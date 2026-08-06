param(
    [switch]$Watch,
    [int]$IntervalSeconds = 10,
    [string]$ConfigPath = ""
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$syncScript = Join-Path $scriptDir "sync_to_obsidian.ps1"

$arguments = @(
    "-NoProfile",
    "-ExecutionPolicy",
    "Bypass",
    "-NoExit",
    "-File",
    $syncScript
)

if ($Watch) {
    $arguments += "-Watch"
    $arguments += "-IntervalSeconds"
    $arguments += $IntervalSeconds
}

if ($ConfigPath -and $ConfigPath.Trim().Length -gt 0) {
    $arguments += "-ConfigPath"
    $arguments += $ConfigPath
}

Start-Process -FilePath "powershell.exe" -ArgumentList $arguments -WorkingDirectory $scriptDir -WindowStyle Normal
