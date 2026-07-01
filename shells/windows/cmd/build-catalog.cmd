:: build-catalog.cmd - Regenerate catalog.md from the current .cmd and .sh inventory.
@echo off
setlocal
call "%~dp0env\requires.cmd" global win-dev
if %errorlevel% neq 0 (
    echo Error: %errorlevel% - required dependencies not found. Please ensure that you have the necessary tools installed.
    exit /b 1
)
python "%~dp0..\..\..\tools\generate_catalog.py"
set "BUILD_CATALOG_RC=%ERRORLEVEL%"

endlocal & exit /b %BUILD_CATALOG_RC%