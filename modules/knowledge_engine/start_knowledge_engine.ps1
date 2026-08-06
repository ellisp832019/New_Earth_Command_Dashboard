Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$moduleRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $moduleRoot

$venvPython = Join-Path $moduleRoot '.venv\Scripts\python.exe'
if (-not (Test-Path $venvPython)) {
  python -m venv .venv
}

if (-not (Test-Path $venvPython)) {
  throw 'Could not find a local Python interpreter for the Knowledge Engine venv.'
}

& $venvPython -m pip install -r requirements.txt
& $venvPython scripts\setup_omega_folders.py

$configPath = Join-Path $moduleRoot 'config.json'
if (-not (Test-Path $configPath)) {
  $configPath = Join-Path $moduleRoot 'config.example.json'
}

$config = Get-Content $configPath -Raw | ConvertFrom-Json
$catalogueJson = Join-Path $config.library_catalogue_path 'pdf_catalogue.json'
$statsJson = Join-Path $config.library_catalogue_path 'library_stats.json'

if (-not (Test-Path $catalogueJson)) {
  & $venvPython scripts\scan_library.py
}

if (-not (Test-Path $statsJson)) {
  & $venvPython scripts\build_catalogue.py
}

& $venvPython -m uvicorn api.main:app --reload --port 8787
