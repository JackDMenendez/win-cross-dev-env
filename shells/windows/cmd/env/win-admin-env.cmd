@echo off
rem Basic Windows CLI Env Setup
if not "%SHELL_ADMIN_ENV%0"=="0" exit /b 0

set SHELL_ADMIN_ENV=1

rem --- Development Shell Path ===
set "PATH=%PATH%;%DEV_SHELL_WIN_PATH%\cmd"
set "PATH=%PATH%;%DEV_SHELL_WIN_PATH%\lib"

rem --- Return to caller ---
exit /b 0
