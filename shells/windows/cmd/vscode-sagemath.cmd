:: vscode-sagemath.cmd - Launch VS Code with SageMath available in the environment.
@echo off
setlocal
call "%~dp0env\requires.cmd" global win-dev sagemath vscode
if %errorlevel% neq 0 (
    echo Error: %errorlevel% - required dependencies not found. Please ensure that you have the necessary tools installed.
    exit /b 1
)

call "%USERPROFILE%\AppData\Local\Programs\Microsoft VS Code\Code.exe" %*
set EXITCODE=%ERRORLEVEL%

endlocal & exit /b %EXITCODE%