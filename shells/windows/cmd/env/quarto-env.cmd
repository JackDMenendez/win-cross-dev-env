:: quarto-env.cmd - Add Quarto to the PATH if it is installed in the default location.
@echo off

if not "%SHELL_QUARTO_ENV%0"=="0" exit /b 0

rem --- Global variables shared by all environments ---
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
echo Quarto found at %WCDE_QUARTO_BIN%. Adding to the PATH.
set "PATH=%path%;%WCDE_QUARTO_BIN%"

rem --- Return to caller ---
:COMPLETE
exit /b %EXITCODE%