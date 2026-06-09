param(
  [Parameter(Mandatory=$true)]
  [ValidateSet("DryRun","BackupNow","VerifyLatest","RestoreDryRun","QuickIncremental","DailyBackup","WeeklySnapshot","MonthlyArchive")]
  [string]$Mode
)

$ModuleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$ConfigPath = Join-Path $ModuleRoot "config\backup_paths.local.json"
$ExampleConfigPath = Join-Path $ModuleRoot "config\backup_paths.local.json.example"
$RuntimeDir = Join-Path $ModuleRoot "runtime"
$StatusPath = Join-Path $RuntimeDir "latest_status.json"
$HistoryPath = Join-Path $RuntimeDir "backup_history.json"

if (!(Test-Path $RuntimeDir)) {
  New-Item -ItemType Directory -Path $RuntimeDir | Out-Null
}

if (Test-Path $ConfigPath) {
  $Config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
} elseif (Test-Path $ExampleConfigPath) {
  $Config = Get-Content $ExampleConfigPath -Raw | ConvertFrom-Json
} else {
  throw "Backup guardian config not found. Expected either '$ConfigPath' or '$ExampleConfigPath'."
}

$Source = $Config.source_drive
$Target = $Config.mirror_folder
$Reports = $Config.reports_folder
$Manifests = $Config.manifests_folder
$BackupRoot = $Config.backup_target
$RestoreTestFolder = $Config.restore_test_folder

function Get-ConfigValue($Object, $Path, $Fallback) {
  if ($null -eq $Object) {
    return $Fallback
  }

  $Current = $Object
  foreach ($Segment in $Path.Split('.')) {
    if ($null -eq $Current) {
      return $Fallback
    }

    $Property = $Current.PSObject.Properties[$Segment]
    if ($null -eq $Property) {
      return $Fallback
    }

    $Current = $Property.Value
  }

  if ($null -eq $Current -or [string]::IsNullOrWhiteSpace([string]$Current)) {
    return $Fallback
  }

  return $Current
}

function Get-IntValue($Value, $Fallback) {
  if ($Value -is [int]) {
    return [int]$Value
  }
  if ($Value -is [long]) {
    return [int]$Value
  }
  if ($Value -is [string]) {
    $Parsed = 0
    if ([int]::TryParse($Value.Trim(), [ref]$Parsed)) {
      return $Parsed
    }
  }
  return $Fallback
}

function Format-ByteSize([long]$Bytes) {
  if ($Bytes -lt 1024) { return "$Bytes B" }
  if ($Bytes -lt 1048576) { return "{0:N1} KB" -f ($Bytes / 1KB) }
  if ($Bytes -lt 1073741824) { return "{0:N1} MB" -f ($Bytes / 1MB) }
  return "{0:N1} GB" -f ($Bytes / 1GB)
}

function Get-FolderStats([string]$Path) {
  if (!(Test-Path $Path)) {
    return [ordered]@{
      file_count = 0
      size_bytes = 0
      size_text = '0 B'
    }
  }

  $Files = Get-ChildItem -LiteralPath $Path -File -Recurse -Force -ErrorAction SilentlyContinue
  $SizeBytes = ($Files | Measure-Object -Property Length -Sum).Sum
  if ($null -eq $SizeBytes) {
    $SizeBytes = 0
  }

  return [ordered]@{
    file_count = @($Files).Count
    size_bytes = [long]$SizeBytes
    size_text = Format-ByteSize([long]$SizeBytes)
  }
}

function Read-JsonFile([string]$Path) {
  if (!(Test-Path $Path)) {
    return $null
  }

  try {
    return Get-Content $Path -Raw | ConvertFrom-Json
  } catch {
    return $null
  }
}

function Write-JsonFile([string]$Path, $Object) {
  $Json = $Object | ConvertTo-Json -Depth 10
  $Json | Set-Content -Path $Path
}

function Get-ManifestPath([string]$Stamp) {
  if (!(Test-Path $Manifests)) {
    New-Item -ItemType Directory -Path $Manifests -Force | Out-Null
  }
  return Join-Path $Manifests "backup_manifest_$Stamp.json"
}

