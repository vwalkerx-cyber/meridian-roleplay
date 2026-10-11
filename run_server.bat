@echo off
setlocal enabledelayedexpansion
title Meridian Roleplay - Server Launcher

echo ===================================================
echo       MERIDIAN ROLEPLAY - FXSERVER LAUNCHER
echo          "Every Choice Shapes the State"
echo ===================================================
echo.

:: Detect FXServer Binary Location
set "SERVER_BIN="

if exist "%~dp0..\FXServer\FXServer.exe" (
    set "SERVER_BIN=%~dp0..\FXServer\FXServer.exe"
) else if exist "%~dp0..\fxserver\FXServer.exe" (
    set "SERVER_BIN=%~dp0..\fxserver\FXServer.exe"
) else if exist "C:\FXServer\server\FXServer.exe" (
    set "SERVER_BIN=C:\FXServer\server\FXServer.exe"
) else if exist "C:\fxserver\FXServer.exe" (
    set "SERVER_BIN=C:\fxserver\FXServer.exe"
) else if exist "%~dp0fxserver\FXServer.exe" (
    set "SERVER_BIN=%~dp0fxserver\FXServer.exe"
)

if "%SERVER_BIN%"=="" (
    echo [ERROR] Could not find FXServer.exe!
    echo.
    echo Please make sure you have extracted the FiveM Windows Server Artifacts.
    pause
    exit /b 1
)

:: Get directory containing FXServer.exe for citizen_dir
for %%I in ("%SERVER_BIN%") do set "FX_DIR=%%~dpI"

echo [OK] Located FXServer binary: %SERVER_BIN%
echo [INFO] FXServer Engine Directory: %FX_DIR%
echo [INFO] Server Data Directory: %~dp0
echo.
echo Starting Meridian Roleplay Server...
echo.

:: Run FXServer with working directory set to this project folder
cd /d "%~dp0"
"%SERVER_BIN%" +set citizen_dir "%FX_DIR%citizen" +exec "%~dp0server.cfg"

pause
