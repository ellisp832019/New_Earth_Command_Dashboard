param([string]$Profile = "", [int]$DebounceSeconds = 5)
. "$PSScriptRoot\common.ps1"
$profilePath = if ($Profile) { $Profile } else { Join-Path $PSScriptRoot "..\profiles\template.json" }
$config = Get-BridgeConfig -Profile $profilePath
$repoRoot = Resolve-RepoRoot -Config $config -Profile $profilePath
Write-Host "Watching repo: $repoRoot"
Write-Host "Profile: $profilePath"
Write-Host "Press Ctrl+C to stop."
$fsw = New-Object IO.FileSystemWatcher $repoRoot -Property @{ IncludeSubdirectories=$true; EnableRaisingEvents=$true }
$last = Get-Date "2000-01-01"
$action = {
    $now = Get-Date
    if (($now - $script:last).TotalSeconds -ge $DebounceSeconds) {
        $script:last = $now
        & "$PSScriptRoot\sync_all.ps1" -Profile $Profile
    }
}
Register-ObjectEvent $fsw Changed -Action $action | Out-Null
Register-ObjectEvent $fsw Created -Action $action | Out-Null
Register-ObjectEvent $fsw Renamed -Action $action | Out-Null
while ($true) { Start-Sleep -Seconds 2 }
