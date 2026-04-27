@echo off
setlocal

call "%~dp0env\global-env.cmd"
call "%~dp0env\sagemath-env.cmd"

rem --- Launch VS Code or Sage shell ---
sage -sh
set EXITCODE=%ERRORLEVEL%

endlocal & exit /b %EXITCODE%

