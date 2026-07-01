:: git-bash.cmd - Launch Git Bash with the repo's Windows-side PATH bootstrap.
@echo off
setlocal
call "%~dp0env\requires.cmd" global git-bash
if %errorlevel% neq 0 (
    echo Error: %errorlevel% - required dependencies not found. Please ensure that you have the necessary tools installed.
    exit /b 1
)
git bash -defterm -no-start -here -msys
set EXITCODE=%ERRORLEVEL%
endlocal & exit /b %EXITCODE%
