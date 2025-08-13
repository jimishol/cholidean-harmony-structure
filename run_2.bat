@echo off
setlocal

set "RESTART_CODE=42"
set "GIT_BASH=%ProgramFiles%\Git\bin\bash.exe"

if not exist "%GIT_BASH%" set "GIT_BASH=%ProgramFiles(x86)%\Git\bin\bash.exe"
if not exist "%GIT_BASH%" set "GIT_BASH=bash.exe"

rem Use dropped folder or the batch’s folder
if "%~1"=="" ( set "TARGET=%~dp0" ) else ( set "TARGET=%~1" )
for %%A in ("%TARGET:\=/%") do set "UNIX_TARGET=%%~A"

:LOOP
"%GIT_BASH%" -i -c "cd '%UNIX_TARGET%' && love --console ."
set "code=%ERRORLEVEL%"

if "%code%"=="%RESTART_CODE%" (
  echo Restarting (exit %code%)...
  timeout /t 1 >nul
  goto LOOP
)

exit /b %code%
