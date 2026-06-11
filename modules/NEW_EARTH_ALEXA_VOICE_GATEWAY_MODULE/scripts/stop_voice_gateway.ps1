param()

$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$moduleRoot = Split-Path -Parent $scriptDir
$logsDir = Join-Path $moduleRoot 'logs'
$launcherLog = Join-Path $logsDir 'launcher.log'

New-Item -ItemType Directory -Force -Path $logsDir | Out-Null

function Write-LauncherLog {
  param([string]$Message)
  Add-Content -Path $launcherLog -Value "$(Get-Date -Format o) $Message"
}

function Stop-MatchingProcess {
  param(
    [string]$Pattern,
    [string]$Label
  )

  $matches = Get-CimInstance Win32_Process |
    Where-Object { $_.CommandLine -match $Pattern }

  if (-not $matches) {
    Write-LauncherLog "$Label not running."
    return
  }

  foreach ($match in $matches) {
    try {
      Stop-Process -Id $match.ProcessId -Force
      Write-LauncherLog "$Label stopped (PID $($match.ProcessId))."
    } catch {
      Write-LauncherLog "Failed to stop $Label (PID $($match.ProcessId)): $($_.Exception.Message)"
    }
  }
}

Write-LauncherLog 'Stop launcher starting.'
Stop-MatchingProcess -Pattern 'mock_dashboard_api\.py' -Label 'Mock dashboard'
Stop-MatchingProcess -Pattern 'src\.voice_gateway\.app' -Label 'Voice gateway'
Write-LauncherLog 'Stop launcher finished.'
