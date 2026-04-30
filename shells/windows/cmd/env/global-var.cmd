@echo off
rem Global Variables Provided For Convenience of Windows Command Shells
rem --- Global variables shared by all environments ---
if not "%SHELL_GLOBAL_VAR%0"=="0" exit /b 0
set SHELL_GLOBAL_VAR=1

if not defined CHOCOLATEY_PATH set "CHOCOLATEY_PATH=%ChocolateyInstall%"
if not defined MY_DEV_ROOT set "MY_DEV_ROOT=%USERPROFILE%\dev"
if not defined MY_TOOLS set "MY_TOOLS=%USERPROFILE%\tools"
if not defined MY_LIB set "MY_LIB=%USERPROFILE%\lib"
if not defined MY_CACHE set "MY_CACHE=%LOCALAPPDATA%\dev-shell\cache"
if not defined NEOVIM_PATH set "NEOVIM_PATH=c:\tools\neovim"
if not defined VIM_PATH set "VIM_PATH=c:\tools\vim"
if not defined GNU_PATH set "GNU_PATH=%CHOCOLATEY_PATH%\lib\unxUtils\tools\unxUtils\usr\local\wbin"

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

set CANONICAL_WIN_VENV=%USERPROFILE%\.venv-win
set CANONICAL_WIN_PYTHON=%CANONICAL_WIN_VENV%\Scripts\python.exe
set CANONICAL_WIN_SCRIPTS=%CANONICAL_WIN_VENV%\Scripts

rem --- Return to caller ---
exit /b 0