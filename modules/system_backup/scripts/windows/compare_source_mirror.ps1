param(
  [string]$SourcePath = '',
  [string]$TargetPath = '',
  [string]$OutputPath = '',
  [string[]]$IgnoreRelativePath = @()
)

$ModuleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$ConfigPath = Join-Path $ModuleRoot "config\backup_paths.local.json"
$ExampleConfigPath = Join-Path $ModuleRoot "config\backup_paths.local.json.example"
$RuntimeDir = Join-Path $ModuleRoot "runtime"

if (!(Test-Path $RuntimeDir)) {
  New-Item -ItemType Directory -Path $RuntimeDir -Force | Out-Null
}

if ([string]::IsNullOrWhiteSpace($SourcePath) -or [string]::IsNullOrWhiteSpace($TargetPath)) {
  $ConfigFile = if (Test-Path $ConfigPath) { $ConfigPath } elseif (Test-Path $ExampleConfigPath) { $ExampleConfigPath } else { $null }
  if ($null -ne $ConfigFile) {
    try {
      $Config = Get-Content $ConfigFile -Raw | ConvertFrom-Json
      if ([string]::IsNullOrWhiteSpace($SourcePath)) {
        $SourcePath = [string]$Config.source_drive
      }
      if ([string]::IsNullOrWhiteSpace($TargetPath)) {
        $TargetPath = [string]$Config.mirror_folder
      }
    } catch {
      # Fall through to the hard-coded defaults below.
    }
  }
}

if ([string]::IsNullOrWhiteSpace($SourcePath)) {
  $SourcePath = 'D:\'
}
if ([string]::IsNullOrWhiteSpace($TargetPath)) {
  $TargetPath = 'E:\NEW_EARTH_BACKUP\mirror'
}
if ([string]::IsNullOrWhiteSpace($OutputPath)) {
  $OutputPath = Join-Path $RuntimeDir 'source_mirror_diff.txt'
}

$ExcludeDirs = @(
  '.git',
  'node_modules',
  'build',
  'dist',
  '.cache',
  '.gradle',
  '.flutter_tool',
  '.dart_tool',
  '__pycache__',
  '.pytest_cache',
  'target',
  'tmp',
  'temp',
  'logs',
  '.local_backup_runtime',
  'backup_tmp'
)

$DefaultIgnoreRelativePath = @(
  'modules/system_backup/scripts/windows/compare_source_mirror.ps1',
  'modules/system_backup/scripts/windows/compare_source_mirror.bat',
  'modules/system_backup/runtime/source_mirror_diff.txt',
  'docs/roadmap/',
  'lib/features/system_backup/data/backup_guardian_service.dart',
  'lib/features/system_backup/presentation/backup_guardian_screen.dart'
)

function Normalize-Path([string]$Path) {
  return ($Path -replace '\\', '/').TrimEnd('/')
}

function Get-RelativePath([string]$Root, [string]$FullName) {
  $NormalizedRoot = Normalize-Path $Root
  $NormalizedFull = Normalize-Path $FullName
  if ([string]::IsNullOrWhiteSpace($NormalizedRoot) -or [string]::IsNullOrWhiteSpace($NormalizedFull)) {
    return $FullName
  }

  if ($NormalizedFull.Length -le $NormalizedRoot.Length) {
    return ''
  }

  return $NormalizedFull.Substring($NormalizedRoot.Length).TrimStart('/')
}

function Test-IsExcluded([string]$RelativePath) {
  $Normalized = Normalize-Path $RelativePath
  foreach ($Ignore in ($DefaultIgnoreRelativePath + $IgnoreRelativePath)) {
    $IgnoreToken = Normalize-Path $Ignore
    if ($Normalized -eq $IgnoreToken) {
      return $true
    }
    if ($Normalized.Contains($IgnoreToken)) {
      return $true
    }
    if ($Normalized.EndsWith("/$IgnoreToken")) {
      return $true
    }
    if ($Normalized.Contains("/$IgnoreToken/")) {
      return $true
    }
  }
  foreach ($Exclude in $ExcludeDirs) {
    $Token = Normalize-Path $Exclude
    if ($Normalized -eq $Token) {
      return $true
    }
    if ($Normalized.StartsWith("$Token/")) {
      return $true
    }
    if ($Normalized.Contains("/$Token/")) {
      return $true
    }
    if ($Normalized.EndsWith("/$Token")) {
      return $true
    }
  }
  return $false
}

function Get-Inventory([string]$Root) {
  if (!(Test-Path -LiteralPath $Root)) {
    throw "Path not found: $Root"
  }

  $Inventory = @{}
  $Files = Get-ChildItem -LiteralPath $Root -File -Recurse -Force -ErrorAction SilentlyContinue
  foreach ($File in $Files) {
    $RelativePath = Get-RelativePath -Root $Root -FullName $File.FullName
    if (Test-IsExcluded -RelativePath $RelativePath) {
      continue
    }

    $Inventory[$RelativePath] = [ordered]@{
      relative_path      = $RelativePath
      full_name          = $File.FullName
      length             = [long]$File.Length
      last_write_utc     = $File.LastWriteTimeUtc.ToString('o')
      attributes         = $File.Attributes.ToString()
    }
  }

  return $Inventory
}

Write-Host "Comparing source and mirror inventories..."
Write-Host "Source: $SourcePath"
Write-Host "Target: $TargetPath"

