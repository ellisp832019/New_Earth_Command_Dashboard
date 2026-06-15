@echo off
setlocal
set "MODULE_ROOT=%~dp0..\.."
set "SCRIPT_PATH=%MODULE_ROOT%\scripts\windows\verify_scheduled_backups.ps1"

powershell -ExecutionPolicy Bypass -File "%SCRIPT_PATH%"

if errorlevel 1 (
  echo Scheduler verification finished with errors.
) else (
  echo Scheduler verification complete.
)

pause
