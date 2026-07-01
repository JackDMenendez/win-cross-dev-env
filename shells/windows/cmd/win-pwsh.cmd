:: win-pwsh.cmd - Launch PowerShell with the repo environment configured.
@echo off
setlocal

call "%~dp0env\requires.cmd" global pwsh
if %errorlevel% neq 0 (
    echo Error: %errorlevel% - required dependencies not found. Please ensure that you have the necessary tools installed.
    exit /b 1
)

%WCDE_POWERSHELL_COMMAND_PATH% %*

set EXITCODE=%ERRORLEVEL%
endlocal & exit /b %EXITCODE%
