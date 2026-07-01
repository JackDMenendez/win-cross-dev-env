:: agda.cmd - Launch Agda interactively or process a file.
@echo off
setlocal
call "%~dp0env\requires.cmd" global win-dev ghcup agda
if %errorlevel% neq 0 (
    echo Error: %errorlevel% - required dependencies not found. Please ensure that you have the necessary tools installed.
    exit /b 1
)

if "%1"=="" (
    agda -i
) else (
    echo %path%
    echo agda %*
    agda %*
)

set EXITCODE=%ERRORLEVEL%
endlocal & exit /b %EXITCODE%
