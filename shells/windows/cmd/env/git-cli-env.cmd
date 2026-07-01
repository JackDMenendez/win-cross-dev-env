:: git-cli-env.cmd - Add Git and GitHub CLI to the PATH if they are installed in the default locations.
@echo off

if not "%SHELL_GIT_CLI_ENV%0"=="0" exit /b 0
call "%~dp0requires.cmd" global
if %errorlevel% neq 0 exit /b %errorlevel%
echo ------------ git-cli
set SHELL_GIT_CLI_ENV=1

rem --- Prepend Git-for-Windows git + GitHub CLI so they win over any MSYS2
rem     git already on PATH (e.g. C:\msys64\ucrt64\bin\git.exe). Git\cmd is set
rem     last so git.exe ends up at the FRONT of PATH. ---
if exist "%ProgramFiles%\GitHub CLI\gh.exe" set "PATH=%ProgramFiles%\GitHub CLI;%path%"
if exist "%ProgramFiles%\Git\cmd\git.exe" set "PATH=%ProgramFiles%\Git\cmd;%path%"

rem --- Append the rest of the Git toolchain (libexec DLLs, usr\bin coreutils).
rem     Kept at the END so Git's bash/coreutils do not shadow MSYS2's. ---
if exist "%ProgramFiles%\Git\mingw64\bin\GitHub.dll" set "PATH=%path%;%ProgramFiles%\Git\mingw64\bin"
if exist "%ProgramFiles%\Git\usr\bin\bash.exe" set "PATH=%path%;%ProgramFiles%\Git\usr\bin"

rem --- Return to caller ---
exit /b 0
