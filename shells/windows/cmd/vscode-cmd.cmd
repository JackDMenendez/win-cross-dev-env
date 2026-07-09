:: vscode-cmd.cmd - Launch VS Code with the full native Windows tool stack layered onto the session.
@echo off
setlocal
call "%~dp0env\requires.cmd" global win git-cli miktex sagemath vscode msys2-tools
if %errorlevel% neq 0 exit /b 1
set "WCDE_VSCODE_PROFILE=ps"
call "%~dp0..\tools\vscode-isolation.cmd" "%~1"
call "%WCDE_VSCODE_EXE_PATH%" %WCDE_VSCODE_DEV_SHELL_ARGS% %*
endlocal & exit /b %ERRORLEVEL%

