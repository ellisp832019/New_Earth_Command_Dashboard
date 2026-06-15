param([string]$Profile = "")
if (-not $Profile) {
    $Profile = Join-Path $PSScriptRoot "..\profiles\template.json"
    Write-Host "No profile supplied. Using template profile: $Profile"
}
Write-Host "=== Repo Intelligence Bridge full sync ==="
Write-Host "Profile: $Profile"
Write-Host "[1/3] Validating config..."
& "$PSScriptRoot\validate_config.ps1" -Profile $Profile
Write-Host "[2/3] Syncing Obsidian..."
& "$PSScriptRoot\sync_to_obsidian.ps1" -Profile $Profile
Write-Host "[3/3] Syncing dashboard exports..."
& "$PSScriptRoot\sync_to_dashboard.ps1" -Profile $Profile
Write-Host "Full sync complete."
