:: R-env.cmd - Set up the R environment for Windows development.
@echo off

rem --- NOTE: This script is idempotent by checking PATH membership, NOT by a
rem     boolean SHELL_R_ENV guard. A boolean guard is unsafe here because
rem     global-env.cmd unconditionally RESETS PATH; if the guard had already
rem     tripped (flag inherited as 1, e.g. ucrt64-env.cmd calls global-env
rem     BEFORE R-env) the R bin would be stranded off PATH. Checking PATH
rem     directly survives both PATH resets and repeated calls. Same fix as
rem     quarto-env.cmd. SHELL_R_ENV is still published for external consumers.
set SHELL_R_ENV=1

rem --- Auto-detect the newest R install (most recently modified R-* dir).
rem     'dir /od' lists oldest-first, so the loop's final assignment wins =
rem     newest. Honor a pre-set WCDE_R_HOME; no setlocal (env-script rule),
rem     so this avoids delayed expansion by letting the last iteration win.
set "WCDE_R_ROOT=C:\Program Files\R"
if not defined WCDE_R_HOME (
    for /f "delims=" %%I in ('dir /b /ad /od "%WCDE_R_ROOT%\R-*" 2^>nul') do set "WCDE_R_HOME=%WCDE_R_ROOT%\%%I"
)
if not defined WCDE_R_HOME set "WCDE_R_HOME=%WCDE_R_ROOT%\R-4.6.0"
set "WCDE_R_BIN_PATH=%WCDE_R_HOME%\bin\x64"

rem --- Add R to PATH only if it exists on disk and is not already present, so
rem     repeat calls don't duplicate it and a PATH reset re-adds it. ---
if not exist "%WCDE_R_BIN_PATH%\R.exe" goto :COMPLETE
echo %PATH% | findstr /I /C:"%WCDE_R_BIN_PATH%" >nul
if errorlevel 1 (
    set "PATH=%PATH%;%WCDE_R_BIN_PATH%"
) else (
    rem R already on PATH; nothing to do.
)

rem --- Return to caller ---
:COMPLETE
exit /b 0
