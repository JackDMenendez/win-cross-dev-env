:: python-activate.cmd - Internal helper that discovers the preferred Windows Python virtual environment.
@echo off
if exist "%CD%\.venv-win\Scripts\activate.bat" (
    set "WIN_DEV_ACTIVATE=%CD%\.venv-win\Scripts\activate.bat"
    set "DEV_SHELL_ACTIVE_VENV_KIND=local"
    set "DEV_SHELL_ACTIVE_VENV_PATH=%CD%\.venv-win"
) else if exist "%CD%\.venv_win64\Scripts\activate.bat" (
    set "WIN_DEV_ACTIVATE=%CD%\.venv_win64\Scripts\activate.bat"
    set "DEV_SHELL_ACTIVE_VENV_KIND=local"
    set "DEV_SHELL_ACTIVE_VENV_PATH=%CD%\.venv_win64"
) else if exist "%CD%\.venv\Scripts\activate.bat" (
    set "WIN_DEV_ACTIVATE=%CD%\.venv\Scripts\activate.bat"
    set "DEV_SHELL_ACTIVE_VENV_KIND=local"
    set "DEV_SHELL_ACTIVE_VENV_PATH=%CD%\.venv"
) else if exist "%DEV_SHELL_DEFAULT_VENV%\Scripts\activate.bat" (
    set "WIN_DEV_ACTIVATE=%DEV_SHELL_DEFAULT_VENV%\Scripts\activate.bat"
    set "DEV_SHELL_ACTIVE_VENV_KIND=default"
    set "DEV_SHELL_ACTIVE_VENV_PATH=%DEV_SHELL_DEFAULT_VENV%"
) else if exist "%CANONICAL_WIN_VENV%\Scripts\activate.bat" (
    rem --- Canonical Windows venv at %CANONICAL_WIN_VENV%, defined by
    rem     global-var.cmd. The old %USERPROFILE%\.venv default was removed
    rem     when the repos moved to the single canonical .venv-win. ---
    set "WIN_DEV_ACTIVATE=%CANONICAL_WIN_VENV%\Scripts\activate.bat"
    set "DEV_SHELL_ACTIVE_VENV_KIND=default"
    set "DEV_SHELL_ACTIVE_VENV_PATH=%CANONICAL_WIN_VENV%"
)

exit /b 0