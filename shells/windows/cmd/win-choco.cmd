:: win-choco.cmd - Launch a Windows shell oriented around Chocolatey-managed tools and venv activation.
@echo off
setlocal
set WIN_CHOCO_RC=0
rem --- Clear any inherited activation marker; python-env.cmd (loaded via the
rem     `python` requirement below) sets WIN_DEV_ACTIVATE if a venv is found. ---
set "WIN_DEV_ACTIVATE="
rem --- Set prompt to indicate Chocolatey Shell ---
call "%~dp0lib\set-prompt.cmd" admin-choco
rem --- Load global baseline environment. `python` routes venv activation
rem     through env\python-env.cmd (which sets WIN_DEV_ACTIVATE and the
rem     DEV_SHELL_ACTIVE_VENV_* variables) -- the one canonical activation path. ---
call "%~dp0env\requires.cmd" global python ghcup win-choco vim
if %errorlevel% neq 0 (
    echo Error: %errorlevel% - required dependencies not found. Please ensure that you have the necessary tools installed.
    exit /b 1
)
rem --- No MSYS2, no MinGW, no UCRT64 ---
rem --- This is a pure Windows shell with Chocolatey ---
rem --- Launch a native Windows command prompt ---
:: If WIN_DEV_ACTIVATE is set, it means we have a Python venv to activate, so we 
:: should do that before launching the shell
if defined WIN_DEV_ACTIVATE call "%WIN_DEV_ACTIVATE%"
if "x%~1"=="x" (
    sudo -E %ComSpec% /k "title Windows Choco Shell" "cd /d %__CD__%"
) else (
    sudo --inline %*
)   
set WIN_CHOCO_RC=%errorlevel%
call "%~dp0tools\restore-prompt.cmd"
if %WIN_CHOCO_RC% neq 0 (
    echo Windows Choco Shell exited with code %WIN_CHOCO_RC%
)
endlocal & exit /b %WIN_CHOCO_RC%
