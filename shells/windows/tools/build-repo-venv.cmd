@echo off
setlocal

call "%~dp0..\cmd\env\global-var.cmd"

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
    echo Unsupported MSYSTEM for repo venv build: %MSYSTEM%
    exit /b 1
)

if exist "%REPO_DIR%\.venv-%VENV_SUFFIX%" (
    set "TARGET_VENV=%REPO_DIR%\.venv-%VENV_SUFFIX%"
) else if exist "%REPO_DIR%\.venv" (
    set "TARGET_VENV=%REPO_DIR%\.venv"
) else (
    set "TARGET_VENV=%REPO_DIR%\.venv-%VENV_SUFFIX%"
)

set "TARGET_PYTHON=%TARGET_VENV%\Scripts\python.exe"
set "REQUIREMENTS_SNAPSHOT=%TEMP%\dev-shell-repo-venv-%RANDOM%-%RANDOM%.txt"

if exist "%TARGET_VENV%" (
    if exist "%TARGET_PYTHON%" (
        echo Saving repo packages to "%REQUIREMENTS_SNAPSHOT%"
        "%TARGET_PYTHON%" -m pip freeze --local > "%REQUIREMENTS_SNAPSHOT%"
        if errorlevel 1 exit /b 1
    )

    echo Removing existing repo venv at "%TARGET_VENV%"
    rmdir /s /q "%TARGET_VENV%"
    if exist "%TARGET_VENV%" exit /b 1
)

if exist "%CANONICAL_WIN_PYTHON%" (
    set "BUILD_PYTHON=%CANONICAL_WIN_PYTHON%"
) else (
    set "BUILD_PYTHON=python"
)

echo Creating repo venv at "%TARGET_VENV%"
"%BUILD_PYTHON%" -m venv "%TARGET_VENV%"
if errorlevel 1 goto :cleanup_error

"%TARGET_PYTHON%" -m pip install --upgrade pip
if errorlevel 1 goto :cleanup_error

if exist "%REQUIREMENTS_SNAPSHOT%" (
    for %%I in ("%REQUIREMENTS_SNAPSHOT%") do if %%~zI gtr 0 (
        echo Restoring repo packages from saved snapshot
        "%TARGET_PYTHON%" -m pip install -r "%REQUIREMENTS_SNAPSHOT%"
        if errorlevel 1 goto :cleanup_error
    ) else (
        del "%REQUIREMENTS_SNAPSHOT%" >nul 2>&1
    )
)

if not exist "%REQUIREMENTS_SNAPSHOT%" if exist "%REPO_DIR%\virtual-env-requirements.txt" (
    echo Installing requirements from "%REPO_DIR%\virtual-env-requirements.txt"
    "%TARGET_PYTHON%" -m pip install -r "%REPO_DIR%\virtual-env-requirements.txt"
    if errorlevel 1 goto :cleanup_error
)

del "%REQUIREMENTS_SNAPSHOT%" >nul 2>&1
exit /b 0

:cleanup_error
del "%REQUIREMENTS_SNAPSHOT%" >nul 2>&1
exit /b 1

:show_help
echo Usage: %~nx0 [-h^|--help] [repo-dir]
echo Rebuilds a repo-local Python virtual environment for the current MSYSTEM.
echo It preserves packages already installed in the venv when one exists,
echo creates a fresh venv, upgrades pip, and restores the saved package set.
echo If no repo venv exists yet, it creates the preferred repo-local venv and
echo installs virtual-env-requirements.txt when present.
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
