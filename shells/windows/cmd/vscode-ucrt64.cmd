:: vscode-ucrt64.cmd - Launch VS Code from a UCRT64-oriented shell session.
@echo off
setlocal
call "%~dp0env\requires.cmd" global ucrt64 vscode
set "WCDE_VSCODE_PROFILE=ucrt64"
call "%~dp0..\tools\vscode-isolation.cmd" "%~1"
call "%WCDE_VSCODE_EXE_PATH%" %WCDE_VSCODE_DEV_SHELL_ARGS% %*
endlocal & exit /b %ERRORLEVEL%