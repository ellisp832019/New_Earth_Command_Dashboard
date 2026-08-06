param([string]$DashboardRoot = "D:\NEW_EARTH_DASHBOARD")
$Source = Split-Path -Parent $PSScriptRoot
$Target = Join-Path $DashboardRoot "modules\01_USERS_AND_DEVICES_CONTROL"
New-Item -ItemType Directory -Force -Path $Target | Out-Null
Copy-Item -Path "$Source\*" -Destination $Target -Recurse -Force
Write-Host "Copied to $Target"
