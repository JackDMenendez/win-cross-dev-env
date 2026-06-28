:: win-choco-env.cmd - Layer Chocolatey-oriented tooling onto the Windows dev environment.
@echo off
rem Basic Windows CLI Env Setup
if not "%SHELL_CHOCO_ENV%0"=="0" exit /b 0

set SHELL_CHOCO_ENV=1

call "%~dp0win-dev-env.cmd"
call "%~dp0ghcup-env.cmd"

rem --- Windows Shell Basic Working PATH ---
set PATH=%PATH%;%CHOCOLATEY_PATH%\bin
rem --- C:\tools\gnu\bin (old GNU tools) removed; use MSYS2 for coreutils/make. ---
set PATH=%PATH%;%DEV_SHELL_WIN_PATH%\cmd
set PATH=%PATH%;%DEV_SHELL_WIN_PATH%\lib

rem --- Return to caller ---
exit /b 0
