:: cabal.cmd - Launch Cabal (Haskell package manager).
@echo off
setlocal
call "%~dp0env\requires.cmd" global win ghcup cabal
if %errorlevel% neq 0 (
    echo Error: %errorlevel% - required dependencies not found. Please ensure that you have the necessary tools installed.
    exit /b 1
)
rem --- Process command line arguments ---  
cabal %*
set EXITCODE=%ERRORLEVEL%
endlocal & exit /b %EXITCODE%
