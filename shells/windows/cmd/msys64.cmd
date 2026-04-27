:: msys.cmd - Launch MSYS2 shell
@echo off
setlocal
call "%~dp0env\msys64-env.cmd"
C:\msys64\msys2_shell.cmd -defterm -no-start -here -msys
set EXITCODE=%ERRORLEVEL%
endlocal & exit /b %EXITCODE%