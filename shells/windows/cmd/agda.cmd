:: agda.cmd - Launch Agda in interactive mode.
@echo off
setlocal

call "%~dp0env\agda-env.cmd"

agda -i %*

set EXITCODE=%ERRORLEVEL%
endlocal & exit /b %EXITCODE%
