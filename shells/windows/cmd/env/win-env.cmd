@echo off
rem Basic Windows CLI Env Setup
if not "%SHELL_WIN_ENV%0"=="0" exit /b 0

set SHELL_WIN_ENV=1

call "%~dp0global-env.cmd"

rem --- Windows Shell Basic Working PATH ---
set "PATH=%PATH%;%CHOCOLATEY_PATH%\lib\unxUtils\tools\unxUtils\usr\local\wbin"
set "PATH=%PATH%;%NEOVIM_PATH%\nvim-win64\bin"
set "PATH=%PATH%;%VIM_PATH%\vim92"
set "PATH=%PATH%;%GNU_PATH%"
rem --- Development Shell Path ===
set "PATH=%PATH%;%DEV_SHELL_WIN_PATH%\cmd"
set "PATH=%PATH%;%DEV_SHELL_WIN_PATH%\lib"

rem --- Return to caller ---
exit /b 0

