:: haskell.cmd - Launch GHCi (Haskell interactive environment).
@echo off
setlocal
call "%~dp0env\requires.cmd" global haskell
if %errorlevel% neq 0 (
    echo Error: %errorlevel% - required dependencies not found. Please ensure that you have the necessary tools installed.
    exit /b 1
)

if "%1"=="" (
    rem --- Launch GHCi interactive mode ---
    ghci
) else (
    rem --- Process command line arguments ---  
    ghci %*
)

set EXITCODE=%ERRORLEVEL%
endlocal & exit /b %EXITCODE%