function Get-SnapshotFolder([string]$Kind, [string]$Stamp) {
  $Folder = Join-Path $BackupRoot $Kind
  if (!(Test-Path $Folder)) {
    New-Item -ItemType Directory -Path $Folder -Force | Out-Null
  }
  $Path = Join-Path $Folder $Stamp
  if (!(Test-Path $Path)) {
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
  }
  return $Path
}

function Prune-SnapshotFolders([string]$Kind, [int]$Keep) {
  if ($Keep -le 0) {
    return
  }

  $Root = Join-Path $BackupRoot $Kind
  if (!(Test-Path $Root)) {
    return
  }

  $Folders = Get-ChildItem -LiteralPath $Root -Directory -ErrorAction SilentlyContinue |
    Sort-Object Name -Descending

  foreach ($Folder in $Folders | Select-Object -Skip $Keep) {
    Remove-Item -LiteralPath $Folder.FullName -Recurse -Force -ErrorAction SilentlyContinue
  }
}

function Get-BackupKind([string]$CurrentMode) {
  return switch ($CurrentMode) {
    'QuickIncremental' { 'quick' }
    'DailyBackup' { 'daily' }
    'WeeklySnapshot' { 'weekly' }
    'MonthlyArchive' { 'monthly' }
    default { 'manual' }
  }
}

function Get-ActionLabel([string]$CurrentMode) {
  return switch ($CurrentMode) {
    'DryRun' { 'Dry Run' }
    'BackupNow' { 'Backup Now' }
    'VerifyLatest' { 'Verify Latest' }
    'RestoreDryRun' { 'Restore Dry Run' }
    'QuickIncremental' { 'Quick Incremental' }
    'DailyBackup' { 'Scheduled Daily Backup' }
    'WeeklySnapshot' { 'Weekly Snapshot' }
    'MonthlyArchive' { 'Monthly Archive' }
    default { $CurrentMode }
  }
}

function Get-RestorePointLabel([string]$CurrentMode, [datetime]$When) {
  $Stamp = $When.ToString('yyyy-MM-dd HH:mm')
  return switch ($CurrentMode) {
    'DailyBackup' { "Daily backup - $Stamp" }
    'WeeklySnapshot' { "Weekly snapshot - $Stamp" }
    'MonthlyArchive' { "Monthly archive - $Stamp" }
    'BackupNow' { "Manual backup - $Stamp" }
    'QuickIncremental' { "Quick incremental - $Stamp" }
    default { "$CurrentMode - $Stamp" }
  }
}

function Get-RetentionValue([string]$Kind, [int]$Fallback) {
  return switch ($Kind) {
    'quick' { Get-IntValue (Get-ConfigValue $Config 'retention.quick_keep' $Fallback) $Fallback }
    'daily' { Get-IntValue (Get-ConfigValue $Config 'retention.daily_keep' $Fallback) $Fallback }
    'weekly' { Get-IntValue (Get-ConfigValue $Config 'retention.weekly_keep' $Fallback) $Fallback }
    'monthly' { Get-IntValue (Get-ConfigValue $Config 'retention.monthly_keep' $Fallback) $Fallback }
    default { $Fallback }
  }
}

function Write-Manifest([string]$Path, [string]$Action, [string]$Kind, [string]$Summary, [hashtable]$SourceStats, [hashtable]$TargetStats, [string]$ReportPath) {
  $Manifest = [ordered]@{
    module = 'system_backup'
    action = $Action
    backup_kind = $Kind
    summary = $Summary
    created_at = (Get-Date).ToString('o')
    source_drive = $Source
    target_drive = $BackupRoot
    source_file_count = $SourceStats.file_count
    source_size_bytes = $SourceStats.size_bytes
    source_size_text = $SourceStats.size_text
    target_file_count = $TargetStats.file_count
    target_size_bytes = $TargetStats.size_bytes
    target_size_text = $TargetStats.size_text
    report_path = $ReportPath
  }

  Write-JsonFile -Path $Path -Object $Manifest
}

