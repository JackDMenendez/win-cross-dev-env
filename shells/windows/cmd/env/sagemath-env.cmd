:: sagemath-env.cmd - Prepend SageMath runtime tools to PATH.
@echo off
if not "%SHELL_SAGEMATH_ENV%0"=="0" exit /b 0
set SHELL_SAGEMATH_ENV=1
call "%~dp0requires.cmd" global
if %errorlevel% neq 0 exit /b %errorlevel%
echo ------------ sagemath
rem ===  S A G E M A T H   E N V ===
set SAGEMATH_BIN=C:\Program Files\SageMath 10.4\runtime\bin
rem --- isolate tool chain contaminator ---
set PATH=%SAGEMATH_BIN%;%path%
rem --- Global variables shared by all environments ---

rem --- Return to caller ---
exit /b 0

