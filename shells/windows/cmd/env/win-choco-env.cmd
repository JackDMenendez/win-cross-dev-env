@echo off
rem Basic Windows CLI Env Setup
if not "%SHELL_CHOCO_ENV%0"=="0" exit /b 0

set SHELL_CHOCO_ENV=1

call "%~dp0win-dev-env.cmd"

rem --- Windows Shell Basic Working PATH ---
set "PATH=%PATH%;%CHOCOLATEY_PATH%\bin"
set "PATH=%PATH%;%~dp0..\..\lib\choco"

rem --- Return to caller ---
exit /b 0
