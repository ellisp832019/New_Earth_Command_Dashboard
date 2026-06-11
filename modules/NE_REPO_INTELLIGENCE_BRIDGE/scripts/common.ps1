function Get-BridgeConfig {
    param([string]$Profile)
    if (-not $Profile) { $Profile = Join-Path $PSScriptRoot "..\obsidian_sync_config.json" }
    if (-not (Test-Path $Profile)) { throw "Profile/config not found: $Profile" }
    return Get-Content $Profile -Raw | ConvertFrom-Json
}

function Resolve-RepoRoot {
    param($Config, [string]$Profile)
    $repo = $Config.repo_root
    if ($repo -eq "." -or [string]::IsNullOrWhiteSpace($repo)) {
        return (Resolve-Path (Join-Path (Split-Path $Profile -Parent) "..")).Path
    }
    return (Resolve-Path $repo).Path
}

function Ensure-Folder {
    param([string]$Path)
    if (-not (Test-Path $Path)) { New-Item -ItemType Directory -Path $Path -Force | Out-Null }
}

function Write-LogLine {
    param([string]$Message)
    $logDir = Join-Path $PSScriptRoot "..\logs"
    Ensure-Folder $logDir
    $log = Join-Path $logDir "sync.log"
    $line = "$(Get-Date -Format s) $Message"
    Add-Content -Path $log -Value $line
    Write-Host $line
}

function ConvertTo-ForwardSlashPath {
    param([string]$Path)
    return $Path -replace "\\", "/"
}

function Get-TextFiles {
    param($RepoRoot, $Ignore)
    $files = Get-ChildItem -Path $RepoRoot -Recurse -File -ErrorAction SilentlyContinue | Where-Object {
        $p = $_.FullName
        $ignored = $false
        foreach ($i in $Ignore) {
            if ($p -like "*$i*") { $ignored = $true; break }
        }
        -not $ignored -and $_.Length -lt 2MB
    }
    return $files
}

function Get-GeneratedSection {
    param([string]$Existing, [string]$Generated)
    $start = "<!-- AUTO-GENERATED:START -->"
    $end = "<!-- AUTO-GENERATED:END -->"
    if ($Existing -match [regex]::Escape($start)) {
        $pattern = "(?s)" + [regex]::Escape($start) + ".*?" + [regex]::Escape($end)
        return [regex]::Replace($Existing, $pattern, "$start`n$Generated`n$end")
    }
    return $Existing + "`n`n$start`n$Generated`n$end`n"
}
