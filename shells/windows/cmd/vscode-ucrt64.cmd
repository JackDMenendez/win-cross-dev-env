:: vscode-ucrt64.cmd - Launch VS Code from a UCRT64-oriented shell session.
@echo off
setlocal
call "%~dp0env\requires.cmd" global ucrt64 vscode

call  %WCDE_VSCODE_EXE_PATH% %WCDE_VSCODE_DEV_SHELL_ARGS% %*
set EXITCODE=%ERRORLEVEL%

endlocal & exit /b %EXITCODE%