:: nvim-cmd.cmd - Open Neovim after rebuilding a clean native Windows development environment.
@echo off
setlocal

rem --- Wipe idempotency guards to force rebuild of a pristine environment ---
set SHELL_GLOBAL_VAR=
set SHELL_WIN_ENV=
set SHELL_WIN_DEV_ENV=

rem --- Provide a C compiler (gcc) as a fallback for Neovim Treesitter ---
call "%~dp0env\requires.cmd" global win-dev
if %errorlevel% neq 0 (
    echo Error: %errorlevel% - required dependencies not found. Please ensure that you have the necessary tools installed.
    exit /b 1
)

call nvim %*
set EXITCODE=%ERRORLEVEL%

endlocal & exit /b %EXITCODE%
