@echo off
setlocal

call "%~dp0env\global-env.cmd"
call "%~dp0env\win-dev-env.cmd"
call "%~dp0env\sagemath-env.cmd"

call "%USERPROFILE%\AppData\Local\Programs\Microsoft VS Code\Code.exe" %*
set EXITCODE=%ERRORLEVEL%

endlocal & exit /b %EXITCODE%