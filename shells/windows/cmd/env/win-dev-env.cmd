@echo off

if not "%SHELL_WIN_DEV_ENV%0"=="0" exit /b 0

set SHELL_WIN_DEV_ENV=1

call "%~dp0win-env.cmd"

rem --- Baseline PATH --- Order matters here
set PATH=%path%;%ProgramFiles%\Git\cmd
if exist "%ProgramFiles%\GitHub CLI\gh.exe" set PATH=%path%;%ProgramFiles%\GitHub CLI
if exist "%ProgramFiles(x86)%\GitHub CLI\gh.exe" set PATH=%path%;%ProgramFiles(x86)%\GitHub CLI
if exist "%LOCALAPPDATA%\Programs\GitHub CLI\gh.exe" set PATH=%path%;%LOCALAPPDATA%\Programs\GitHub CLI
set PATH=%path%;%ProgramFiles%\doxygen\bin
set PATH=%path%;%CHOCOLATEY_PATH%\lib\make\tools\install\bin
set PATH=%path%;%ProgramFiles%\CMake\bin
set PATH=%path%;%ProgramFiles%\Tcl\bin

rem --- Compiler environment for pip builds (MSVC) ---
if exist "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat" (
    call "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat"
)
set CC=cl.exe
set CXX=cl.exe

rem --- Return to caller ---
exit /b 0

set PATH=%path%;

rem --- Global variables shared by all environments ---

rem --- Return to caller ---
exit /b 0

