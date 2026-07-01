:: vscode-cmd.cmd - Launch VS Code with the full native Windows tool stack layered onto the session.
@echo off
setlocal

rem --- Load your global baseline environment ---
call "%~dp0env\requires.cmd" global win-dev texlive sagemath vscode
if %errorlevel% neq 0 (
    echo Error: %errorlevel% - required dependencies not found. Please ensure that you have the necessary tools installed.
    exit /b 1
)
rem --- No MSYS2 paths added here ---
rem --- This is a pure Windows environment ---
rem --- Launch native Windows VS Code ---
call "%USERPROFILE%\AppData\Local\Programs\Microsoft VS Code\Code.exe" %*
set EXITCODE=%ERRORLEVEL%

endlocal & exit /b %EXITCODE%

