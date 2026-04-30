@echo off

if not "%SHELL_WIN_DEV_ENV%0"=="0" exit /b 0

set SHELL_WIN_DEV_ENV=1

call "%~dp0win-env.cmd"

rem --- Baseline PATH ---
set PATH=%path%;%ProgramFiles%\Git\cmd
set PATH=%path%;C:\Python314\Scripts
set PATH=%path%;C:\Python314
set PATH=%path%;%ProgramFiles%\doxygen\bin
set PATH=%path%;%CHOCOLATEY_PATH%\lib\make\tools\install\bin
set PATH=%path%;%ProgramFiles%\CMake\bin
set PATH=%path%;%ProgramFiles%\Tcl\bin

rem --- Compiler environment for pip builds (MSVC) ---
set CC=cl.exe
set CXX=cl.exe

rem --- Return to caller ---
exit /b 0

set PATH=%path%;

rem --- Global variables shared by all environments ---

rem --- Return to caller ---
exit /b 0

