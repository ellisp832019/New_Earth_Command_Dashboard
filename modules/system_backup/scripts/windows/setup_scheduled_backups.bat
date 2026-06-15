@echo off
setlocal
set "MODULE_ROOT=%~dp0..\.."
set "SCRIPT_PATH=%MODULE_ROOT%\scripts\windows\setup_scheduled_backups.ps1"

echo ==========================================
echo New Earth Backup Guardian - SETUP SCHEDULER
echo ==========================================

powershell -ExecutionPolicy Bypass -File "%SCRIPT_PATH%"

if errorlevel 1 (
  echo Scheduler setup finished with errors.
) else (
  echo Scheduler setup complete.
)

pause
