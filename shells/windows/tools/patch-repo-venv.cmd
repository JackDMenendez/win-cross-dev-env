:: patch-repo-venv.cmd - Install baseline repo tooling into an existing repo-local Windows Python virtual environment.
@echo off
setlocal

if /i "%~1"=="-h" goto :show_help
if /i "%~1"=="--help" goto :show_help
if not "%~2"=="" goto :show_help_error

set "REPO_DIR=%CD%"
if not "%~1"=="" set "REPO_DIR=%~f1"
if not exist "%REPO_DIR%" (
    echo Repository directory not found: %REPO_DIR%
    exit /b 1
)

if /i "%MSYSTEM%"=="WIN64" (
    set "VENV_SUFFIX=win"
) else (
    echo Unsupported MSYSTEM for repo venv patch: %MSYSTEM%
    exit /b 1
)

if exist "%REPO_DIR%\.venv-%VENV_SUFFIX%" (
    set "TARGET_VENV=%REPO_DIR%\.venv-%VENV_SUFFIX%"
) else if exist "%REPO_DIR%\.venv" (
    set "TARGET_VENV=%REPO_DIR%\.venv"
) else (
    echo Repository venv not found in %REPO_DIR%
    exit /b 1
)

set "TARGET_PYTHON=%TARGET_VENV%\Scripts\python.exe"
if not exist "%TARGET_PYTHON%" (
    echo Python interpreter not found in %TARGET_VENV%
    exit /b 1
)

echo Installing baseline repo tooling into "%TARGET_VENV%"
"%TARGET_PYTHON%" -m pip install isort
if errorlevel 1 exit /b 1

exit /b 0

:show_help
echo Usage: %~nx0 [-h^|--help] [repo-dir]
echo Installs baseline repo tooling into an existing repo-local Python virtual environment.
echo It does not rebuild the venv.
echo.
echo Arguments:
echo   repo-dir  Optional repository directory. Defaults to the current directory.
echo.
echo Environment Variables Used:
echo   MSYSTEM  - Determines the target subsystem ^(WIN64^)
exit /b 0

:show_help_error
call :show_help
exit /b 1