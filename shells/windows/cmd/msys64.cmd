:: msys64.cmd - Launch the MSYS2 MSYS shell with the repo startup wrapper loaded.
@echo off
setlocal
call "%~dp0env\requires.cmd" msys64 
if %errorlevel% neq 0 (
    echo Error: %errorlevel% - required dependencies not found. Please ensure that you have the necessary tools installed.
    exit /b 1
)
C:\msys64\msys2_shell.cmd -defterm -no-start -here -msys %*
set EXITCODE=%ERRORLEVEL%
endlocal & exit /b %EXITCODE%
