@echo off
setlocal

call "%~dp0env\mingw64-env.cmd"
rem --- Additional isolated environments follow ---
call "%~dp0env\texlive-env.cmd"
call "%~dp0env\sagemath-env.cmd"
call "%~dp0env\win-perl-env.cmd"

rem --- Use the users home path ---
call "%USERPROFILE%\AppData\Local\Programs\Microsoft VS Code\Code.exe" %*
set EXITCODE=%ERRORLEVEL%

endlocal & exit /b %EXITCODE%

