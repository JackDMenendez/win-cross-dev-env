@echo off
setlocal

call "%~dp0env\global-env.cmd"

set MSYSTEM=MINGW64
set CHERE_INVOKING=1
set PATH=C:\msys64\mingw64\bin;%PATH%

call nvim %*
set EXITCODE=%ERRORLEVEL%

endlocal & exit /b %EXITCODE%

