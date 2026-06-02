:: git-cli-env.cmd - Add Git and GitHub CLI to the PATH if they are installed in the default locations.
@echo off

if not "%SHELL_GIT_CLI_ENV%0"=="0" exit /b 0

set SHELL_GIT_CLI_ENV=1

rem --- Add Git and GitHub CLI to the PATH if they are installed in the default locations ---
set PATH=%path%;%ProgramFiles%\Git
if exist "%ProgramFiles%\GitHub CLI\gh.exe" set PATH=%path%;%ProgramFiles%\GitHub CLI
if exist "%ProgramFiles(x86)%\GitHub CLI\gh.exe" set PATH=%path%;%ProgramFiles(x86)%\GitHub CLI
if exist "%LOCALAPPDATA%\Programs\GitHub CLI\gh.exe" set PATH=%path%;%LOCALAPPDATA%\Programs\GitHub CLI

rem --- Return to caller ---
exit /b 0