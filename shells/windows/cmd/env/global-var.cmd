:: global-var.cmd - Define repo-root and shared convenience variables.
@echo off
rem Global Variables Provided For Convenience of Windows Command Shells
rem --- Global variables shared by all environments ---
:: --- Idempotency Guard --- 
:: Reentrant calls to this script will be no-ops, preventing infinite loops 
:: and redundant processing.
if not "%SHELL_GLOBAL_VAR%0"=="0" exit /b 0
set SHELL_GLOBAL_VAR=1
echo Setting up global environment variables for Windows development shells...
rem --- Set default MSYSTEM like MSYS2-based tools but for cmd shell use. ---
:: This variable is reset as needed by MYSY2 environment.
:: It is used by some tools to determine the virtual environment they are
:: running in, and to adjust their behavior accordingly.
set MSYSTEM=WIN64
rem --- Commonly used environment variables with defaults if not already set ---
if not defined CHOCOLATEY_PATH set "CHOCOLATEY_PATH=%ChocolateyInstall%"
if not defined MY_DEV_ROOT set "MY_DEV_ROOT=%USERPROFILE%\dev"
if not defined MY_TOOLS set "MY_TOOLS=%USERPROFILE%\tools"
if not defined MY_LIB set "MY_LIB=%USERPROFILE%\lib"
if not defined MY_CACHE set "MY_CACHE=%LOCALAPPDATA%\dev-shell\cache"
if not defined NEOVIM_PATH set "NEOVIM_PATH=c:\tools\neovim"
if not defined VIM_PATH set "VIM_PATH=c:\tools\vim"
rem Unfortunately, the following variable is a folder that contains python.exe.
if not defined WCDE_LOCAL_WINDOWS_APPS set "LOCAL_WINDOWS_APPS=%LOCALAPPDATA%\Microsoft\WindowsApps"

rem --- Ensure relocatable path variables are absolute and POSIX-style where possible ---
if not defined DEV_SHELL_PATH (
	for %%I in ("%~dp0..\..\..\..") do set "DEV_SHELL_PATH=%%~fI"
)
if not defined DEV_SHELL_POSIX_PATH (
	set "DEV_SHELL_POSIX_PATH=%DEV_SHELL_PATH:\=/%"
	if exist "C:\msys64\usr\bin\cygpath.exe" (
		for /f "delims=" %%I in ('C:\msys64\usr\bin\cygpath.exe -u "%DEV_SHELL_PATH%"') do set "DEV_SHELL_POSIX_PATH=%%I"
	)
)
set DEV_SHELL_WIN_PATH=%DEV_SHELL_PATH%\shells\windows
set DEV_SHELL=%DEV_SHELL_PATH%

set CANONICAL_WIN_VENV=%USERPROFILE%\.venv
set CANONICAL_WIN_PYTHON=%CANONICAL_WIN_VENV%\Scripts\python.exe
set CANONICAL_WIN_SCRIPTS=%CANONICAL_WIN_VENV%\Scripts
echo Canonical Windows virtual environment path set to: %CANONICAL_WIN_VENV%

rem --- Return to caller ---
echo Global environment variables set up.
exit /b 0