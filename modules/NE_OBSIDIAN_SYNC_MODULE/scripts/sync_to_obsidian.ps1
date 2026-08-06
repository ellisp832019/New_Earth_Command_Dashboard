param(
    [switch]$Watch,
    [int]$IntervalSeconds = 10,
    [string]$ConfigPath = ""
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$pythonScript = Join-Path $scriptDir "sync_obsidian.py"

$python = Get-Command python -ErrorAction SilentlyContinue
if ($null -eq $python) {
    $python = Get-Command python3 -ErrorAction SilentlyContinue
}

if ($null -eq $python) {
    throw "Python is required to run the Obsidian sync module."
}

$pythonPath = $python.Path
if ($null -eq $pythonPath -or $pythonPath.Trim().Length -eq 0) {
    $pythonPath = $python.Source
}

$modeLabel = if ($Watch) { "watch" } else { "sync" }
Write-Host "=== Obsidian Sync Module ==="
Write-Host "Mode: $modeLabel"
Write-Host "Script: $pythonScript"
if ($ConfigPath -and $ConfigPath.Trim().Length -gt 0) {
    Write-Host "Config: $ConfigPath"
} else {
    Write-Host "Config: default module config"
}
Write-Host ""

$args = @($pythonPath, $pythonScript)
if ($Watch) {
    $args += "watch"
    $args += "--interval"
    $args += $IntervalSeconds
} else {
    $args += "sync"
}

if ($ConfigPath -and $ConfigPath.Trim().Length -gt 0) {
    $args += "--config"
    $args += $ConfigPath
}

& $args[0] @($args[1..($args.Length - 1)])

if (-not $Watch) {
    Write-Host ""
    Write-Host "Obsidian sync wrapper finished."
}