$SourceInventory = Get-Inventory -Root $SourcePath
$TargetInventory = Get-Inventory -Root $TargetPath

$AllPaths = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
foreach ($Key in $SourceInventory.Keys) {
  [void]$AllPaths.Add($Key)
}
foreach ($Key in $TargetInventory.Keys) {
  [void]$AllPaths.Add($Key)
}

$Diffs = New-Object System.Collections.Generic.List[object]
foreach ($PathKey in $AllPaths) {
  $SourceItem = $null
  $TargetItem = $null
  $HasSource = $SourceInventory.ContainsKey($PathKey)
  $HasTarget = $TargetInventory.ContainsKey($PathKey)
  if ($HasSource) {
    $SourceItem = $SourceInventory[$PathKey]
  }
  if ($HasTarget) {
    $TargetItem = $TargetInventory[$PathKey]
  }

  if ($HasSource -and -not $HasTarget) {
    $Diffs.Add([pscustomobject]@{
      status         = 'OnlyInSource'
      relative_path  = $PathKey
      source_length  = $SourceItem.length
      target_length  = $null
      source_write   = $SourceItem.last_write_utc
      target_write   = $null
      source_name    = $SourceItem.full_name
      target_name    = $null
    }) | Out-Null
    continue
  }

  if (-not $HasSource -and $HasTarget) {
    $Diffs.Add([pscustomobject]@{
      status         = 'OnlyInMirror'
      relative_path  = $PathKey
      source_length  = $null
      target_length  = $TargetItem.length
      source_write   = $null
      target_write   = $TargetItem.last_write_utc
      source_name    = $null
      target_name    = $TargetItem.full_name
    }) | Out-Null
    continue
  }

  $IsDifferent = $false
  $Reasons = @()
  if ($SourceItem.length -ne $TargetItem.length) {
    $IsDifferent = $true
    $Reasons += 'length'
  }
  if ($SourceItem.last_write_utc -ne $TargetItem.last_write_utc) {
    $IsDifferent = $true
    $Reasons += 'timestamp'
  }
  if ($SourceItem.attributes -ne $TargetItem.attributes) {
    $IsDifferent = $true
    $Reasons += 'attributes'
  }

  if ($IsDifferent) {
    $Diffs.Add([pscustomobject]@{
      status         = 'Changed'
      relative_path  = $PathKey
      source_length  = $SourceItem.length
      target_length  = $TargetItem.length
      source_write   = $SourceItem.last_write_utc
      target_write   = $TargetItem.last_write_utc
      source_name    = $SourceItem.full_name
      target_name    = $TargetItem.full_name
      reasons        = ($Reasons -join ', ')
    }) | Out-Null
  }
}

$OnlyInSource = @($Diffs | Where-Object { $_.status -eq 'OnlyInSource' })
$OnlyInMirror = @($Diffs | Where-Object { $_.status -eq 'OnlyInMirror' })
$Changed = @($Diffs | Where-Object { $_.status -eq 'Changed' })

$ReportLines = New-Object System.Collections.Generic.List[string]
$ReportLines.Add("Source: $SourcePath") | Out-Null
$ReportLines.Add("Target: $TargetPath") | Out-Null
$ReportLines.Add("Generated: $(Get-Date -Format o)") | Out-Null
$ReportLines.Add("Source files: $($SourceInventory.Count)") | Out-Null
$ReportLines.Add("Mirror files: $($TargetInventory.Count)") | Out-Null
$ReportLines.Add("Only in source: $($OnlyInSource.Count)") | Out-Null
$ReportLines.Add("Only in mirror: $($OnlyInMirror.Count)") | Out-Null
$ReportLines.Add("Changed: $($Changed.Count)") | Out-Null
$ReportLines.Add("Exclude dirs: $($ExcludeDirs -join ', ')") | Out-Null
$ReportLines.Add("") | Out-Null

foreach ($Item in ($Diffs | Sort-Object status, relative_path)) {
  $Line = switch ($Item.status) {
    'OnlyInSource' { "[OnlyInSource] $($Item.relative_path)" }
    'OnlyInMirror' { "[OnlyInMirror] $($Item.relative_path)" }
    'Changed' { "[Changed] $($Item.relative_path) ({0})" -f $Item.reasons }
    default { "[$($Item.status)] $($Item.relative_path)" }
  }
  $ReportLines.Add($Line) | Out-Null
}

$ReportLines | Set-Content -Path $OutputPath

Write-Host ""
Write-Host "Summary"
Write-Host "-------"
Write-Host ("Source files : {0}" -f $SourceInventory.Count)
Write-Host ("Mirror files : {0}" -f $TargetInventory.Count)
Write-Host ("Only in source: {0}" -f $OnlyInSource.Count)
Write-Host ("Only in mirror: {0}" -f $OnlyInMirror.Count)
Write-Host ("Changed      : {0}" -f $Changed.Count)
Write-Host ("Report file   : {0}" -f $OutputPath)

if ($Diffs.Count -gt 0) {
  Write-Host ""
  Write-Host "Differences"
  Write-Host "-----------"
  $Diffs | Sort-Object status, relative_path | Format-Table -AutoSize status, relative_path, source_length, target_length, reasons
}

if ($Diffs.Count -gt 0) {
  exit 1
}

exit 0
