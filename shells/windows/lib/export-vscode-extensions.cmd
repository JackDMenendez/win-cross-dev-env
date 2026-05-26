@echo off
REM export-vscode-extensions.cmd - Export the current VS Code extension manifest to a file for reproducibility.

setlocal enabledelayedexpansion

REM Set default target repo to current directory
set "TARGET_REPO=%~1"
if "%TARGET_REPO%"=="" set "TARGET_REPO=."

REM Resolve to absolute path
for /f "tokens=*" %%A in ('cd /d "%TARGET_REPO%" ^& cd') do set "TARGET_REPO=%%A"

REM Verify the target is a directory
if not exist "%TARGET_REPO%" (
    echo Error: Target repository not found: %TARGET_REPO%
    exit /b 1
)

REM Create .vscode directory if it doesn't exist
set "VSCODE_DIR=%TARGET_REPO%\.vscode"
if not exist "%VSCODE_DIR%" mkdir "%VSCODE_DIR%"

REM Check if code command is available
where /q code
if errorlevel 1 (
    echo Error: VS Code 'code' command not found in PATH.
    echo Make sure VS Code is installed and added to your PATH.
    exit /b 1
)

REM Export extensions with versions
set "EXTENSIONS_FILE=%VSCODE_DIR%\extensions.txt"
echo Exporting VS Code extensions to %EXTENSIONS_FILE%...
code --list-extensions --show-versions > "%EXTENSIONS_FILE%"

if %errorlevel% neq 0 (
    echo Error: Failed to export extensions.
    exit /b 1
)

REM Count extensions
for /f %%A in ('find /c /v "" ^< "%EXTENSIONS_FILE%"') do set "EXTENSION_COUNT=%%A"

echo Done.
echo Exported %EXTENSION_COUNT% extensions
echo.
echo Extension list saved to: %EXTENSIONS_FILE%
echo.
echo To restore extensions from this file:
echo   for /f %%%%i in ^(type "%EXTENSIONS_FILE%"^) do code --install-extension %%%%i
echo.
echo Or commit the file for project release:
echo   git add %EXTENSIONS_FILE%
echo   git commit -m "Freeze VS Code extensions for reproducible development"

endlocal
exit /b 0
