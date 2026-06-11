param(
  [switch]$NoMockDashboard,
  [switch]$NoGateway
)

$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$moduleRoot = Split-Path -Parent $scriptDir
$logsDir = Join-Path $moduleRoot 'logs'
$runtimeDir = Join-Path $moduleRoot 'runtime'
$launcherLog = Join-Path $logsDir 'launcher.log'
$mockLog = Join-Path $logsDir 'mock_dashboard.log'
$gatewayLog = Join-Path $logsDir 'voice_gateway.log'

New-Item -ItemType Directory -Force -Path $logsDir | Out-Null
New-Item -ItemType Directory -Force -Path $runtimeDir | Out-Null

$python = Join-Path $moduleRoot '.venv\Scripts\python.exe'
if (-not (Test-Path $python)) {
  $python = 'python'
}

function Write-LauncherLog {
  param([string]$Message)
  Add-Content -Path $launcherLog -Value "$(Get-Date -Format o) $Message"
}

Write-LauncherLog 'Launcher starting.'
Write-LauncherLog "Module root: $moduleRoot"

if (-not $NoMockDashboard) {
  $mockArgs = @(
    '-NoProfile'
    '-WindowStyle'
    'Hidden'
    '-WorkingDirectory'
    $moduleRoot
    '-Command'
    "& '$python' examples/dashboard_mock/mock_dashboard_api.py *> '$mockLog'"
  )

  Start-Process -FilePath 'powershell.exe' -ArgumentList $mockArgs | Out-Null
  Write-LauncherLog 'Mock dashboard started.'
}

if (-not $NoGateway) {
  $gatewayArgs = @(
    '-NoProfile'
    '-WindowStyle'
    'Hidden'
    '-WorkingDirectory'
    $moduleRoot
    '-Command'
    "& '$python' -m src.voice_gateway.app *> '$gatewayLog'"
  )

  Start-Process -FilePath 'powershell.exe' -ArgumentList $gatewayArgs | Out-Null
  Write-LauncherLog 'Voice gateway started.'
}

Write-LauncherLog 'Launcher finished.'
