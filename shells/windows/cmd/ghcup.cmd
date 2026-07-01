:: ghcup.cmd - Launch GHCup with Haskell toolchain available.
@echo off
setlocal
call "%~dp0env\requires.cmd" global win ghcup
if %errorlevel% neq 0 (
    echo Error: %errorlevel% - required dependencies not found. Please ensure that you have the necessary tools installed.
    exit /b 1
)

if "%1"=="" (
    rem --- Launch GHCup interactive mode ---
    ghcup tui
) else (
    rem --- Process command line arguments ---
    echo %path%
    echo ghcup %*
    ghcup %*
)
set EXITCODE=%ERRORLEVEL%
endlocal & exit /b %EXITCODE%