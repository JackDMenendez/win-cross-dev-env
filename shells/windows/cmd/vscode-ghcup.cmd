:: vscode-ghcup.cmd - Launch VS Code with GHCup and Haskell toolchain available.
@echo off
setlocal

call "%~dp0env\ghcup-env.cmd"
call "%~dp0env\vscode-env.cmd"

call %WCDE_VSCODE_EXE_PATH% %WCDE_VSCODE_DEV_SHELL_ARGS% %*
set EXITCODE=%ERRORLEVEL%

endlocal & exit /b %EXITCODE%