function Write-HistoryEntry($Entry) {
  $History = @{ events = @() }
  $Existing = Read-JsonFile -Path $HistoryPath
  if ($null -ne $Existing -and $Existing.PSObject.Properties['events']) {
    $History.events = @($Existing.events)
  }

  $History.events += $Entry
  $History.events = @($History.events | Sort-Object {
      $Finished = $null
      if ($_.PSObject.Properties['finished_at']) {
        $Finished = $_.finished_at
      }
      if ([string]::IsNullOrWhiteSpace([string]$Finished) -and $_.PSObject.Properties['updated_at']) {
        $Finished = $_.updated_at
      }
      if ([string]::IsNullOrWhiteSpace([string]$Finished)) {
        $Finished = '1970-01-01T00:00:00Z'
      }
      [datetime]::Parse([string]$Finished)
    } -Descending)
  if ($History.events.Count -gt 200) {
    $History.events = @($History.events | Select-Object -First 200)
  }

  Write-JsonFile -Path $HistoryPath -Object $History
}

function Write-Status(
  $State,
  $Summary,
  $Warnings,
  $Errors,
  $LastBackupAt = $null,
  $LastVerificationAt = $null,
  $RestoreTestStatus = $null,
  $FilesScanned = $null,
  $FilesCopied = $null,
  $FilesSkipped = $null,
  $BackupSizeBytes = $null,
  $DurationMs = $null,
  $BackupKind = $null,
  $ManifestPath = $null,
  $RestorePointPath = $null
) {
  $ResolvedLastBackupAt = if ($LastBackupAt) { $LastBackupAt } else { Get-ConfigValue $ExistingStatus 'last_backup_at' $null }
  $ResolvedLastVerificationAt = if ($LastVerificationAt) { $LastVerificationAt } else { Get-ConfigValue $ExistingStatus 'last_verification_at' $null }
  $ResolvedRestoreTestStatus = if ($RestoreTestStatus) { $RestoreTestStatus } else { Get-ConfigValue $ExistingStatus 'restore_test_status' 'Not run yet' }
  $ResolvedBackupSizeText = if ($BackupSizeBytes -ne $null) { Format-ByteSize([long]$BackupSizeBytes) } else { Get-ConfigValue $ExistingStatus 'backup_size_text' 'Not tracked in V1' }

  $status = [ordered]@{
    module = 'system_backup'
    state = $State
    health_state = $State
    mode = $Mode
    source_drive = $Source
    backup_target = $BackupRoot
    source = $Source
    target = $Target
    summary = $Summary
    latest_backup_status = $Summary
    last_backup_at = $ResolvedLastBackupAt
    last_verification_at = $ResolvedLastVerificationAt
    restore_test_status = $ResolvedRestoreTestStatus
    backup_size_text = $ResolvedBackupSizeText
    backup_file_count = $FilesCopied
    backup_size_bytes = $BackupSizeBytes
    backup_duration_ms = $DurationMs
    backup_kind = $BackupKind
    files_scanned = $FilesScanned
    files_copied = $FilesCopied
    files_skipped = $FilesSkipped
    manifest_path = $ManifestPath
    restore_point_path = $RestorePointPath
    history_path = $HistoryPath
    latest_report_path = $LogPath
    warnings = $Warnings
    errors = $Errors
    updated_at = (Get-Date).ToString('o')
    log_path = $LogPath
  }

  $status | ConvertTo-Json -Depth 10 | Set-Content $StatusPath
}

function Create-RestorePoint(
  [string]$Kind,
  [string]$Action,
  [string]$Summary,
  [hashtable]$SourceStats,
  [hashtable]$TargetStats,
  [string]$ReportPath,
  [string]$ManifestPath,
  [string]$RestoreTestStatus,
  [int]$DurationMs
) {
  $Stamp = (Get-Date).ToString('yyyyMMdd_HHmmss')
  $RestorePointFolder = Get-SnapshotFolder -Kind $Kind -Stamp $Stamp
  $RestorePointPath = Join-Path $RestorePointFolder 'restore_point.json'

  $RestorePoint = [ordered]@{
    module = 'system_backup'
    action = $Action
    backup_kind = $Kind
    restore_point_label = Get-RestorePointLabel -CurrentMode $Action -When (Get-Date)
    summary = $Summary
    created_at = (Get-Date).ToString('o')
    report_path = $ReportPath
    manifest_path = $ManifestPath
    restore_test_status = $RestoreTestStatus
    duration_ms = $DurationMs
    source_file_count = $SourceStats.file_count
    source_size_bytes = $SourceStats.size_bytes
    source_size_text = $SourceStats.size_text
    target_file_count = $TargetStats.file_count
    target_size_bytes = $TargetStats.size_bytes
    target_size_text = $TargetStats.size_text
  }

  Write-JsonFile -Path $RestorePointPath -Object $RestorePoint
  Prune-SnapshotFolders -Kind $Kind -Keep (Get-RetentionValue -Kind $Kind -Fallback 7)
  return $RestorePointPath
}

