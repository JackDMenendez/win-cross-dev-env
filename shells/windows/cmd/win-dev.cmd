rem win-dev.cmd - Launch Windows Dev %CompSpec% Shell
@echo off
setlocal
set WIN_DEV_RC=0
set "WIN_DEV_ACTIVATE="
set "DEV_SHELL_SUBSYSTEM=WINDOWS"
set "DEV_SHELL_DEFAULT_VENV=%USERPROFILE%\.venv-win"
set "DEV_SHELL_VENV_SUFFIX=win"
set "DEV_SHELL_ACTIVE_VENV_KIND="
set "DEV_SHELL_ACTIVE_VENV_PATH="
rem --- Load Python venv activation logic, which sets DEV_SHELL_ACTIVE_VENV_* variables ---
call "%~dp0lib\python-activate.cmd"

call "%~dp0lib\set-prompt.cmd" dev
rem --- Load global baseline environment ---
call "%~dp0env\win-dev-env.cmd"
rem --- No MSYS2, no MinGW, no UCRT64 ---
rem --- This is a pure Windows dev shell ---
rem --- Launch a native Windows command prompt ---
if defined WIN_DEV_ACTIVATE (
    call "%WIN_DEV_ACTIVATE%"
    title Windows Dev Shell
    %ComSpec% /k
) else (
    %ComSpec% /k "title Windows Dev Shell"
)
set WIN_DEV_RC=%errorlevel%
call "%~dp0tools\restore-prompt.cmd"
if %WIN_DEV_RC% neq 0 (
    echo Windows Dev Shell exited with code %WIN_DEV_RC%
)
endlocal & exit /b %WIN_DEV_RC%

