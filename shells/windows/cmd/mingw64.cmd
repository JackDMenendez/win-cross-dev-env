:: mingw64.cmd - Launch MINGW64 shell
@echo off
setlocal

call "%~dp0env\mingw64-env.cmd"

C:\msys64\msys2_shell.cmd -defterm -no-start -here -mingw64

set EXITCODE=%ERRORLEVEL%
endlocal & exit /b %EXITCODE%