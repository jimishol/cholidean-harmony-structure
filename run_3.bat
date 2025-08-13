@echo off
setlocal ENABLEEXTENSIONS

rem --- Configuration ---
set "RESTART_CODE=42"

rem --- Resolve target (project path) and collect optional args ---
if "%~1"=="" (
  set "TARGET=%~dp0"
) else (
  if exist "%~1\" (
    set "TARGET=%~1"
    shift
  ) else if exist "%~1" (
    rem If a file was dropped, use its directory
    set "TARGET=%~dp1"
    shift
  ) else (
    rem First arg isn't a path; default target is the batch's folder
    set "TARGET=%~dp0"
  )
)

for %%I in ("%TARGET%") do set "TARGET=%%~fI"

set "ARGS="
:collect_args
if "%~1"=="" goto find_love
if defined ARGS (
  set "ARGS=%ARGS% "%~1""
) else (
  set "ARGS="%~1""
)
shift
goto collect_args

rem --- Locate love.exe (portable > PATH > common installs) ---
:find_love
set "LOVE_EXE="

rem 1) Portable next to this script
if exist "%~dp0love.exe" set "LOVE_EXE=%~dp0love.exe"

rem 2) PATH
if not defined LOVE_EXE for /f "delims=" %%P in ('where love.exe 2^>nul') do (
  set "LOVE_EXE=%%P"
  goto have_love
)

rem 3) Common install locations
if not defined LOVE_EXE if exist "%ProgramFiles%\LOVE\love.exe" set "LOVE_EXE=%ProgramFiles%\LOVE\love.exe"
if not defined LOVE_EXE if exist "%ProgramFiles(x86)%\LOVE\love.exe" set "LOVE_EXE=%ProgramFiles(x86)%\LOVE\love.exe"
if not defined LOVE_EXE if exist "%LocalAppData%\Programs\love\love.exe" set "LOVE_EXE=%LocalAppData%\Programs\love\love.exe"

:have_love
if not defined LOVE_EXE (
  echo [Error] Could not find love.exe.
  echo - Add LÖVE to your PATH, or
  echo - Place love.exe next to this .bat, or
  echo - Install LÖVE to a standard location.
  exit /b 9009
)

rem --- Run loop with restart support ---
:LOOP
pushd "%TARGET%"
"%LOVE_EXE%" --console %ARGS% "%TARGET%"
set "code=%ERRORLEVEL%"
popd

if "%code%"=="%RESTART_CODE%" (
  echo Restarting (exit %code%)...
  timeout /t 1 >nul
  goto :LOOP
)

exit /b %code%
