:: vscode-env.cmd - Set environment variables for launching VS Code from a UCRT64-oriented shell session.
@echo off

if not "%SHELL_VSCODE_ENV%0"=="0" exit /b 0

set SHELL_VSCODE_ENV=1

REM --- Global variables shared by all environments ---
set WCDE_VSCODE_DEV_SHELL_ARGS= --verbose
set WCDE_VSCODE_COMMAND=Code.exe
set WCDE_VSCODE_PATH=%LOCALAPPDATA%\Programs\Microsoft VS Code
set WCDE_VSCODE_EXE_PATH="%LOCALAPPDATA%\Programs\Microsoft VS Code\%WCDE_VSCODE_COMMAND%"

if not exist %WCDE_VSCODE_EXE_PATH% (
    echo Warning: %WCDE_VSCODE_EXE_PATH% not found in %WCDE_VSCODE_PATH%. VS Code features may not work as expected.
    exit /b 1
)

rem --- Return to caller ---
exit /b 0