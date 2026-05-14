@echo off
rem Basic Windows CLI Env Setup
if not "%SHELL_GIT_BASH_ENV%0"=="0" exit /b 0

set SHELL_GIT_BASH_ENV=1

call "%~dp0global-env.cmd"

rem --- GIT BASH Basic Working PATH ---
set PATH=%path%;%ProgramFiles%\Git\cmd
if exist "%ProgramFiles%\GitHub CLI\gh.exe" set PATH=%path%;%ProgramFiles%\GitHub CLI
if exist "%ProgramFiles(x86)%\GitHub CLI\gh.exe" set PATH=%path%;%ProgramFiles(x86)%\GitHub CLI
if exist "%LOCALAPPDATA%\Programs\GitHub CLI\gh.exe" set PATH=%path%;%LOCALAPPDATA%\Programs\GitHub CLI
rem --- Development Shell Path ===
set "PATH=%PATH%;%DEV_SHELL_WIN_PATH%\cmd"
set "PATH=%PATH%;%DEV_SHELL_WIN_PATH%\lib"

rem --- Return to caller ---
exit /b 0
