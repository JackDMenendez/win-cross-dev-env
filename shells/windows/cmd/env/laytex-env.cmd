:: laytex-env.cmd - Prepend MiKTeX (LaTeX) binaries to PATH.
@echo off

if not "%SHELL_LAYTEX_ENV%0"=="0" exit /b 0
set SHELL_LAYTEX_ENV=1
call "%~dp0requires.cmd" global
if %errorlevel% neq 0 exit /b %errorlevel%
echo ------------ laytex
set "PATH=C:\Program Files\MiKTeX\miktex\bin\x64;%PATH%"

exit /b 0
