:: quarto-env.cmd - Add Quarto to the PATH if it is installed in the default location.
@echo off
if not "%SHELL_QUARTO_ENV%0"=="0" exit /b 0
set SHELL_QUARTO_ENV=1
call "%~dp0requires.cmd" global
if %errorlevel% neq 0 exit /b %errorlevel%
echo ------------ quarto
rem --- NOTE: This script is idempotent by checking PATH membership, NOT by a
rem     boolean SHELL_QUARTO_ENV guard. A boolean guard is unsafe here because
rem     global-env.cmd unconditionally RESETS PATH; if the guard had already
rem     tripped (flag inherited as 1) the Quarto bin would be stranded off PATH.
rem     Checking PATH directly survives both PATH resets and repeated calls.
set SHELL_QUARTO_ENV=1
set EXITCODE=0
set "WCDE_QUARTO_PATH=%ProgramFiles%\Quarto"
set "WCDE_QUARTO_BIN=%WCDE_QUARTO_PATH%\bin"
set "WCDE_QUARTO_COMMAND=quarto.exe"

rem --- Add Quarto to the PATH if it is installed in the default location ---
if not exist "%WCDE_QUARTO_BIN%\%WCDE_QUARTO_COMMAND%" (
    echo Warning: %WCDE_QUARTO_COMMAND% not found in %WCDE_QUARTO_BIN%. Quarto features may not work as expected.
    set EXITCODE=1
    goto COMPLETE
)
rem --- Only add if not already present, so repeat calls don't duplicate it ---
echo %PATH% | findstr /I /C:"%WCDE_QUARTO_BIN%" >nul
if errorlevel 1 (
    echo Quarto found at %WCDE_QUARTO_BIN%. Adding to the PATH.
    set "PATH=%path%;%WCDE_QUARTO_BIN%"
) else (
    echo Quarto already on PATH at %WCDE_QUARTO_BIN%.
)

rem --- Return to caller ---
:COMPLETE
exit /b %EXITCODE%
