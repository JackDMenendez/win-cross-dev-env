:: vscode-agda.cmd - Launch VS Code with Agda and Haskell toolchain available.
@echo off
setlocal
call "%~dp0env\requires.cmd" global win ghcup agda vscode
if %errorlevel% neq 0 exit /b 1
set "WCDE_VSCODE_PROFILE=agda"
call "%~dp0..\tools\vscode-isolation.cmd" "%~1"
call "%WCDE_VSCODE_EXE_PATH%" %WCDE_VSCODE_DEV_SHELL_ARGS% %*
endlocal & exit /b %EXITCODE%
