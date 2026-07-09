:: vscode-haskell.cmd - Launch VS Code from a Haskell (GHCup) development environment.
@echo off
setlocal enabledelayedexpansion
call "%~dp0lib\vscode-launcher-lib.cmd" "%~1"
if %errorlevel% neq 0 goto COMPLETE
rem --- Load your global baseline environment ---
call "%~dp0env\requires" global win git-cli haskell vscode
if %errorlevel% neq 0 exit /b 1
rem --- No MSYS2 paths added here ---
rem --- This is a pure Windows environment ---
set "WCDE_VSCODE_PROFILE=haskell"
call "%~dp0..\tools\vscode-isolation.cmd" "!TARGET!"
call "%~dp0..\tools\setup-vscode.cmd" %*
call "%WCDE_VSCODE_EXE_PATH%" %WCDE_VSCODE_DEV_SHELL_ARGS% %*
:COMPLETE
endlocal & exit /b %EXITCODE%

