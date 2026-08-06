Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$moduleRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $moduleRoot

if (-not (Test-Path "$moduleRoot\.venv\Scripts\python.exe")) {
  python -m venv .venv
}

$pythonExe = Join-Path $moduleRoot '.venv\Scripts\python.exe'
if (-not (Test-Path $pythonExe)) {
  throw 'Could not find a Python executable in .venv.'
}

if (-not $env:GAIA_USB_ROOT) {
  $preferredUsbRoot = 'F:\\GAIA_USB'
  $fallbackUsbRoot = 'F:\\'
  if (Test-Path $preferredUsbRoot) {
    $env:GAIA_USB_ROOT = $preferredUsbRoot
  }
  elseif (Test-Path $fallbackUsbRoot) {
    $env:GAIA_USB_ROOT = $fallbackUsbRoot
  }
  else {
    $env:GAIA_USB_ROOT = Join-Path $moduleRoot '.gaia_usb'
  }
}

Write-Host "Starting GAIA bridge server with GAIA_USB_ROOT=$env:GAIA_USB_ROOT"
& $pythonExe gaia_bridge_server.py
