:: nvim-ucrt64.cmd - Open Neovim after rebuilding a clean UCRT64 environment.
@echo off
setlocal

rem --- Wipe idempotency guards to force rebuild of a pristine environment ---
set SHELL_GLOBAL_VAR=
set SHELL_WIN_ENV=
set SHELL_MSYS64_ENV=
set SHELL_UCRT64_ENV=
call "%~dp0env\requires.cmd" global ucrt64
if %errorlevel% neq 0 (
    echo Error: %errorlevel% - required dependencies not found. Please ensure that you have the necessary tools installed.
    exit /b 1
)

call nvim %*
set EXITCODE=%ERRORLEVEL%

endlocal & exit /b %EXITCODE%

