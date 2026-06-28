:: ghcup-env.cmd - Add Haskell/GHC toolchain to the PATH and set up MSYS64 environment.
@echo off
rem GHCup environment setup
if not "%SHELL_GHCUP_ENV%0"=="0" exit /b 0

set SHELL_GHCUP_ENV=1

call "%~dp0msys64-env.cmd"

rem --- Add ghcup to the PATH ---
if exist "C:\tools\ghcup" (
    echo Adding ghcup to PATH from C:\tools\ghcup
    set PATH=C:\tools\ghcup\bin;%PATH%
) else (
    echo Warning: ghcup not found in C:\tools\ghcup
)

rem --- Return to caller ---
exit /b 0
