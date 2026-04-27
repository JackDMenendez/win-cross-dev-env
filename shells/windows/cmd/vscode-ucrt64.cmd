@echo off
setlocal

call "%~dp0env\ucrt64-env.cmd"

rem --- Use the users home path ---
call "%USERPROFILE%\AppData\Local\Programs\Microsoft VS Code\Code.exe" %*
set EXITCODE=%ERRORLEVEL%

endlocal & exit /b %EXITCODE%

