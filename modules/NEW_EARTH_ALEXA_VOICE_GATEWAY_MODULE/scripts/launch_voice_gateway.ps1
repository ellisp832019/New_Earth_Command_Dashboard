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
$mockErrorLog = Join-Path $logsDir 'mock_dashboard.error.log'
$gatewayLog = Join-Path $logsDir 'voice_gateway.log'
$gatewayErrorLog = Join-Path $logsDir 'voice_gateway.error.log'
$envFile = Join-Path $moduleRoot '.env.local'
$fallbackEnvFile = Join-Path $moduleRoot '.env'

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

function Import-DotEnvFile {
  param([string]$Path)

  if (-not (Test-Path $Path)) {
    return $false
  }

  foreach ($line in Get-Content -Path $Path) {
    $trimmed = $line.Trim()
    if (-not $trimmed -or $trimmed.StartsWith('#')) {
      continue
    }

    $separatorIndex = $trimmed.IndexOf('=')
    if ($separatorIndex -lt 1) {
      continue
    }

    $name = $trimmed.Substring(0, $separatorIndex).Trim()
    $value = $trimmed.Substring($separatorIndex + 1).Trim()
    [System.Environment]::SetEnvironmentVariable($name, $value, 'Process')
  }

  return $true
}

Write-LauncherLog 'Launcher starting.'
Write-LauncherLog "Module root: $moduleRoot"

if (Import-DotEnvFile -Path $envFile) {
  Write-LauncherLog "Loaded environment from $envFile."
} elseif (Import-DotEnvFile -Path $fallbackEnvFile) {
  Write-LauncherLog "Loaded environment from $fallbackEnvFile."
} else {
  Write-LauncherLog 'No local env file found. Using existing shell environment.'
}

if (-not $NoMockDashboard) {
  Start-Process `
    -FilePath $python `
    -ArgumentList 'examples/dashboard_mock/mock_dashboard_api.py' `
    -WorkingDirectory $moduleRoot `
    -WindowStyle Hidden `
    -RedirectStandardOutput $mockLog `
    -RedirectStandardError $mockErrorLog | Out-Null
  Write-LauncherLog "Mock dashboard started with $python."
}

if (-not $NoGateway) {
  Start-Process `
    -FilePath $python `
    -ArgumentList '-m', 'src.voice_gateway.app' `
    -WorkingDirectory $moduleRoot `
    -WindowStyle Hidden `
    -RedirectStandardOutput $gatewayLog `
    -RedirectStandardError $gatewayErrorLog | Out-Null
  Write-LauncherLog "Voice gateway started with $python."
}

Write-LauncherLog 'Launcher finished.'
