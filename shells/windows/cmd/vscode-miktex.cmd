:: vscode-miktex.cmd - Launch VS Code with MiKTeX added to the Windows tool stack.
@echo off
setlocal
call "%~dp0env\requires.cmd" global win-dev miktex vscode
if %errorlevel% neq 0 (
    echo Error: %errorlevel% - required dependencies not found. Please ensure that you have the necessary tools installed.
    exit /b 1
)

call "%USERPROFILE%\AppData\Local\Programs\Microsoft VS Code\Code.exe" %*
set EXITCODE=%ERRORLEVEL%

endlocal & exit /b %EXITCODE%