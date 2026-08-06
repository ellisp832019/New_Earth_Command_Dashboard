# Baseline Runtime Smoke Test

Date: 2026-08-06

## Command

```powershell
$releaseDirectory = ".\build\windows\x64\runner\Release"
$exe = Get-ChildItem $releaseDirectory -Filter "*.exe" |
  Where-Object {
    $_.Name -notmatch "flutter_windows|unins|crashpad"
  } |
  Select-Object -First 1

if (-not $exe) {
  throw "No Windows application executable was found."
}

$process = Start-Process -FilePath $exe.FullName -PassThru
Start-Sleep -Seconds 10
$process.Refresh()

if ($process.HasExited) {
  throw "Application exited during the smoke-test window with exit code $($process.ExitCode)."
}

Stop-Process -Id $process.Id
```

## Result

- Executable path: `D:\Dev\Projects\New Earth - Command Dashboard\build\windows\x64\runner\Release\new_earth_command_dashboard.exe`
- Process remained running after 10 seconds: `True`
- The process was then stopped cleanly.
- No exception dialog was observed during the smoke window.
- Manual UI verification was limited to the release window launching and remaining responsive.

## Limitation

This smoke test only proves that the release process can start and remain alive briefly. It does not prove that every screen rendered correctly or that every user workflow was exercised.
