param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$FlutterArgs
)

$ErrorActionPreference = 'Stop'

if (-not $FlutterArgs -or $FlutterArgs.Count -eq 0) {
  throw 'No Flutter arguments were provided.'
}

$mutexName = 'Local\NewEarthCommandDashboardFlutterTask'
$mutex = New-Object System.Threading.Mutex($false, $mutexName)
$lockAcquired = $false

try {
  if (-not $mutex.WaitOne(0)) {
    Write-Host 'Another Flutter task is already running. Please wait for it to finish.'
    exit 0
  }

  $lockAcquired = $true

  $flutter = Get-Command flutter -ErrorAction Stop
  & $flutter.Path @FlutterArgs
  exit $LASTEXITCODE
} catch {
  Write-Error $_
  exit 1
} finally {
  if ($lockAcquired) {
    try {
      $mutex.ReleaseMutex() | Out-Null
    } catch {
      # If the process is already exiting, there is nothing more to do.
    }
  }

  $mutex.Dispose()
}
