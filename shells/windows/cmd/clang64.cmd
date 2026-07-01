:: clang64.cmd - Launch the MSYS2 CLANG64 shell with the repo startup wrapper loaded.
@echo off
setlocal
call "%~dp0env\requires.cmd" global clang64
if %errorlevel% neq 0 (
    echo Error: %errorlevel% - required dependencies not found. Please ensure that you have the necessary tools installed.
    exit /b 1
)

C:\msys64\msys2_shell.cmd -defterm -no-start -here -clang64

set EXITCODE=%ERRORLEVEL%
endlocal & exit /b %EXITCODE%
