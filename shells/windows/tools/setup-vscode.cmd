@echo off
setlocal

call "%~dp0..\cmd\env\global-var.cmd"
set "PYTHON=%CANONICAL_WIN_PYTHON%"

if exist ".venv-win\Scripts\python.exe" (
    set "PYTHON=%CD%\.venv-win\Scripts\python.exe"
) else if exist ".venv\Scripts\python.exe" (
	set "PYTHON=%CD%\.venv\Scripts\python.exe"
)

set "PYTHON_JSON=%PYTHON:\=/%"

mkdir .vscode >nul 2>&1

echo {> .vscode\settings.json
echo     "python.defaultInterpreterPath": "%PYTHON_JSON%",>> .vscode\settings.json
echo     "terminal.integrated.defaultProfile.windows": "PowerShell",>> .vscode\settings.json
echo     "files.eol": "crlf">> .vscode\settings.json
echo }>> .vscode\settings.json

echo VS Code settings created for Windows-native environment
endlocal
