@echo off
setlocal

rem --- Wipe idempotency guards to force rebuild of a pristine environment ---
set SHELL_GLOBAL_VAR=
set SHELL_WIN_ENV=
set SHELL_MSYS64_ENV=

call "%~dp0env\msys64-env.cmd"

call nvim %*
set EXITCODE=%ERRORLEVEL%

endlocal & exit /b %EXITCODE%
