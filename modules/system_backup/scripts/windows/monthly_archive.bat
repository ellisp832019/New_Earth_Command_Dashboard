@echo off
setlocal
set "MODULE_ROOT=%~dp0..\.."
set "SCRIPT_PATH=%MODULE_ROOT%\scripts\windows\new_earth_backup_guardian.ps1"

echo ==========================================
echo New Earth Backup Guardian - MONTHLY ARCHIVE
echo ==========================================

powershell -ExecutionPolicy Bypass -File "%SCRIPT_PATH%" -Mode MonthlyArchive

if errorlevel 1 (
  echo Monthly archive finished with errors.
) else (
  echo Monthly archive complete.
)

pause
