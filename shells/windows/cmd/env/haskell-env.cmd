:: haskell-env.cmd - Set up Haskell toolchain environment.
@echo off
if not "%SHELL_HASKELL_ENV%0"=="0" exit /b 0
set SHELL_HASKELL_ENV=1
call "%~dp0requires.cmd" global ghcup
if %errorlevel% neq 0 exit /b %errorlevel%
echo ------------ haskell
rem --- return to caller ---
exit /b 0
