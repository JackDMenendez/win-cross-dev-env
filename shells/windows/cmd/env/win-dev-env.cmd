:: win-dev-env.cmd - Build the native Windows development PATH and compiler baseline.
@echo off

if not "%SHELL_WIN_DEV_ENV%0"=="0" exit /b 0

set SHELL_WIN_DEV_ENV=1
rem --- Compiler environment for pip builds (MSVC) ---
if exist "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat" (
    call "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat"
)
call "%~dp0requires.cmd" global win pwsh quarto git-cli
if %errorlevel% neq 0 exit /b %errorlevel%
echo ------------ win-dev
set PATH=%path%;%ProgramFiles%\doxygen\bin
rem --- Old Chocolatey GNU Make (3.x) removed. Drive MSVC builds with CMake +
rem     Ninja, or run make from an MSYS2 shell (GNU Make 4.x). ---
set PATH=%path%;%ProgramFiles%\CMake\bin
set PATH=%path%;%ProgramFiles%\Tcl\bin

set CC=cl.exe
set CXX=cl.exe

rem --- Return to caller ---
echo Windows development environment PATH and compiler environment set up.
exit /b 0

set PATH=%path%;

rem --- Global variables shared by all environments ---

rem --- Return to caller ---
exit /b 0

