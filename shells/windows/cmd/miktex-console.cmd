@echo off
setlocal

call "%~dp0env/global-env.cmd"
call "%~dp0env\miktex-env.cmd"

miktex-console %*
set EXITCODE=%ERRORLEVEL%

endlocal & exit /b %EXITCODE%

