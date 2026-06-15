param([string]$Profile = "")
. "$PSScriptRoot\common.ps1"
$config = Get-BridgeConfig -Profile $Profile
$dest = Join-Path $config.obsidian_vault_path $config.obsidian_project_folder
Ensure-Folder $dest
Write-Host "Syncing Obsidian notes to: $dest"
$generatedAt = Get-Date -Format s
$templates = Join-Path $PSScriptRoot "..\templates"
$count = 0
foreach ($template in Get-ChildItem $templates -Filter "*.md") {
    $target = Join-Path $dest $template.Name
    $content = Get-Content $template.FullName -Raw
    $content = $content.Replace("{{project_name}}", $config.project_name).Replace("{{generated_at}}", $generatedAt)
    $generated = "Project: $($config.project_name)`nType: $($config.project_type)`nGenerated: $generatedAt`nSource of truth: $($config.source_of_truth)"
    if (Test-Path $target) {
        $existing = Get-Content $target -Raw
        $updated = Get-GeneratedSection -Existing $existing -Generated $generated
        Set-Content -Path $target -Value $updated -Encoding UTF8
        Write-LogLine "Updated Obsidian generated section: $target"
    } else {
        $content = Get-GeneratedSection -Existing $content -Generated $generated
        Set-Content -Path $target -Value $content -Encoding UTF8
        Write-LogLine "Created Obsidian note: $target"
    }
    $count++
}
Write-Host "Obsidian sync complete. Notes processed: $count"
