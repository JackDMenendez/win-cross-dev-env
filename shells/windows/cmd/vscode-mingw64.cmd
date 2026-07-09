:: vscode-mingw64.cmd - Launch VS Code from a MINGW64-oriented shell.
@echo off
setlocal
call "%~dp0env\requires.cmd" global win-dev mingw64 vscode
if %errorlevel% neq 0 exit /b 1
set "WCDE_VSCODE_PROFILE=mingw64"
call "%~dp0..\tools\vscode-isolation.cmd" "%~1"
call "%WCDE_VSCODE_EXE_PATH%" %WCDE_VSCODE_DEV_SHELL_ARGS% %*
endlocal & exit /b %EXITCODE%

