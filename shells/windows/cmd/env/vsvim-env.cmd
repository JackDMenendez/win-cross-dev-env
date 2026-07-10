:: vsvim-env.cmd - Set up environment for the VSVim VS Code extension.
@echo off
if not "%SHELL_VSVIM_ENV%0"=="0" exit /b 0
set SHELL_VSVIM_ENV=1
call "%~dp0requires.cmd" global
if %errorlevel% neq 0 exit /b %errorlevel%
echo ------------ vsvim
:: Use the presence of this environment variable to detect
:: that VSVim is active. This is used by the setup-vscode.cmd 
:: script to enable the vim extension
set WCDE_VSVIM_ACTIVE=1
:: This is a vscode extension that does not require a change
:: to the PATH.
exit /b 0
