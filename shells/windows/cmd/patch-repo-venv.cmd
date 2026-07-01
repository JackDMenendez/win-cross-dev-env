:: patch-repo-venv.cmd - Wrapper that patches a repo-local Windows Python virtual environment.
@echo off
setlocal
call "%~dp0env\requires.cmd" global win-dev
if %errorlevel% neq 0 (
    echo Error: %errorlevel% - required dependencies not found. Please ensure that you have the necessary tools installed.
    exit /b 1
)
call "%~dp0..\tools\patch-repo-venv.cmd" %*
set "PATCH_REPO_RC=%ERRORLEVEL%"

endlocal & exit /b %PATCH_REPO_RC%