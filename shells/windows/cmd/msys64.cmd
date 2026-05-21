:: msys64.cmd - Launch the MSYS2 MSYS shell with the repo startup wrapper loaded.
@echo off
setlocal
call "%~dp0env\msys64-env.cmd" 
C:\msys64\msys2_shell.cmd -defterm -no-start -here -msys %*
set EXITCODE=%ERRORLEVEL%
endlocal & exit /b %EXITCODE%