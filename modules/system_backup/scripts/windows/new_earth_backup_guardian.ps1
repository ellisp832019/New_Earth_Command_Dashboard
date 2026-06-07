param(
  [Parameter(Mandatory=$true)]
  [ValidateSet("DryRun","BackupNow","VerifyLatest","RestoreDryRun")]
  [string]$Mode
)

$ModuleRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$ConfigPath = Join-Path $ModuleRoot "config\backup_paths.local.json"
$ExampleConfigPath = Join-Path $ModuleRoot "config\backup_paths.local.json.example"
$RuntimeDir = Join-Path $ModuleRoot "runtime"

if (!(Test-Path $RuntimeDir)) {
  New-Item -ItemType Directory -Path $RuntimeDir | Out-Null
}

if (Test-Path $ConfigPath) {
  $Config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
} else {
  $Config = Get-Content $ExampleConfigPath -Raw | ConvertFrom-Json
}

$Source = $Config.source_drive
$Target = $Config.mirror_folder
$Reports = $Config.reports_folder
$BackupRoot = $Config.backup_target
$RestoreTestFolder = $Config.restore_test_folder

$ExistingStatus = $null
if (Test-Path $StatusPath) {
  try {
    $ExistingStatus = Get-Content $StatusPath -Raw | ConvertFrom-Json
  } catch {
    $ExistingStatus = $null
  }
}

if (!(Test-Path $Reports)) {
  New-Item -ItemType Directory -Path $Reports -Force | Out-Null
}

$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$LogPath = Join-Path $Reports "backup_guardian_$Timestamp.log"
$StatusPath = Join-Path $RuntimeDir "latest_status.json"

function Get-ExistingValue($Object, $Name, $Fallback) {
  if ($null -eq $Object) {
    return $Fallback
  }

  $Property = $Object.PSObject.Properties[$Name]
  if ($null -eq $Property) {
    return $Fallback
  }

  if ($null -eq $Property.Value -or [string]::IsNullOrWhiteSpace([string]$Property.Value)) {
    return $Fallback
  }

  return $Property.Value
}

function Write-Status($State, $Summary, $Warnings, $Errors, $LastBackupAt = $null, $LastVerificationAt = $null, $RestoreTestStatus = $null) {
  $ResolvedLastBackupAt = if ($LastBackupAt) {
    $LastBackupAt
  } else {
    Get-ExistingValue $ExistingStatus "last_backup_at" $null
  }

  $ResolvedLastVerificationAt = if ($LastVerificationAt) {
    $LastVerificationAt
  } else {
    Get-ExistingValue $ExistingStatus "last_verification_at" $null
  }

  $ResolvedRestoreTestStatus = if ($RestoreTestStatus) {
    $RestoreTestStatus
  } else {
    Get-ExistingValue $ExistingStatus "restore_test_status" "Not run yet"
  }

  $status = [ordered]@{
    module = "system_backup"
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
    backup_size_text = Get-ExistingValue $ExistingStatus "backup_size_text" "Not tracked in V1"
    latest_report_path = $LogPath
    warnings = $Warnings
    errors = $Errors
    updated_at = (Get-Date).ToString("o")
    log_path = $LogPath
  }
  $status | ConvertTo-Json -Depth 5 | Set-Content $StatusPath
}

if (!(Test-Path $Source)) {
  Write-Status "red" "Source drive missing" @() @("Source path not found: $Source")
  exit 1
}

if ($Mode -ne "DryRun" -and !(Test-Path (Split-Path $Target -Parent))) {
  Write-Status "red" "Backup drive missing" @() @("Backup target root not found: $Target")
  exit 1
}

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

if ($Mode -eq "DryRun") {
  robocopy $Source $Target /MIR /L /R:2 /W:2 /XJ /FFT /Z @ExcludeArgs /LOG:$LogPath
  Write-Status "grey" "Dry run complete. No files copied." @() @()
  exit 0
}

if ($Mode -eq "BackupNow") {
  if (!(Test-Path $Target)) {
    New-Item -ItemType Directory -Path $Target -Force | Out-Null
  }

  robocopy $Source $Target /MIR /R:2 /W:2 /XJ /FFT /Z @ExcludeArgs /LOG:$LogPath
  $RoboCode = $LASTEXITCODE

  if ($RoboCode -le 7) {
    Write-Status "amber" "Backup completed successfully. Verification still recommended." @("Robocopy exit code: $RoboCode") @() (Get-Date).ToString("o")
    exit 0
  } else {
    Write-Status "red" "Backup failed." @() @("Robocopy exit code: $RoboCode")
    exit $RoboCode
  }
}

if ($Mode -eq "VerifyLatest") {
  if (Test-Path $Target) {
    Write-Status "green" "Backup target exists. Basic verification passed." @("Deep checksum verification to be added in Phase 2.") @() $null (Get-Date).ToString("o")
    exit 0
  } else {
    Write-Status "red" "Backup target missing." @() @("Missing: $Target")
    exit 1
  }
}

if ($Mode -eq "RestoreDryRun") {
  $RestoreTest = $Config.restore_test_folder
  robocopy $Target $RestoreTest /MIR /L /R:2 /W:2 /XJ /FFT /Z /LOG:$LogPath
  Write-Status "grey" "Restore dry run complete. No files restored." @() @() $null $null "Restore dry run complete. No files restored."
  exit 0
}
