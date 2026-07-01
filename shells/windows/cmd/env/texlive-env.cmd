:: texlive-env.cmd - Prepend TeX Live binaries to PATH.
@echo off
if not "%SHELL_TEXLIVE_ENV%0"=="0" exit /b 0
set SHELL_TEXLIVE_ENV=1
call "%~dp0requires.cmd" global
if %errorlevel% neq 0 exit /b %errorlevel%
echo ------------ texlive
rem --- isolate tool chain contaminator ---
set PATH=%path%;C:\texlive\2026\bin\windows
rem --- Global variables shared by all environments ---

rem --- Return to caller ---
exit /b 0

