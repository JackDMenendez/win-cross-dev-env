:: setup-vscode.cmd - Write .vscode/settings.json for the native Windows interpreter and terminal profile.
@echo off
setlocal
echo Setting up VS Code settings for the native Windows development environment...
call "%~dp0..\cmd\env\global-var.cmd"
echo Setting up VS for directory "%~f1" or current directory if no argument provided...
if "%~f1"=="" (
    set "TARGET=%CD%"
    echo Target directory is current directory: %TARGET%
) else (
    REM -- If an argument is provided, treat it as the target directory for the VS Code settings. Otherwise, use the current directory.
    set "TARGET=%~f1"
    echo Target directory is: %TARGET%
)
rem do we have python env?
if "%WCDE_INCLUDE_PYTHON_VENV%0" == "0" goto :setup_vscode_skip_venv
rem --- Prefer a native Windows-layout venv (Scripts\python.exe). A UCRT64/MSYS2
rem     venv uses bin\ and is intentionally ignored here. Set PYTHON in EVERY
rem     branch so the interpreter path is never left empty.
if exist "%TARGET%\.venv-win\Scripts\python.exe" (
    call "%TARGET%\.venv-win\Scripts\activate.bat"
    set "PYTHON=%TARGET%\.venv-win\Scripts\python.exe"
) else if exist "%TARGET%\.venv\Scripts\python.exe" (
    call "%TARGET%\.venv\Scripts\activate.bat"
    set "PYTHON=%TARGET%\.venv\Scripts\python.exe"
) else if exist "%CANONICAL_WIN_VENV%\Scripts\python.exe" (
    call "%CANONICAL_WIN_VENV%\Scripts\activate.bat"
    set "PYTHON=%CANONICAL_WIN_VENV%\Scripts\python.exe"
) else (
    echo Warning: No native Windows Python interpreter found for VS Code settings. Please ensure Python is installed and available in the PATH.
    set "PYTHON=python"
)

set "PYTHON_JSON=%PYTHON:\=/%"
:setup_vscode_skip_venv

rem --- Terminal profile bootstrap paths (PowerShell git+venv, cmd git) ---
rem     PowerShell dot-sources profile.ps1 -> forward slashes are fine.
rem     cmd /k calls git-cli-env.cmd -> backslashes must be doubled for JSON.
set "PS_PROFILE=%DEV_SHELL_PATH%\shells\windows\PowerShell\profile.ps1"
set "PS_PROFILE_JSON=%PS_PROFILE:\=/%"
set "GIT_CLI_ENV=%DEV_SHELL_PATH%\shells\windows\cmd\env\git-cli-env.cmd"
set "GIT_CLI_ENV_JSON=%GIT_CLI_ENV:\=\\%"
set "CMD_EXE=%SystemRoot%\System32\cmd.exe"
set "CMD_EXE_JSON=%CMD_EXE:\=\\%"

if not exist "%TARGET%\.vscode" (
    mkdir "%TARGET%\.vscode" >nul 2>&1
    if errorlevel 1 (
        echo Error: Failed to create .vscode directory at %TARGET%\.vscode
        exit /b 1
    )
    echo Created .vscode directory at %TARGET%\.vscode
)

echo {> "%TARGET%\.vscode\settings.json"
if defined WCDE_INCLUDE_PYTHON_VENV (
    echo     "python.defaultInterpreterPath": "%PYTHON_JSON%",>> "%TARGET%\.vscode\settings.json"
)
echo     "terminal.integrated.defaultProfile.windows": "PowerShell 7",>> "%TARGET%\.vscode\settings.json"
echo     "terminal.integrated.profiles.windows": {>> "%TARGET%\.vscode\settings.json"
echo         "PowerShell 7": {>> "%TARGET%\.vscode\settings.json"
echo             "source": "PowerShell",>> "%TARGET%\.vscode\settings.json"
echo             "args": [>> "%TARGET%\.vscode\settings.json"
echo                 "-NoExit",>> "%TARGET%\.vscode\settings.json"
echo                 "-Command",>> "%TARGET%\.vscode\settings.json"
echo                 ". '%PS_PROFILE_JSON%'">> "%TARGET%\.vscode\settings.json"
echo             ]>> "%TARGET%\.vscode\settings.json"
echo         },>> "%TARGET%\.vscode\settings.json"
echo         "Command Prompt (dev)": {>> "%TARGET%\.vscode\settings.json"
echo             "path": "%CMD_EXE_JSON%",>> "%TARGET%\.vscode\settings.json"
echo             "args": [>> "%TARGET%\.vscode\settings.json"
echo                 "/k",>> "%TARGET%\.vscode\settings.json"
echo                 "%GIT_CLI_ENV_JSON%">> "%TARGET%\.vscode\settings.json"
echo             ]>> "%TARGET%\.vscode\settings.json"
echo         }>> "%TARGET%\.vscode\settings.json"
echo     },>> "%TARGET%\.vscode\settings.json"
echo     "files.eol": "\r\n",>> "%TARGET%\.vscode\settings.json"
echo     "chat.tools.terminal.autoApprove": {>> "%TARGET%\.vscode\settings.json"
echo         "rename-item": true>> "%TARGET%\.vscode\settings.json"
echo     },>> "%TARGET%\.vscode\settings.json"
::       added autosave preference.
echo     "files.autoSaveDelay": 5000,>> "%TARGET%\.vscode\settings.json"
echo     "files.autoSave": "afterDelay",>> "%TARGET%\.vscode\settings.json"
echo     "vim.easymotion": true,>> "%TARGET%\.vscode\settings.json"
echo     "vim.incsearch": true,>> "%TARGET%\.vscode\settings.json"
echo     "vim.useSystemClipboard": true,>> "%TARGET%\.vscode\settings.json"
echo     "vim.useCtrlKeys": true,>> "%TARGET%\.vscode\settings.json"
echo     "vim.hlsearch": true,>> "%TARGET%\.vscode\settings.json"
echo     "vim.leader": "<space>",>> "%TARGET%\.vscode\settings.json"
echo     "vim.handleKeys": {>> "%TARGET%\.vscode\settings.json"
echo        "<C-a>": false,>> "%TARGET%\.vscode\settings.json"
echo        "<C-f>": false,>> "%TARGET%\.vscode\settings.json"
echo        "<C-v>": false,>> "%TARGET%\.vscode\settings.json"
echo        "<C-x>": false>> "%TARGET%\.vscode\settings.json"
echo     },>> "%TARGET%\.vscode\settings.json"
echo }>> "%TARGET%\.vscode\settings.json"
echo  Windows-native vscode environment
cat "%TARGET%\.vscode\settings.json"
endlocal
