:: repo-setup.cmd - Clone a repository, write its VS Code settings, and install
:: its requirements into the ONE canonical Windows venv (%USERPROFILE%\.venv-win).
:: No per-repo venv is created: every DCL repo shares the canonical venv (per the
:: global CLAUDE.md canonical-interpreter policy). Pass --no-venv to clone + write
:: settings only, skipping the dependency install into the canonical venv.
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

echo Cloning %URL% into %DIR%
git clone %URL% %DIR%

cd %DIR%

if /i "%SKIP_VENV%"=="--no-venv" goto :write_settings

REM --- Install into the ONE canonical venv; never create a per-repo venv. ---
if not exist "%CANONICAL_WIN_PYTHON%" (
    echo Error: canonical venv not found at %CANONICAL_WIN_VENV%.
    echo Build it first with shells\windows\cmd\build-canonical-venv.cmd, then re-run.
    exit /b 1
)

REM Install requirements if file exists
if exist "virtual-env-requirements.txt" (
    echo Installing requirements from virtual-env-requirements.txt into %CANONICAL_WIN_VENV%
    REM CuPy needs the CUDA-toolkit wheels [ctk] to actually run, and must come
    REM from binaries only -- a bare 'cupy' sdist triggers a runaway source build
    REM (the memory bomb). Install it via the known-good recipe and keep it out of
    REM the generic pip run.
    findstr /i /r /c:"^ *cupy" virtual-env-requirements.txt >nul 2>&1
    if not errorlevel 1 (
        echo Detected cupy requirement - installing cupy-cuda12x[ctk] binary-only
        "%CANONICAL_WIN_PYTHON%" -m pip install --only-binary=:all: "cupy-cuda12x[ctk]"
        findstr /i /v /r /c:"^ *cupy" virtual-env-requirements.txt > virtual-env-requirements-temp.txt
        "%CANONICAL_WIN_PYTHON%" -m pip install -r virtual-env-requirements-temp.txt
        del virtual-env-requirements-temp.txt
    ) else (
        "%CANONICAL_WIN_PYTHON%" -m pip install -r virtual-env-requirements.txt
    )
)

echo Installing baseline repo tooling
"%CANONICAL_WIN_PYTHON%" -m pip install isort

:write_settings

REM Delegate VS Code settings generation to the canonical generator so repos
REM cloned here get the same "PowerShell 7" + "Command Prompt (dev)" profiles as
REM setup-vscode.cmd (single source of truth). With no per-repo venv, it falls
REM back to the canonical venv for the interpreter path.
call "%~dp0..\tools\setup-vscode.cmd"

echo Repo initialized for Windows-native environment
if /i "%SKIP_VENV%"=="--no-venv" echo Dependency install skipped (--no-venv)
echo VS Code settings created

if /i "%SKIP_VENV%"=="--no-venv" exit /b 0

REM Activate the canonical venv in the current shell
call "%CANONICAL_WIN_SCRIPTS%\activate.bat"
