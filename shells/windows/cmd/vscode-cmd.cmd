:: vscode-cmd.cmd - Launch VS Code with the full native Windows tool stack layered onto the session.
@echo off
setlocal

rem --- Load your global baseline environment ---
call "%~dp0env\requires.cmd" global win git-cli miktex sagemath vscode msys2-tools
if %errorlevel% neq 0 (
    echo Error: %errorlevel% - required dependencies not found. Please ensure that you have the necessary tools installed.
    exit /b 1
)
rem --- No MSYS2 paths added here ---
rem --- This is a pure Windows environment ---
rem --- Isolate this flavor: shares the full-native 'ps' profile ---
set "WCDE_VSCODE_PROFILE=ps"
call "%~dp0..\tools\vscode-isolation.cmd" "%~1"
rem --- Launch native Windows VS Code ---
call "%WCDE_VSCODE_EXE_PATH%" %WCDE_VSCODE_DEV_SHELL_ARGS% %*
set EXITCODE=%ERRORLEVEL%

endlocal & exit /b %EXITCODE%

