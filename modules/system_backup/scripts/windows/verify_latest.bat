@echo off
setlocal
cd /d "%~dp0..\.."

echo ==========================================
echo New Earth Backup Guardian - VERIFY LATEST
echo ==========================================

powershell -ExecutionPolicy Bypass -File scripts\windows\new_earth_backup_guardian.ps1 -Mode VerifyLatest

pause
