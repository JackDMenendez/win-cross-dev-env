@echo off
rem Basic Windows CLI Env Setup
if not "%SHELL_WIN_ENV%0"=="0" exit /b 0

set SHELL_WIN_ENV=1

call "%~dp0global-env.cmd"
rem --- Windows Shell Basic Working PATH ---
set "PATH=%PATH%;%SystemRoot%\System32\WindowsPowerShell\v1.0"
set "PATH=%PATH%;%CHOCOLATEY_PATH%\lib\unxUtils\tools\unxUtils\usr\local\wbin"
set "PATH=%PATH%;%NEOVIM_PATH%\nvim-win64\bin"
set "PATH=%PATH%;%VIM_PATH%\vim92"
set "PATH=%PATH%;%GNU_PATH%"
:: Pick up any tools not covered, like "which"
set PATH=%path%;C:\tools\gnu\bin
rem --- Provide a C compiler (gcc) as a fallback for Neovim Treesitter ---
set "PATH=%PATH%;C:\msys64\ucrt64\bin"
rem --- Development Shell Path ===
set "PATH=%PATH%;%DEV_SHELL_WIN_PATH%\cmd"
set "PATH=%PATH%;%DEV_SHELL_WIN_PATH%\lib"

rem --- Return to caller ---
exit /b 0