function Invoke-BackupRun(
  [string]$CurrentMode,
  [string]$SummaryWhenSuccess,
  [string]$SummaryWhenFailure,
  [switch]$PreserveDeletedSourceFiles
) {
  $RunStartedAt = Get-Date
  $Timer = [System.Diagnostics.Stopwatch]::StartNew()
  $ActionLabel = Get-ActionLabel -CurrentMode $CurrentMode
  $BackupKind = Get-BackupKind -CurrentMode $CurrentMode
  $ManifestPath = $null
  $RestorePointPath = $null

  if ($CurrentMode -ne 'DryRun' -and !(Test-Path $Target)) {
    New-Item -ItemType Directory -Path $Target -Force | Out-Null
  }

  $SourceStats = Get-FolderStats -Path $Source
  $TargetStatsBefore = Get-FolderStats -Path $Target

  if ($CurrentMode -eq 'DryRun') {
    $CopyModeArgs = if ($PreserveDeletedSourceFiles) { '/E' } else { '/MIR' }
    robocopy $Source $Target $CopyModeArgs /L /R:2 /W:2 /XJ /FFT /Z @ExcludeArgs /TEE /LOG:$LogPath
    $RoboCode = $LASTEXITCODE
    $Timer.Stop()
    $TargetStatsAfter = Get-FolderStats -Path $Target
    $BackupSizeBytes = $TargetStatsAfter.size_bytes
    $FilesCopied = 0
    $FilesScanned = $SourceStats.file_count
    $FilesSkipped = $SourceStats.file_count
    $Summary = if ($RoboCode -le 7) { $SummaryWhenSuccess } else { $SummaryWhenFailure }
    $Warnings = @()
    $Errors = @()
    if ($RoboCode -gt 7) {
      $Errors = @("Robocopy exit code: $RoboCode")
    }

    if ($Config.create_manifest) {
      $ManifestPath = Get-ManifestPath -Stamp $RunStartedAt.ToString('yyyyMMdd_HHmmss')
      Write-Manifest -Path $ManifestPath -Action $ActionLabel -Kind $BackupKind -Summary $Summary -SourceStats $SourceStats -TargetStats $TargetStatsAfter -ReportPath $LogPath
    }

    Write-Status -State ($(if ($RoboCode -le 7) { 'grey' } else { 'red' })) -Summary $Summary -Warnings $Warnings -Errors $Errors -FilesScanned $FilesScanned -FilesCopied $FilesCopied -FilesSkipped $FilesSkipped -BackupSizeBytes $BackupSizeBytes -DurationMs $Timer.ElapsedMilliseconds -BackupKind $BackupKind -ManifestPath $ManifestPath

    Write-HistoryEntry ([ordered]@{
      action = $ActionLabel
      mode = $CurrentMode
      backup_kind = $BackupKind
      state = ($(if ($RoboCode -le 7) { 'grey' } else { 'red' }))
      summary = $Summary
      started_at = $RunStartedAt.ToString('o')
      finished_at = (Get-Date).ToString('o')
      duration_ms = $Timer.ElapsedMilliseconds
      files_scanned = $FilesScanned
      files_copied = $FilesCopied
      files_skipped = $FilesSkipped
      backup_size_bytes = $BackupSizeBytes
      backup_size_text = Format-ByteSize([long]$BackupSizeBytes)
      manifest_path = $ManifestPath
      report_path = $LogPath
      restore_point_label = ''
      restore_point_path = ''
    })
    exit ($(if ($RoboCode -le 7) { 0 } else { $RoboCode }))
  }

  $CopyModeArgs = if ($PreserveDeletedSourceFiles) { '/E' } else { '/MIR' }
  robocopy $Source $Target $CopyModeArgs /R:2 /W:2 /XJ /FFT /Z @ExcludeArgs /TEE /LOG:$LogPath
  $RoboCode = $LASTEXITCODE
  $Timer.Stop()
  $TargetStatsAfter = Get-FolderStats -Path $Target
  $BackupSizeBytes = $TargetStatsAfter.size_bytes
  $FilesScanned = $SourceStats.file_count
  $FilesCopied = if ($PreserveDeletedSourceFiles) {
    [Math]::Max(0, $TargetStatsAfter.file_count - $TargetStatsBefore.file_count)
  } else {
    $TargetStatsAfter.file_count
  }
  $FilesSkipped = if ($PreserveDeletedSourceFiles) {
    [Math]::Max(0, $TargetStatsBefore.file_count - $TargetStatsAfter.file_count)
  } else {
    [Math]::Max(0, $FilesScanned - $FilesCopied)
  }
  $Summary = if ($RoboCode -le 7) { $SummaryWhenSuccess } else { $SummaryWhenFailure }
  $Warnings = @()
  $Errors = @()

  if ($RoboCode -le 7) {
    $Warnings += "Robocopy exit code: $RoboCode"
  } else {
    $Errors += "Robocopy exit code: $RoboCode"
  }

  if ($Config.create_manifest) {
    $ManifestPath = Get-ManifestPath -Stamp $RunStartedAt.ToString('yyyyMMdd_HHmmss')
    Write-Manifest -Path $ManifestPath -Action $ActionLabel -Kind $BackupKind -Summary $Summary -SourceStats $SourceStats -TargetStats $TargetStatsAfter -ReportPath $LogPath
  }

  if ($RoboCode -le 7) {
    $RestorePointPath = Create-RestorePoint -Kind $BackupKind -Action $CurrentMode -Summary $Summary -SourceStats $SourceStats -TargetStats $TargetStatsAfter -ReportPath $LogPath -ManifestPath $ManifestPath -RestoreTestStatus (Get-ConfigValue $ExistingStatus 'restore_test_status' 'Not run yet') -DurationMs $Timer.ElapsedMilliseconds
  }

  $State = if ($RoboCode -le 7) {
    if ($CurrentMode -eq 'BackupNow') {
      'amber'
    } elseif ($CurrentMode -eq 'DailyBackup' -or $CurrentMode -eq 'WeeklySnapshot' -or $CurrentMode -eq 'MonthlyArchive' -or $CurrentMode -eq 'QuickIncremental') {
      'green'
    } else {
      'grey'
    }
  } else {
    'red'
  }

  Write-Status -State $State -Summary $Summary -Warnings $Warnings -Errors $Errors -LastBackupAt ($(if ($CurrentMode -eq 'VerifyLatest') { $null } else { (Get-Date).ToString('o') })) -LastVerificationAt ($(if ($CurrentMode -eq 'VerifyLatest') { (Get-Date).ToString('o') } else { $null })) -RestoreTestStatus (Get-ConfigValue $ExistingStatus 'restore_test_status' 'Not run yet') -FilesScanned $FilesScanned -FilesCopied $FilesCopied -FilesSkipped $FilesSkipped -BackupSizeBytes $BackupSizeBytes -DurationMs $Timer.ElapsedMilliseconds -BackupKind $BackupKind -ManifestPath $ManifestPath -RestorePointPath $RestorePointPath

  $RestorePointLabel = if ($RestorePointPath) { Get-RestorePointLabel -CurrentMode $CurrentMode -When (Get-Date) } else { '' }
  Write-HistoryEntry ([ordered]@{
    action = $ActionLabel
    mode = $CurrentMode
    backup_kind = $BackupKind
    state = $State
    summary = $Summary
    started_at = $RunStartedAt.ToString('o')
    finished_at = (Get-Date).ToString('o')
    duration_ms = $Timer.ElapsedMilliseconds
    files_scanned = $FilesScanned
    files_copied = $FilesCopied
    files_skipped = $FilesSkipped
    backup_size_bytes = $BackupSizeBytes
    backup_size_text = Format-ByteSize([long]$BackupSizeBytes)
    manifest_path = $ManifestPath
    report_path = $LogPath
    restore_point_label = $RestorePointLabel
    restore_point_path = $RestorePointPath
  })

  if ($RoboCode -le 7) {
    exit 0
  }

  exit $RoboCode
}

