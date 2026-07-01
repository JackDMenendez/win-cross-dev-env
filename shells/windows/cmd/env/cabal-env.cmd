:: caball-env.cmd - Set up Cabal environment.
@echo off
if not "%SHELL_CABALL_ENV%0"=="0" exit /b 0
set SHELL_CABALL_ENV=1
call "%~dp0requires.cmd" global ghcup
if %errorlevel% neq 0 exit /b %errorlevel%
echo ------------ cabal
rem --- return to caller ---
exit /b 0
