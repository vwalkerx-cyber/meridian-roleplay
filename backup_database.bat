@echo off
setlocal enabledelayedexpansion
title Meridian Roleplay - Database Backup Utility

echo ===================================================
echo     MERIDIAN ROLEPLAY - DATABASE BACKUP UTILITY
echo ===================================================
echo.

set "BACKUP_DIR=%~dp0database\backups"
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

:: Format timestamp YYYYMMDD_HHMMSS
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set "TIMESTAMP=%datetime:~0,8%_%datetime:~8,6%"
set "BACKUP_FILE=%BACKUP_DIR%\meridian_rp_backup_%TIMESTAMP%.sql"

echo [INFO] Dumping database 'meridian_rp' to:
echo        %BACKUP_FILE%
echo.

if exist "C:\xampp\mysql\bin\mysqldump.exe" (
    "C:\xampp\mysql\bin\mysqldump.exe" -u root --routines --triggers --single-transaction meridian_rp > "%BACKUP_FILE%"
) else (
    mysqldump -u root --routines --triggers --single-transaction meridian_rp > "%BACKUP_FILE%"
)

if %ERRORLEVEL% EQU 0 (
    echo [SUCCESS] Backup created successfully!
) else (
    echo [ERROR] Database backup failed with exit code %ERRORLEVEL%.
)

echo.
pause
