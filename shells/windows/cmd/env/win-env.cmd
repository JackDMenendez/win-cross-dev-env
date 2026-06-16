:: win-env.cmd - Build the baseline Windows shell PATH and repo command access.
@echo off
rem Basic Windows CLI Env Setup
if not "%SHELL_WIN_ENV%0"=="0" exit /b 0

set SHELL_WIN_ENV=1

call "%~dp0global-env.cmd"
rem --- Pick up winget and other Windows Store tools ---
set PATH=%PATH%;%USERPROFILE%\AppData\Local\Microsoft\WindowsApps
set "PATH=%PATH%;%NEOVIM_PATH%\nvim-win64\bin"
set "PATH=%PATH%;%VIM_PATH%\vim92"
rem --- The old Chocolatey/unxUtils GNU tools (incl. GNU Make 3.x) are
rem     intentionally NOT on PATH. Use an MSYS2 shell (UCRT64/MINGW64/CLANG64)
rem     for make/coreutils, or modern Windows tools (ripgrep, fd) / PowerShell. ---
rem --- Development Shell Path ===
set "PATH=%PATH%;%DEV_SHELL_WIN_PATH%\cmd"
set "PATH=%PATH%;%DEV_SHELL_WIN_PATH%\lib"

rem --- Return to caller ---
exit /b 0

