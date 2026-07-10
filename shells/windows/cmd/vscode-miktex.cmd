:: vscode-miktex.cmd - Launch VS Code with MiKTeX added to the Windows tool stack.
@echo off
setlocal enabledelayedexpansion
call "%~dp0lib\vscode-launcher-lib.cmd" "%~1"
if %errorlevel% neq 0 goto COMPLETE
rem --- Load the baseline environment ---
call "%~dp0env\requires.cmd" global win-dev miktex vsvim nvim vscode
if %errorlevel% neq 0 exit /b 1
set "WCDE_VSCODE_PROFILE=tex"
call "%~dp0..\tools\vscode-isolation.cmd" "!TARGET!"
call "%~dp0..\tools\setup-vscode.cmd" %*
call "%WCDE_VSCODE_EXE_PATH%" %WCDE_VSCODE_DEV_SHELL_ARGS% %*
:COMPLETE
endlocal & exit /b %ERRORLEVEL%
