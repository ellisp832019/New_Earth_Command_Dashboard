param(
  [switch]$SkipAnalyze,
  [switch]$SkipTest,
  [switch]$SkipWindowsBuild,
  [switch]$KeepRunningAppOpen,
  [string]$LogDirectory = "tmp\release_readiness"
)

$ErrorActionPreference = 'Stop'

function Invoke-Step {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Title,
    [Parameter(Mandatory = $true)]
    [scriptblock]$Action
  )

  Write-Host ""
  Write-Host "== $Title ==" -ForegroundColor Cyan
  & $Action
}

function Stop-RunningDashboard {
  $dashboardProcesses = Get-Process -Name 'new_earth_command_dashboard' -ErrorAction SilentlyContinue
  if ($null -eq $dashboardProcesses) {
    Write-Host "No running dashboard process detected." -ForegroundColor DarkGray
    return
  }

  foreach ($process in $dashboardProcesses) {
    Write-Host "Stopping running dashboard process $($process.Id) before build checks..." -ForegroundColor Yellow
    Stop-Process -Id $process.Id -Force
  }
}

function Invoke-LoggedFlutterTask {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [Parameter(Mandatory = $true)]
    [string[]]$FlutterArgs
  )

  $logBase = Join-Path $LogDirectory $Name
  $stdoutPath = "$logBase.log"
  $stderrPath = "$logBase.err"

  Write-Host "Running: flutter $($FlutterArgs -join ' ')" -ForegroundColor DarkGray
  & flutter @FlutterArgs 1> $stdoutPath 2> $stderrPath
  $exitCode = $LASTEXITCODE

  if ($exitCode -ne 0) {
    Write-Host "Command failed. Stdout: $stdoutPath" -ForegroundColor Red
    Write-Host "Command failed. Stderr: $stderrPath" -ForegroundColor Red
    exit $exitCode
  }

  Write-Host "Saved stdout to $stdoutPath" -ForegroundColor Green
  if ((Test-Path $stderrPath) -and (Get-Item $stderrPath).Length -gt 0) {
    Write-Host "Saved stderr to $stderrPath" -ForegroundColor Yellow
  }
}

New-Item -ItemType Directory -Path $LogDirectory -Force | Out-Null

Invoke-Step -Title "Release readiness setup" -Action {
  if (-not $KeepRunningAppOpen) {
    Stop-RunningDashboard
  } else {
    Write-Host "Keeping any running dashboard process alive because -KeepRunningAppOpen was set." -ForegroundColor Yellow
  }
}

if (-not $SkipAnalyze) {
  Invoke-Step -Title "Flutter analyze" -Action {
    Invoke-LoggedFlutterTask -Name "flutter_analyze" -FlutterArgs @('analyze')
  }
}

if (-not $SkipTest) {
  Invoke-Step -Title "Flutter test" -Action {
    Invoke-LoggedFlutterTask -Name "flutter_test" -FlutterArgs @('test')
  }
}

if (-not $SkipWindowsBuild) {
  Invoke-Step -Title "Flutter build windows" -Action {
    Invoke-LoggedFlutterTask -Name "flutter_build_windows" -FlutterArgs @('build', 'windows')
  }
}

Write-Host ""
Write-Host "Release readiness command set completed." -ForegroundColor Green
Write-Host "Next manual checks:" -ForegroundColor Cyan
Write-Host "1. Open the app and verify the daily loop."
Write-Host "2. Test restart persistence."
Write-Host "3. Check Inbox, Voice, and Users & Devices flows."
