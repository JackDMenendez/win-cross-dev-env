:: python-activate.cmd - Detect and set environment variables for Python virtual environments
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
) else if exist "%USERPROFILE%\.venv\Scripts\activate.bat" (
    set "WIN_DEV_ACTIVATE=%USERPROFILE%\.venv\Scripts\activate.bat"
    set "DEV_SHELL_ACTIVE_VENV_KIND=default"
    set "DEV_SHELL_ACTIVE_VENV_PATH=%USERPROFILE%\.venv"
)

exit /b 0