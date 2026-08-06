param([string]$DashboardRoot = ".")
$Source = Join-Path $PSScriptRoot ".."
$Dest = Join-Path $DashboardRoot "modules\gaia_voice_assistant"
New-Item -ItemType Directory -Force -Path (Split-Path $Dest) | Out-Null
Copy-Item -Recurse -Force $Source $Dest
Write-Host "GAIA module copied to $Dest"
