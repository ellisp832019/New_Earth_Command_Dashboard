@echo off
setlocal
set "MODULE_ROOT=%~dp0..\.."
set "SCRIPT_PATH=%MODULE_ROOT%\scripts\windows\new_earth_backup_guardian.ps1"

echo ==========================================
echo New Earth Backup Guardian - VERIFY LATEST
echo ==========================================

powershell -ExecutionPolicy Bypass -File "%SCRIPT_PATH%" -Mode VerifyLatest

if errorlevel 1 (
  echo Verify latest finished with errors.
) else (
  echo Verify latest complete.
)

pause
