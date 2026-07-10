:: vim-env.cmd - Prepend the native-Windows Vim bin dir to PATH.
:: global-env resets PATH to bare System32, so the native Vim (C:\tools\vim) is
:: otherwise unreachable inside a launcher. Prepending it here makes the native
:: `vim`/`gvim` the winner over C:\Program Files\Git\usr\bin\vim.exe. The VS Code
:: Vim extension does NOT need this (it emulates Vim, and its optional deeper
:: integration uses Neovim, see nvim-env.cmd) - this file exists so classic Vim
:: is managed through the same requires system for shells and future launchers.
@echo off
if not "%SHELL_VIM_ENV%0"=="0" exit /b 0
set SHELL_VIM_ENV=1
call "%~dp0requires.cmd" global
if %errorlevel% neq 0 exit /b %errorlevel%
echo ------------ vim
if exist "C:\tools\vim\vim92\vim.exe" set "PATH=C:\tools\vim\vim92;%PATH%"
if exist "C:\tools\vim\vim92\vim.exe" echo Prepended native Vim (C:\tools\vim\vim92) to PATH
if not exist "C:\tools\vim\vim92\vim.exe" echo Warning: native Vim not found at C:\tools\vim\vim92; relying on existing PATH
exit /b 0
