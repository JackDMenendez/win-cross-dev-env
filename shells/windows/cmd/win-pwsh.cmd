:: win-pwsh.cmd - Launch PowerShell with the repo environment configured.
@echo off
setlocal

call "%~dp0env\pwsh-env.cmd"

%WCDE_POWERSHELL_COMMAND_PATH% %*

set EXITCODE=%ERRORLEVEL%
endlocal & exit /b %EXITCODE%
