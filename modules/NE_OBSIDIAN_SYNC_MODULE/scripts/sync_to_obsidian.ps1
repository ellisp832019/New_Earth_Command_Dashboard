# NE_OBSIDIAN_SYNC_MODULE
# Sync generated project documentation into your Obsidian vault.

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$moduleRoot = Resolve-Path (Join-Path $scriptDir "..")
$configPath = Join-Path $moduleRoot "obsidian_sync_config.json"

if (!(Test-Path $configPath)) {
    throw "Config not found: $configPath"
}

$config = Get-Content $configPath -Raw | ConvertFrom-Json
$source = Join-Path $moduleRoot "exports"
$destination = Join-Path $config.obsidian_vault_path $config.obsidian_project_folder

if (!(Test-Path $source)) {
    throw "Exports folder not found: $source"
}

if (!(Test-Path $destination)) {
    New-Item -ItemType Directory -Path $destination -Force | Out-Null
}

foreach ($doc in $config.export_docs) {
    $srcFile = Join-Path $source $doc
    $dstFile = Join-Path $destination $doc

    if (Test-Path $srcFile) {
        Copy-Item $srcFile $dstFile -Force
        Write-Host "Synced $doc to $destination"
    } else {
        Write-Warning "Missing export file: $doc"
    }
}

Write-Host ""
Write-Host "Obsidian sync complete for $($config.project_name)"
Write-Host "Destination: $destination"
