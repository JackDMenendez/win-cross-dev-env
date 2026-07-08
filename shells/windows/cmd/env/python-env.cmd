@echo off
rem Basic Windows CLI Env Setup
if not "%SHELL_PYTHON_WIN_ENV%0"=="0" exit /b 0

set SHELL_PYTHON_WIN_ENV=1

call "%~dp0requires.cmd" global
echo ------------ PYTHON win
if %errorlevel% neq 0 exit /b %errorlevel%
rem --- This script is only loaded when `python` is passed to requires.cmd. ---
rem --- Publish that request so downstream shells decide whether to activate. ---
set "WCDE_INCLUDE_PYTHON_VENV=1"
rem --- Load Python venv activation logic, which sets DEV_SHELL_ACTIVE_VENV_* variables ---
call "%~dp0..\lib\python-activate.cmd"
rem --- Return to caller ---
exit /b 0
