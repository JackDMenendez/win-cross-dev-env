:: R-env.cmd - Set up the R environment for Windows development.
@echo off
if not "%SHELL_R_ENV%0"=="0" exit /b 0
set SHELL_R_ENV=1
call "%~dp0requires.cmd" global
if %errorlevel% neq 0 exit /b %errorlevel%
echo ------------ R
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