$ExistingStatus = Read-JsonFile -Path $StatusPath

if (!(Test-Path $Reports)) {
  New-Item -ItemType Directory -Path $Reports -Force | Out-Null
}

$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$LogPath = Join-Path $Reports "backup_guardian_$Timestamp.log"

$ExcludeDirs = @(
  ".git",
  "node_modules",
  "build",
  "dist",
  ".cache",
  ".gradle",
  ".flutter_tool",
  ".dart_tool",
  "__pycache__",
  ".pytest_cache",
  "target",
  "tmp",
  "temp",
  "logs",
  ".local_backup_runtime",
  "backup_tmp"
)

$ExcludeArgs = @()
foreach ($dir in $ExcludeDirs) {
  $ExcludeArgs += "/XD"
  $ExcludeArgs += $dir
}

if (!(Test-Path $Source)) {
  Write-Status "red" "Source drive missing" @() @("Source path not found: $Source")
  Write-HistoryEntry ([ordered]@{
    action = 'Source Check'
    mode = $Mode
    backup_kind = 'manual'
    state = 'red'
    summary = "Source path not found: $Source"
    started_at = (Get-Date).ToString('o')
    finished_at = (Get-Date).ToString('o')
    duration_ms = 0
    files_scanned = 0
    files_copied = 0
    files_skipped = 0
    backup_size_bytes = 0
    backup_size_text = '0 B'
    manifest_path = ''
    report_path = $LogPath
    restore_point_label = ''
    restore_point_path = ''
  })
  exit 1
}

