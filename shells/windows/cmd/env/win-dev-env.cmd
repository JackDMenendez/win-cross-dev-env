:: win-dev-env.cmd - Build the native Windows development PATH and compiler baseline.
@echo off

if not "%SHELL_WIN_DEV_ENV%0"=="0" exit /b 0

set SHELL_WIN_DEV_ENV=1

call "%~dp0win-env.cmd"
rem --- Compiler environment for pip builds (MSVC) ---
if exist "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat" (
    call "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat"
)
call "%~dp0pwsh-env.cmd"
call "%~dp0quarto-env.cmd"
call "%~dp0git-cli-env.cmd"

rem --- Baseline PATH --- Order matters here
set PATH=%path%;%ProgramFiles%\doxygen\bin
set PATH=%path%;%CHOCOLATEY_PATH%\lib\make\tools\install\bin
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

