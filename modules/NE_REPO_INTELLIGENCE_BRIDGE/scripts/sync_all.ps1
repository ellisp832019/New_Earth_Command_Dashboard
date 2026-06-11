param([string]$Profile = "")
& "$PSScriptRoot\validate_config.ps1" -Profile $Profile
& "$PSScriptRoot\sync_to_obsidian.ps1" -Profile $Profile
& "$PSScriptRoot\sync_to_dashboard.ps1" -Profile $Profile
Write-Host "Sync complete."
