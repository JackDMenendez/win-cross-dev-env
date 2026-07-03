:: msys2-tools-env.cmd - Put the MSYS2 UCRT64 and MSYS (usr) bin directories on
:: PATH for a NATIVE-Windows shell, WITHOUT switching MSYSTEM or the Python venv.
:: Lets a PowerShell-launched VS Code reach the ucrt64 toolchain (gcc, make,
:: pkg-config, ...) alongside the canonical Windows Python venv.
::
:: Appended (lowest priority) on purpose:
::   * Windows System32 utilities (find, sort, link, ...) keep precedence over the
::     identically-named MSYS coreutils.
::   * The activated Windows venv's python keeps precedence over ucrt64\bin\python.exe.
:: UCRT64 only -- never mingw64 (its MSVCRT runtime conflicts; see notes/memory).
@echo off
if not "%SHELL_MSYS2_TOOLS_ENV%0"=="0" exit /b 0
set SHELL_MSYS2_TOOLS_ENV=1
call "%~dp0requires.cmd" global
if %errorlevel% neq 0 exit /b %errorlevel%
if exist "C:\msys64\ucrt64\bin" set "PATH=%PATH%;C:\msys64\ucrt64\bin"
if exist "C:\msys64\usr\bin" set "PATH=%PATH%;C:\msys64\usr\bin"
if exist "C:\msys64\ucrt64\bin" echo Added MSYS2 UCRT64 + MSYS bin to PATH (native-Windows, appended)
if not exist "C:\msys64\ucrt64\bin" echo Warning: C:\msys64\ucrt64\bin not found
exit /b 0
