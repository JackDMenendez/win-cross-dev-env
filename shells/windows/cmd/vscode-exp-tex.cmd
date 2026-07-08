:: vscode-exp-tex.cmd - Bring up a python environment with laytex tools
@echo off
echo Launching VS Code from the native Windows development environment (PowerShell-oriented)...
echo Parameters passed to this script: %*
rem --- Whatever happens here, stays here. We want to avoid any side effects on the caller's environment, so we use setlocal and endlocal to contain all changes within this script.

setlocal enabledelayedexpansion

Set EXITCODE=0
Set TARGET=

if "x%~1"=="x" (
    echo No target directory provided. Using current directory: %CD%
    set "TARGET=%CD%"
) else (
    set "TARGET=%~f1"
    echo param %~1 Target directory provided: %TARGET%
    if not exist !TARGET! (
        echo Error: Target directory not found: %TARGET%
        set EXITCODE=1
        goto COMPLETE
    )
)

rem --- Load your global baseline environment ---
rem     msys2-tools is last so C:\msys64\ucrt64\bin + C:\msys64\usr\bin are
rem     APPENDED to PATH (native Windows keeps precedence; ucrt64 toolchain is
rem     still reachable for gcc/make/pkg-config etc.).
call "%~dp0env\requires" global win git-cli python laytex vscode msys2-tools
if %errorlevel% neq 0 (
    echo requires returned %errorlevel%
    exit /b 1
)
rem --- Native Windows environment; ucrt64/usr bin appended via msys2-tools ---
rem --- Isolate this flavor: own user-data + extensions dir (see lib\vsprofiles) ---
rem     Own profile label (NOT python) so it gets its own isolated ext dir +
rem     exp-tex.txt manifest (python + LaTeX), not the pure-python flavor's set.
set "WCDE_VSCODE_PROFILE=exp-tex"
call "%~dp0..\tools\vscode-isolation.cmd" "%~1"
rem --- Launch native Windows VS Code ---
call "%~dp0..\tools\setup-vscode.cmd" %*
echo call "%WCDE_VSCODE_EXE_PATH%" %WCDE_VSCODE_DEV_SHELL_ARGS% %*
call "%WCDE_VSCODE_EXE_PATH%" %WCDE_VSCODE_DEV_SHELL_ARGS% %*
set EXITCODE=%ERRORLEVEL%

REM --- Return to caller with the exit code from VS Code ---
:COMPLETE
endlocal & exit /b %EXITCODE%
