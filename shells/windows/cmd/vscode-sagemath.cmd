:: vscode-sagemath.cmd - Launch VS Code with SageMath available in the environment.
@echo off
setlocal
call "%~dp0env\requires.cmd" global win-dev sagemath vscode
if %errorlevel% neq 0 exit /b 1
set "WCDE_VSCODE_PROFILE=sage"
call "%~dp0..\tools\vscode-isolation.cmd" "%~1"
call "%WCDE_VSCODE_EXE_PATH%" %WCDE_VSCODE_DEV_SHELL_ARGS% %*
endlocal & exit /b %ERRORLEVEL%