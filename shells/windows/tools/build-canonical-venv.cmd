@echo off
setlocal

call "%~dp0..\cmd\env\global-var.cmd"

if /i "%~1"=="-h" goto :show_help
if /i "%~1"=="--help" goto :show_help

if /i "%MSYSTEM%"=="WIN64" (
    set "VENV_SUFFIX=win"
) else (
    echo Unsupported MSYSTEM for canonical venv build: %MSYSTEM%
    exit /b 1
)

set "CANONICAL_VENV=%USERPROFILE%\.venv-%VENV_SUFFIX%"
set "CANONICAL_PYTHON=%CANONICAL_VENV%\Scripts\python.exe"
set "CANONICAL_PACKAGES=%USERPROFILE%\canonical-packages-%VENV_SUFFIX%.txt"

if exist "%CANONICAL_VENV%" (
    if exist "%CANONICAL_PYTHON%" (
        echo Saving canonical packages to "%CANONICAL_PACKAGES%"
        "%CANONICAL_PYTHON%" -m pip freeze > "%CANONICAL_PACKAGES%"
        if errorlevel 1 exit /b 1
    )

    echo Removing existing canonical venv at "%CANONICAL_VENV%"
    rmdir /s /q "%CANONICAL_VENV%"
    if exist "%CANONICAL_VENV%" exit /b 1
)

echo Creating canonical venv at "%CANONICAL_VENV%"
python -m venv "%CANONICAL_VENV%"
if errorlevel 1 exit /b 1

"%CANONICAL_PYTHON%" -m pip install --upgrade pip
if errorlevel 1 exit /b 1

if exist "%CANONICAL_PACKAGES%" (
    echo Restoring canonical packages from "%CANONICAL_PACKAGES%"
    "%CANONICAL_PYTHON%" -m pip install -r "%CANONICAL_PACKAGES%"
    if errorlevel 1 exit /b 1
)

exit /b 0

:show_help
echo Usage: %~nx0 [-h^|--help]
echo Builds or rebuilds the canonical Python virtual environment for the current MSYSTEM.
echo It saves the current pip packages if the venv exists, creates a fresh venv,
echo upgrades pip, and restores the packages from the saved requirements file.
echo.
echo Environment Variables Used:
echo   MSYSTEM  - Determines the target subsystem ^(WIN64^)
exit /b 0


