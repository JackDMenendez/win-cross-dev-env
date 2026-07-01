:: miktex-console.cmd - Launch the MiKTeX console with the repo baseline Windows environment loaded.
@echo off
setlocal
call "%~dp0env\requires.cmd" global miktex
if %errorlevel% neq 0 (
    echo Error: %errorlevel% - required dependencies not found. Please ensure that you have the necessary tools installed.
    exit /b 1
)
miktex-console %*
set EXITCODE=%ERRORLEVEL%
endlocal & exit /b %EXITCODE%

