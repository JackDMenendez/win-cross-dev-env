:: win-admin.cmd - Launch an administrative Windows command shell with repo helpers on PATH.
@echo off
setlocal
set WIN_ADMIN_RC=0
call "%~dp0lib\set-prompt.cmd" admin
rem --- Load global baseline environment ---
call "%~dp0env\requires.cmd" global win-dev git-cli win-admin
if %errorlevel% neq 0 (
    echo Error: %errorlevel% - required dependencies not found. Please ensure that you have the necessary tools installed.
    exit /b 1
)
rem --- This is a pure Windows shell with Chocolatey ---
rem --- Launch a native Windows command prompt ---
sudo -E %ComSpec% /k "title Windows Admin Shell"
set WIN_ADMIN_RC=%errorlevel%
call "%~dp0tools\restore-prompt.cmd"
if %WIN_ADMIN_RC% neq 0 (
    echo Windows Admin Shell exited with code %WIN_ADMIN_RC%
)
endlocal & exit /b %WIN_ADMIN_RC%
