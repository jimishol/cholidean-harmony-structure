@echo off
rem Relaunch LÖVE when the game exits with code 42.

set "RESTART_CODE=42"

rem Check that 'love' is on PATH
where love >nul 2>&1 || (
  echo Error: 'love' executable not found in PATH.
  exit /b 127
)

:LOOP
rem Launch the game
love .
set "code=%ERRORLEVEL%"

if "%code%"=="%RESTART_CODE%" (
  echo Restart requested (exit %code%). Relaunching...
  timeout /t 1 >nul
  goto LOOP
)

echo Exiting (code %code%).
exit /b %code%
