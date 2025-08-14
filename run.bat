@echo off
cd /d "%~dp0" || exit /b 1
set "RESTART_CODE=42"

:loop

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "& 'C:\Program Files\Git\usr\bin\winpty.exe' bash -lc 'exec ./love.exe --console .; exit $?'; exit $LASTEXITCODE"
set "code=%ERRORLEVEL%"

if "%code%"=="%RESTART_CODE%" (
  echo Restart requested (exit %code%). Relaunching...
  timeout /t 1 >nul
  goto loop
) else (
  echo Exiting (code %code%).
  exit /b %code%
)