if ($Mode -ne "DryRun" -and !(Test-Path (Split-Path $Target -Parent))) {
  Write-Status "red" "Backup drive missing" @() @("Backup target root not found: $Target")
  Write-HistoryEntry ([ordered]@{
    action = 'Drive Check'
    mode = $Mode
    backup_kind = 'manual'
    state = 'red'
    summary = "Backup target root not found: $Target"
    started_at = (Get-Date).ToString('o')
    finished_at = (Get-Date).ToString('o')
    duration_ms = 0
    files_scanned = 0
    files_copied = 0
    files_skipped = 0
    backup_size_bytes = 0
    backup_size_text = '0 B'
    manifest_path = ''
    report_path = $LogPath
    restore_point_label = ''
    restore_point_path = ''
  })
  exit 1
}

switch ($Mode) {
  'DryRun' {
    Invoke-BackupRun -CurrentMode $Mode -SummaryWhenSuccess 'Dry run complete. No files copied.' -SummaryWhenFailure 'Dry run failed.'
  }
  'BackupNow' {
    Invoke-BackupRun -CurrentMode $Mode -SummaryWhenSuccess 'Backup completed successfully. Verification still recommended.' -SummaryWhenFailure 'Backup failed.'
  }
  'QuickIncremental' {
    Invoke-BackupRun -CurrentMode $Mode -PreserveDeletedSourceFiles -SummaryWhenSuccess 'Quick incremental backup completed successfully. Deleted source files were preserved in the target.' -SummaryWhenFailure 'Quick incremental backup failed.'
  }
  'DailyBackup' {
    Invoke-BackupRun -CurrentMode $Mode -SummaryWhenSuccess 'Scheduled daily backup completed successfully.' -SummaryWhenFailure 'Scheduled daily backup failed.'
  }
  'WeeklySnapshot' {
    Invoke-BackupRun -CurrentMode $Mode -SummaryWhenSuccess 'Weekly snapshot completed successfully.' -SummaryWhenFailure 'Weekly snapshot failed.'
  }
  'MonthlyArchive' {
    Invoke-BackupRun -CurrentMode $Mode -SummaryWhenSuccess 'Monthly archive completed successfully.' -SummaryWhenFailure 'Monthly archive failed.'
  }
  'VerifyLatest' {
    $TargetStats = Get-FolderStats -Path $Target
    if (Test-Path $Target) {
      $LastBackupAt = Get-ConfigValue $ExistingStatus 'last_backup_at' $null
      $Warnings = @("Deep checksum verification to be added in Phase 2.")
      if ($TargetStats.file_count -gt 0) {
        $Warnings += "Target contains $($TargetStats.file_count) file$(if ($TargetStats.file_count -eq 1) { '' } else { 's' })."
      }
      Write-Status "green" "Backup target exists. Basic verification passed." $Warnings @() $null (Get-Date).ToString("o") (Get-ConfigValue $ExistingStatus 'restore_test_status' 'Not run yet') $TargetStats.file_count $TargetStats.file_count 0 $TargetStats.size_bytes 0 'backup' $null $null
      Write-HistoryEntry ([ordered]@{
        action = 'Verify Latest'
        mode = $Mode
        backup_kind = 'manual'
        state = 'green'
        summary = 'Backup target exists. Basic verification passed.'
        started_at = (Get-Date).ToString('o')
        finished_at = (Get-Date).ToString('o')
        duration_ms = 0
        files_scanned = $TargetStats.file_count
        files_copied = $TargetStats.file_count
        files_skipped = 0
        backup_size_bytes = $TargetStats.size_bytes
        backup_size_text = $TargetStats.size_text
        manifest_path = ''
        report_path = $LogPath
        restore_point_label = ''
        restore_point_path = ''
      })
      exit 0
    } else {
      Write-Status "red" "Backup target missing." @() @("Missing: $Target")
      Write-HistoryEntry ([ordered]@{
        action = 'Verify Latest'
        mode = $Mode
        backup_kind = 'manual'
        state = 'red'
        summary = "Missing: $Target"
        started_at = (Get-Date).ToString('o')
        finished_at = (Get-Date).ToString('o')
        duration_ms = 0
        files_scanned = 0
        files_copied = 0
        files_skipped = 0
        backup_size_bytes = 0
        backup_size_text = '0 B'
        manifest_path = ''
        report_path = $LogPath
        restore_point_label = ''
        restore_point_path = ''
      })
      exit 1
    }
  }
  'RestoreDryRun' {
    if (!(Test-Path $Target)) {
      Write-Status "red" "Restore target missing." @() @("Missing: $Target")
      exit 1
    }

    $Timer = [System.Diagnostics.Stopwatch]::StartNew()
    robocopy $Target $RestoreTestFolder /MIR /L /R:2 /W:2 /XJ /FFT /Z /TEE /LOG:$LogPath
    $RoboCode = $LASTEXITCODE
    $Timer.Stop()
    $TargetStats = Get-FolderStats -Path $Target
    $Warnings = @()
    $Errors = @()
    if ($RoboCode -le 7) {
      $Warnings += "Restore dry run complete. No files restored."
    } else {
      $Errors += "Robocopy exit code: $RoboCode"
    }

    Write-Status ($(if ($RoboCode -le 7) { 'grey' } else { 'red' })) "Restore dry run complete. No files restored." $Warnings $Errors $null $null "Restore dry run complete. No files restored." $TargetStats.file_count 0 0 $TargetStats.size_bytes $Timer.ElapsedMilliseconds 'manual' $null $null
    Write-HistoryEntry ([ordered]@{
      action = 'Restore Dry Run'
      mode = $Mode
      backup_kind = 'manual'
      state = ($(if ($RoboCode -le 7) { 'grey' } else { 'red' }))
      summary = 'Restore dry run complete. No files restored.'
      started_at = (Get-Date).ToString('o')
      finished_at = (Get-Date).ToString('o')
      duration_ms = $Timer.ElapsedMilliseconds
      files_scanned = $TargetStats.file_count
      files_copied = 0
      files_skipped = $TargetStats.file_count
      backup_size_bytes = $TargetStats.size_bytes
      backup_size_text = $TargetStats.size_text
      manifest_path = ''
      report_path = $LogPath
      restore_point_label = ''
      restore_point_path = ''
    })
    exit ($(if ($RoboCode -le 7) { 0 } else { $RoboCode }))
  }
}
