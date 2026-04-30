:: global-env.cmd
@echo off
:: ---------------------------------------------------------------------------- 
:: BRIEF: Provide a Global Windows CLI Minimum Environment
:: PURPOSE: Bootstraps a windows development environment that isolates
:: tool-chain dependencies from the system environment and from each other
:: DESCRIPTION: Some tool chains along with their dependencies and the 
:: system environment may contaminate a specific tool-chain environment by
:: distributing their full tool chain. For example, the existing release
:: of Strawberry Perl contains a make utility among other basic tools. Some
:: tools even distribute their own version of Python.
:: FEATURES:
:: Minimum Windows CLI environment setup
:: Can be safely called multiple times
:: Retains existing environment variables with different path
:: USAGE: call "%~dp0win-env.cmd" from another xxx-env.cmd or directly
:: from a shell like msys2 or Git Bash
:: ---------------------------------------------------------------------------- 
rem --- Initialize global environment return code ---
set GLOBAL_ENV_RC=0
rem --- Retrieve Baseline Environment Variables ---
call "%~dp0global-var.cmd"
set GLOBAL_ENV_RC=%ERRORLEVEL%
if not "%GLOBAL_ENV_RC%"=="0" exit /b %GLOBAL_ENV_RC%
rem --- Windows Minimum Path
set "PATH=%SystemRoot%\System32;%SystemRoot%"
rem --- Return to caller ---
exit /b %GLOBAL_ENV_RC%