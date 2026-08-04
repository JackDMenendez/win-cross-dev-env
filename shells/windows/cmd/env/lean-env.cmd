:: lean-env.cmd - Mathematical proof assitance
@echo off
if not "%SHELL_LEAN_ENV%0"=="0" exit /b 0
set SHELL_LEAN_ENV=1
call "%~dp0requires.cmd" global mathlib
if %errorlevel% neq 0 exit /b %errorlevel%
echo ------------ vsvim
:: Use the presence of this environment variable to detect
:: that VSVim is active. This is used by the setup-vscode.cmd 
:: script to enable the vim extension
set WCDE_LEAN_ACTIVE=1
set ELAN_HOME=%USERPROFILE%\.elan
:: The ELAN_HOME environment variable is used by lean
if exist "%ELAN_HOME%\bin\elan.exe" echo Adding Lean to path
if exist "%ELAN_HOME%\bin\elan.exe" set "PATH=%ELAN_HOME%\bin;%PATH%"
if not exist "%ELAN_HOME%\bin" echo Warning: lean could not be added to path
:: elan can be installed while having no Lean toolchain yet (toolchains/ empty),
:: in which case the VS Code Lean extension fails trying to install one on first
:: use. Warn early so it is obvious -- fix: elan toolchain install stable
if exist "%ELAN_HOME%\bin\elan.exe" if not exist "%ELAN_HOME%\toolchains\*" echo Warning: elan has no Lean toolchain installed -- run: elan toolchain install stable
:: This is a vscode extension that does not require a change
:: to the PATH.
exit /b 0
