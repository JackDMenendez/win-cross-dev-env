:: vscode-agda.cmd - Launch VS Code with Agda and Haskell toolchain available.
@echo off
setlocal

call "%~dp0env\agda-env.cmd"
call "%~dp0env\vscode-env.cmd"

call %WCDE_VSCODE_EXE_PATH% %WCDE_VSCODE_DEV_SHELL_ARGS% %*
set EXITCODE=%ERRORLEVEL%

endlocal & exit /b %EXITCODE%
