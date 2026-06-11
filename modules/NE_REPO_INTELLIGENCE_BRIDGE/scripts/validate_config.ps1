param([string]$Profile = "")
. "$PSScriptRoot\common.ps1"
$config = Get-BridgeConfig -Profile $Profile
$required = @("project_name","repo_root","obsidian_vault_path","obsidian_project_folder","dashboard_export_path")
foreach ($key in $required) {
    if (-not $config.$key) { throw "Missing required config key: $key" }
}
Write-Host "Config valid for project: $($config.project_name)"
Write-Host "Obsidian vault: $($config.obsidian_vault_path)"
Write-Host "Obsidian folder: $($config.obsidian_project_folder)"
Write-Host "Dashboard export path: $($config.dashboard_export_path)"
