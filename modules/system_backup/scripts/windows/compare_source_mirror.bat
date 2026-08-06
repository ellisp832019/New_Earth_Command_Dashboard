@echo off
setlocal
set "MODULE_ROOT=%~dp0..\.."
set "SCRIPT_PATH=%MODULE_ROOT%\scripts\windows\compare_source_mirror.ps1"

echo ==========================================
echo New Earth Backup Guardian - COMPARE SOURCE
echo ==========================================

powershell -ExecutionPolicy Bypass -File "%SCRIPT_PATH%"

if errorlevel 1 (
  echo Compare finished with differences.
) else (
  echo Compare complete. No differences found.
)

pause
