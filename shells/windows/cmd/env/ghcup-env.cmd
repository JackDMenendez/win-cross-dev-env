:: ghcup-env.cmd - Add Haskell/GHC toolchain to the PATH and set up MSYS64 environment.
@echo off
rem GHCup environment setup
if not "%SHELL_GHCUP_ENV%0"=="0" exit /b 0

set SHELL_GHCUP_ENV=1
call "%~dp0requires.cmd" global
if %errorlevel% neq 0 exit /b %errorlevel%
echo ------------ ghcup
rem --- Set GHCup installation base prefix and MSYS2 paths ---
rem These are used by ghcup to locate the Haskell toolchain and MSYS2 libraries.
set GHCUP_INSTALL_BASE_PREFIX=C:\tools\ghcup
set GHCUP_MSYS2_PATH=C:\msys64\usr\bin
set GHCUP_MSYS2_ENV_PATH=UCRT64

rem NOTE: the set/if statements below are deliberately kept on single lines
rem (no parenthesized "( ... )" blocks). Inside a block, %PATH% is expanded at
rem parse time, so a ")" in an entry like "C:\Program Files (x86)\..." closes
rem the block early -- which previously made the UCRT64 check take the else
rem branch and skip adding ucrt64. Quoted single-line "set" avoids that.

rem --- Add MSYS2 UCRT64 runtime libraries to PATH ---
if exist "C:\msys64\ucrt64\bin" echo Adding MSYS2 UCRT64 libraries to PATH
if exist "C:\msys64\ucrt64\bin" set "PATH=C:\msys64\ucrt64\bin;%PATH%"
if not exist "C:\msys64\ucrt64\bin" echo Warning: MSYS2 UCRT64 bin directory not found

rem --- Add MSYS2 MSYS runtime libraries to PATH ---
if exist "C:\msys64\usr\bin" echo Adding MSYS2 MSYS libraries to PATH
if exist "C:\msys64\usr\bin" set "PATH=C:\msys64\usr\bin;%PATH%"
if not exist "C:\msys64\usr\bin" echo Warning: MSYS2 MSYS bin directory not found

rem --- Add ghcup to the PATH ---
if exist "%GHCUP_INSTALL_BASE_PREFIX%" echo Adding ghcup to PATH from %GHCUP_INSTALL_BASE_PREFIX%
if exist "%GHCUP_INSTALL_BASE_PREFIX%" set "PATH=%GHCUP_INSTALL_BASE_PREFIX%\bin;%PATH%"
if not exist "%GHCUP_INSTALL_BASE_PREFIX%" echo Warning: ghcup not found in %GHCUP_INSTALL_BASE_PREFIX%

rem --- Return to caller ---
exit /b 0
