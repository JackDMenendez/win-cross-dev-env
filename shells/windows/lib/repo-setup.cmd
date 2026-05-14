@echo off
setlocal
REM Usage: repo-setup.cmd <github-url> <project-dir> [--no-venv]

set URL=%1
set DIR=%2
set SKIP_VENV=%3

if "%URL%"=="" (
    echo Usage: repo-setup.cmd ^<github-url^> ^<project-dir^> [--no-venv]
    exit /b 1
)

if "%DIR%"=="" (
    echo Usage: repo-setup.cmd ^<github-url^> ^<project-dir^> [--no-venv]
    exit /b 1
)

if not "%SKIP_VENV%"=="" if /i not "%SKIP_VENV%"=="--no-venv" (
    echo Usage: repo-setup.cmd ^<github-url^> ^<project-dir^> [--no-venv]
    exit /b 1
)

call "%~dp0..\cmd\env\global-var.cmd"
if exist "%CANONICAL_WIN_PYTHON%" (
    set "PYTHON=%CANONICAL_WIN_PYTHON%"
) else (
    set "PYTHON=python"
)

echo Cloning %URL% into %DIR%
git clone %URL% %DIR%

cd %DIR%

if /i "%SKIP_VENV%"=="--no-venv" goto :write_settings

REM Create .venv-win if it doesn't exist
if not exist ".venv-win" (
    echo Creating .venv-win
    "%PYTHON%" -m venv .venv-win
)

REM Install requirements if file exists
if exist "virtual-env-requirements.txt" (
    echo Installing requirements from virtual-env-requirements.txt
    ".venv-win\Scripts\python.exe" -m pip install -r virtual-env-requirements.txt
)

REM Set PYTHON to the local venv
set "PYTHON=%CD%\.venv-win\Scripts\python.exe"

set "PYTHON_JSON=%PYTHON:\=/%"

:write_settings

mkdir .vscode >nul 2>&1

echo {> .vscode\settings.json
if /i not "%SKIP_VENV%"=="--no-venv" echo     "python.defaultInterpreterPath": "%PYTHON_JSON%",>> .vscode\settings.json
echo     "terminal.integrated.defaultProfile.windows": "PowerShell",>> .vscode\settings.json
echo     "files.eol": "crlf">> .vscode\settings.json
echo }>> .vscode\settings.json

echo Repo initialized for Windows-native environment
if /i "%SKIP_VENV%"=="--no-venv" echo Virtual environment setup skipped
echo VS Code settings created

if /i "%SKIP_VENV%"=="--no-venv" exit /b 0

REM Activate the venv in the current shell
call ".venv-win\Scripts\activate.bat"

