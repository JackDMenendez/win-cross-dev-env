:: vscode-ghcup.cmd - Launch VS Code with GHCup and Haskell toolchain available.
@echo off
setlocal
call "%~dp0env\requires.cmd" global win ghcup vscode
if %errorlevel% neq 0 (
    echo Error: %errorlevel% - required dependencies not found. Please ensure that you have the necessary tools installed.
    exit /b 1
)

set "WCDE_VSCODE_PROFILE=haskell"
call "%~dp0..\tools\vscode-isolation.cmd" "%~1"
call "%WCDE_VSCODE_EXE_PATH%" %WCDE_VSCODE_DEV_SHELL_ARGS% %*
set EXITCODE=%ERRORLEVEL%

endlocal & exit /b %EXITCODE%
