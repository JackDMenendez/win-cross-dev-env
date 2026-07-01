:: vscode-mingw64.cmd - Launch VS Code from a MINGW64-oriented shell plus TeX, SageMath, and Perl tools.
@echo off
setlocal
call "%~dp0env\requires.cmd" global win-dev mingw64 texlive sagemath vscode
if %errorlevel% neq 0 (
    echo Error: %errorlevel% - required dependencies not found. Please ensure that you have the necessary tools installed.
    exit /b 1
)

rem --- Use the users home path ---
call "%USERPROFILE%\AppData\Local\Programs\Microsoft VS Code\Code.exe" %*
set EXITCODE=%ERRORLEVEL%

endlocal & exit /b %EXITCODE%

