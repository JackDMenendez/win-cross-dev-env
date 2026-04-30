@echo off

if not "%SHELL_MIKTEX_ENV%0"=="0" exit /b 0
set SHELL_MIKTEX_ENV=1

set "PATH=C:\Program Files\MiKTeX\miktex\bin\x64;%PATH%"

exit /b 0