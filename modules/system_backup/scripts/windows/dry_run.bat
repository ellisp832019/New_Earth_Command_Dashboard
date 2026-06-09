@echo off
setlocal
set "MODULE_ROOT=%~dp0..\.."
set "SCRIPT_PATH=%MODULE_ROOT%\scripts\windows\new_earth_backup_guardian.ps1"

echo ==========================================
echo New Earth Backup Guardian - DRY RUN
echo ==========================================

powershell -ExecutionPolicy Bypass -File "%SCRIPT_PATH%" -Mode DryRun

pause
