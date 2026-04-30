@echo off
rem ===  S A G E M A T H   E N V ===
set SAGEMATH_BIN=C:\Program Files\SageMath 10.4\runtime\bin
rem --- isolate tool chain contaminator ---
set PATH=%SAGEMATH_BIN%;%path%
rem --- Global variables shared by all environments ---

rem --- Return to caller ---
exit /b 0

