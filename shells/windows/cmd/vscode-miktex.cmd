:: vscode-miktex.cmd - Launch VS Code with MiKTeX added to the Windows tool stack.
@echo off
setlocal
call "%~dp0env\requires.cmd" global win-dev miktex vscode
if %errorlevel% neq 0 exit /b 1
set "WCDE_VSCODE_PROFILE=tex"
call "%~dp0..\tools\vscode-isolation.cmd" "%~1"
call "%WCDE_VSCODE_EXE_PATH%" %WCDE_VSCODE_DEV_SHELL_ARGS% %*
endlocal & exit /b %ERRORLEVEL%