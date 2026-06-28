:: agda-env.cmd - Add Agda to the PATH and set up GHCup environment.
@echo off
rem Agda environment setup
if not "%SHELL_AGDA_ENV%0"=="0" exit /b 0

set SHELL_AGDA_ENV=1

call "%~dp0ghcup-env.cmd"

rem --- Add Agda to the PATH ---
if exist "C:\tools\agda" (
    echo Adding Agda to PATH from C:\tools\agda
    set PATH=C:\tools\agda\bin;%PATH%
) else (
    echo Warning: Agda not found in C:\tools\agda
)

rem --- Return to caller ---
exit /b 0
