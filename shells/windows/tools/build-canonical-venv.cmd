@echo off
set "CANONICAL_WIN_VENV=%USERPROFILE%\.venv-win"
set "CANONICAL_WIN_PYTHON=%CANONICAL_WIN_VENV%\Scripts\python.exe"
set "CANONICAL_PACKAGES=%USERPROFILE%\canonical-packages-win.txt"

if exist "%CANONICAL_WIN_VENV%" (
    if exist "%CANONICAL_WIN_PYTHON%" (
        echo Saving canonical packages to "%CANONICAL_PACKAGES%"
        call "%CANONICAL_WIN_PYTHON%" -m pip freeze > "%CANONICAL_PACKAGES%"
    )
    echo "Removing existing canonical venv at %CANONICAL_WIN_VENV%"
    rmdir /s /q "%CANONICAL_WIN_VENV%"
)

echo "Creating canonical venv at %CANONICAL_WIN_VENV%"

python -m venv "%CANONICAL_WIN_VENV%"
call "%CANONICAL_WIN_PYTHON%" -m pip install --upgrade pip

if exist "%CANONICAL_PACKAGES%" (
    echo Restoring canonical packages from "%CANONICAL_PACKAGES%"
    call "%CANONICAL_WIN_PYTHON%" -m pip install -r "%CANONICAL_PACKAGES%"
)

