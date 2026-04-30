@echo off
rem Basic Windows CLI Env Setup
if not "%SHELL_PERL_ENV%0"=="0" exit /b 0

set SHELL_PERL_ENV=1

call "%~dp0win-dev-env.cmd"

rem --- Windows Shell Basic Working PATH ---
set PATH=%path%;C:\Strawberry\c\bin

rem --- Return to caller ---
exit /b 0


