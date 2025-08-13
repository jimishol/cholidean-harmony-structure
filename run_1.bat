@echo off
setlocal enabledelayedexpansion

rem Relaunch LÖVE when the game exits with code 42.
set "RESTART_CODE=42"
set "LOVE_EXE=love.exe"

rem ——————————————————————
rem 1) Locate Git Bash
rem ——————————————————————
set "GIT_BASH=%ProgramFiles%\Git\bin\bash.exe"
if not exist "%GIT_BASH%" set "GIT_BASH=%ProgramFiles(x86)%\Git\bin\bash.exe"
if not exist "%GIT_BASH%" set "GIT_BASH=bash.exe"

rem ——————————————————————
rem 2) Determine target folder
rem    Drag-and-drop passes the folder path as %1.
rem    If nothing’s dropped, use the batch’s own folder.
rem ——————————————————————
if "%~1"=="" (
  set "TARGET_DIR=%~dp0"
) else (
  set "TARGET_DIR=%~1"
)

:LAUNCH
rem ——————————————————————
rem 3) Invoke LÖVE inside Git Bash
rem    Uses cygpath to convert Windows paths → Unix style.
rem ——————————————————————
if exist "%~dp0%LOVE_EXE%" (
  "%GIT_BASH%" -i -c "cd \"$(cygpath -u '%TARGET_DIR%')\" && \
\"$(cygpath -u '%~dp0%LOVE_EXE%')\" --console ."
) else (
  "%GIT_BASH%" -i -c "cd \"$(cygpath -u '%TARGET_DIR%')\" && love --console ."
)

set "code=%ERRORLEVEL%"

if "%code%"=="%RESTART_CODE%" (
  echo Restart requested (exit %code%). Relaunching...
  timeout /t 1 >nul
  goto LAUNCH
)

echo Exiting (code %code%).
exit /b %code%
