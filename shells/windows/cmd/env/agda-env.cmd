:: agda-env.cmd - Add Agda to the PATH and set up UCRT64 environment for MSYS2 libraries.
@echo off
rem Agda environment setup
if not "%SHELL_AGDA_ENV%0"=="0" exit /b 0

set SHELL_AGDA_ENV=1
call "%~dp0requires.cmd" global ghcup
if %errorlevel% neq 0 exit /b %errorlevel%
eche ------------ agda
rem --- Add Agda to the PATH ---
if exist "%GHCUP_INSTALL_BASE_PREFIX%\bin" (
    echo Adding Agda to PATH from %GHCUP_INSTALL_BASE_PREFIX%\bin
    set PATH=%GHCUP_INSTALL_BASE_PREFIX%\bin;%PATH%
) else if exist "%GHCUP_INSTALL_BASE_PREFIX%" (
    echo Adding Agda to PATH from %GHCUP_INSTALL_BASE_PREFIX%
    set PATH=%GHCUP_INSTALL_BASE_PREFIX%;%PATH%
) else (
    echo Warning: Agda not found in %GHCUP_INSTALL_BASE_PREFIX%
)

rem --- Return to caller ---
exit /b 0
