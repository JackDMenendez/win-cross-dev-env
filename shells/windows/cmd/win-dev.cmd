@echo off
setlocal
set WIN_DEV_RC=0
set "WIN_DEV_ACTIVATE="
set "DEV_SHELL_SUBSYSTEM=WINDOWS"
set "DEV_SHELL_DEFAULT_VENV=%USERPROFILE%\.venv-win"
set "DEV_SHELL_VENV_SUFFIX=win"
set "DEV_SHELL_ACTIVE_VENV_KIND="
set "DEV_SHELL_ACTIVE_VENV_PATH="

if exist "%CD%\.venv-win\Scripts\activate.bat" (
    set "WIN_DEV_ACTIVATE=%CD%\.venv-win\Scripts\activate.bat"
    set "DEV_SHELL_ACTIVE_VENV_KIND=local"
    set "DEV_SHELL_ACTIVE_VENV_PATH=%CD%\.venv-win"
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
call "%~dp0lib\restore-prompt.cmd"
if %WIN_DEV_RC% neq 0 (
    echo Windows Dev Shell exited with code %WIN_DEV_RC%
)
endlocal & exit /b %WIN_DEV_RC%

