@echo off
setlocal

call "%~dp0env\global-env.cmd"

set PATH=C:\msys64\ucrt64\bin;%PATH%
set MSYSTEM=UCRT64

call nvim %*
set EXITCODE=%ERRORLEVEL%

endlocal & exit /b %EXITCODE%

