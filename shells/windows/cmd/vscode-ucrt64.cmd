:: vscode-ucrt64.cmd - Launch VS Code from a UCRT64-oriented shell session.
@echo off
setlocal

call "%~dp0env\ucrt64-env.cmd"
call "%~dp0env\vscode-env.cmd"

call  %WCDE_VSCODE_EXE_PATH% %WCDE_VSCODE_DEV_SHELL_ARGS% %*
set EXITCODE=%ERRORLEVEL%

endlocal & exit /b %EXITCODE%