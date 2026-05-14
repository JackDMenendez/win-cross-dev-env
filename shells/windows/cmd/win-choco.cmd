@echo off
setlocal
set WIN_CHOCO_RC=0
rem --- Load Python venv activation logic, which sets DEV_SHELL_ACTIVE_VENV_* variables ---
call "%~dp0lib\python-activate.cmd"
rem --- Set prompt to indicate Chocolatey Shell ---
call "%~dp0lib\set-prompt.cmd" admin-choco
rem --- Load global baseline environment ---
call "%~dp0env\win-choco-env.cmd"
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
