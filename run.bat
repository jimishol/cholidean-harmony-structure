@echo off
rem Relaunch LÖVE when the game exits with code 42.

setlocal
set "RESTART_CODE=42"
set "LOVE_EXE=love.exe"

rem Check for local love.exe first, then fallback to PATH
if exist "%~dp0%LOVE_EXE%" (
  set "LOVE_CMD=%~dp0%LOVE_EXE%"
) else (
  where love >nul 2>&1
  if errorlevel 1 (
    echo Error: 'love' executable not found locally or in PATH.
    exit /b 127
  )
  set "LOVE_CMD=love --console"
)

:LOOP
rem Launch the game
"%LOVE_CMD%" .
set "code=%ERRORLEVEL%"

if "%code%"=="%RESTART_CODE%" (
  echo Restart requested (exit %code%). Relaunching...
  timeout /t 1 >nul
  goto LOOP
)

echo Exiting (code %code%).
exit /b %code%
