param([string]$Profile = "")
. "$PSScriptRoot\common.ps1"
$profilePath = if ($Profile) { $Profile } else { Join-Path $PSScriptRoot "..\profiles\template.json" }
$config = Get-BridgeConfig -Profile $profilePath
$repoRoot = Resolve-RepoRoot -Config $config -Profile $profilePath
$dest = $config.dashboard_export_path
Ensure-Folder $dest
Write-Host "Syncing dashboard exports to: $dest"
$generatedAt = Get-Date -Format s
$files = Get-TextFiles -RepoRoot $repoRoot -Ignore $config.ignore
$readme = $files | Where-Object { $_.Name -match '^README\.md$' } | Select-Object -First 1
$docs = $files | Where-Object { $_.FullName -match '\\docs\\|/docs/' }
$todos = @()
foreach ($f in $files) {
    try {
        $lines = Select-String -Path $f.FullName -Pattern "TODO|FIXME|NEXT|RISK|DECISION" -SimpleMatch:$false -ErrorAction SilentlyContinue
        foreach ($l in $lines) {
            if ($todos.Count -lt 100) { $todos += @{ file=(ConvertTo-ForwardSlashPath $f.FullName); line=$l.LineNumber; text=$l.Line.Trim() } }
        }
    } catch {}
}
$healthScore = 50
$checks = @()
if ($readme) { $healthScore += 10; $checks += @{name="README found"; status="pass"} } else { $checks += @{name="README found"; status="warn"} }
if ($docs.Count -gt 0) { $healthScore += 10; $checks += @{name="docs folder/content found"; status="pass"} } else { $checks += @{name="docs folder/content found"; status="warn"} }
if ($todos.Count -lt 20) { $healthScore += 10 } else { $checks += @{name="many TODO/FIXME markers"; status="warn"} }
if (Test-Path (Join-Path $repoRoot ".git")) { $healthScore += 10; $checks += @{name="git repository found"; status="pass"} }
$healthScore = [Math]::Min(100,$healthScore)

$projectStatus = @{
    project=$config.project_name; type=$config.project_type; status="active"; phase="repo intelligence sync"; health=$(if($healthScore -ge 75){"green"}elseif($healthScore -ge 55){"amber"}else{"red"});
    health_score=$healthScore; current_focus="Keep Obsidian, Omega OS and Dashboard exports current"; generated_at=$generatedAt; repo_root=(ConvertTo-ForwardSlashPath $repoRoot)
}
$nextActions = @{ generated_at=$generatedAt; next_actions=@(
    @{title="Review generated Obsidian notes"; priority="high"; status="open"},
    @{title="Connect dashboard to JSON bridge folder"; priority="high"; status="open"},
    @{title="Review risks and TODO markers"; priority="medium"; status="open"}
)}
$tasks = @{ generated_at=$generatedAt; tasks=$todos }
$risks = @{ generated_at=$generatedAt; risks=@(
    @{title="Vault path moved or misconfigured"; severity="medium"; mitigation="Run validate_config.ps1 and check Omega OS paths"},
    @{title="AI overreach"; severity="high"; mitigation="Use ai_context blocked permissions and human approval gates"}
)}
$decisions = @{ generated_at=$generatedAt; decisions=@(
    @{decision="Use Omega OS as export destination"; status="accepted"},
    @{decision="Use Obsidian for human-readable Markdown and Dashboard for JSON"; status="accepted"}
)}
$timeline = @{ generated_at=$generatedAt; timeline=@(
    @{stage="Setup"; status="complete"},
    @{stage="First sync"; status="current"},
    @{stage="Dashboard integration"; status="next"},
    @{stage="Safe AI voice layer context"; status="future"}
)}
$repoHealth = @{ generated_at=$generatedAt; score=$healthScore; health=$projectStatus.health; total_scanned_files=$files.Count; todo_markers=$todos.Count; checks=$checks }
$aiContext = @{
    project_name=$config.project_name; source_of_truth=$config.source_of_truth; generated_at=$generatedAt;
    locked_rules=$config.locked_rules; safe_ai_permissions=$config.safe_ai_permissions; blocked_ai_permissions=$config.blocked_ai_permissions;
    human_approval_required=@("source-code edits","file deletion","git commits","git push","secrets access","licensing/payment changes","firmware flashing")
}
$manifest = @{ generated_at=$generatedAt; project=$config.project_name; exports=@("project_status.json","next_actions.json","tasks.json","risks.json","decisions.json","timeline.json","repo_health.json","ai_context.json") }

$map = @{"project_status.json"=$projectStatus;"next_actions.json"=$nextActions;"tasks.json"=$tasks;"risks.json"=$risks;"decisions.json"=$decisions;"timeline.json"=$timeline;"repo_health.json"=$repoHealth;"ai_context.json"=$aiContext;"sync_manifest.json"=$manifest}
foreach ($k in $map.Keys) {
    $out = Join-Path $dest $k
    $map[$k] | ConvertTo-Json -Depth 10 | Set-Content -Path $out -Encoding UTF8
    Write-LogLine "Wrote dashboard export: $out"
}
Write-Host "Dashboard export sync complete. Files written: $($map.Count)"
