:: build-canonical-venv.cmd - Wrapper that rebuilds the canonical Windows Python virtual environment.
@echo off
setlocal
call "%~dp0env\requires.cmd" global win-dev
if %errorlevel% neq 0 (
    echo Error: %errorlevel% - required dependencies not found. Please ensure that you have the necessary tools installed.
    exit /b 1
)
call "%~dp0..\tools\build-canonical-venv.cmd" %*
set "BUILD_CANONICAL_RC=%ERRORLEVEL%"

endlocal & exit /b %BUILD_CANONICAL_RC%