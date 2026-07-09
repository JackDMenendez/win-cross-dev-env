:: vscode-isolation.cmd - Resolve per-profile VS Code isolation dirs, provision
::   extensions, and build the --user-data-dir/--extensions-dir launch args.
::
::   Contract (caller must satisfy):
::     - WCDE_VSCODE_PROFILE  is set to the isolation label (e.g. ps, web, ucrt64).
::     - WCDE_VSCODE_PATH      points at the VS Code install dir  (from vscode-env).
::     - WCDE_VSCODE_EXE_PATH  points at Code.exe                 (from vscode-env).
::   Argument:
::     %1 = the explicit target dir from the command line, or empty if none.
::          When non-empty  -> user-data is REPO-LOCAL   (customizable, gitignored).
::          When empty      -> user-data is USER-PROFILE (a stable personal copy).
::   Result (set in the CALLER's scope - this script is NOT setlocal'd):
::     WCDE_VSCODE_DEV_SHELL_ARGS = --user-data-dir "..." --extensions-dir "..."
::
::   Extensions always live per-profile under %USERPROFILE%\.vsisolation\<profile>\ext
::   and are shared across every repo opened with that profile (installed once).
::
::   Set WCDE_VSISO_DRYRUN=1 to resolve paths + touch gitignore WITHOUT installing
::   extensions or writing the provisioned marker (used for headless testing).
@echo off

if "%WCDE_VSCODE_PROFILE%"=="" (
    echo [vscode-isolation] ERROR: WCDE_VSCODE_PROFILE is not set; cannot isolate.
    exit /b 1
)

set "_VSISO_PROFILE=%WCDE_VSCODE_PROFILE%"
set "_VSISO_USERROOT=%USERPROFILE%\.vsisolation\%_VSISO_PROFILE%"
set "_VSISO_EXT=%_VSISO_USERROOT%\ext"

if "%~1"=="" (
    set "_VSISO_DATA=%_VSISO_USERROOT%\data"
    echo [vscode-isolation] profile=%_VSISO_PROFILE% ^(no target^): user-profile user-data
) else (
    set "_VSISO_DATA=%~f1\.vsisolation\%_VSISO_PROFILE%\data"
    echo [vscode-isolation] profile=%_VSISO_PROFILE% target=%~f1: repo-local user-data
    call :ensure_gitignore "%~f1"
)

if not exist "%_VSISO_DATA%" mkdir "%_VSISO_DATA%" >nul 2>&1
if not exist "%_VSISO_EXT%"  mkdir "%_VSISO_EXT%"  >nul 2>&1

call :seed_user_settings
call :provision

rem --- --sync off forces VS Code Settings Sync OFF on every isolated launch, so a
rem     stray sign-in can't refill a profile's ext dir with the full synced set.
rem     --new-window forces each profile to open in its own isolated instance,
rem     preventing profile collapse when switching between flavors. ---
set "WCDE_VSCODE_DEV_SHELL_ARGS=--sync off --new-window --no-sandbox --user-data-dir "%_VSISO_DATA%" --extensions-dir "%_VSISO_EXT%""
echo [vscode-isolation] args: %WCDE_VSCODE_DEV_SHELL_ARGS%

rem --- leave WCDE_VSCODE_DEV_SHELL_ARGS set; drop the scratch vars ---
set "_VSISO_PROFILE="
set "_VSISO_USERROOT="
set "_VSISO_EXT="
set "_VSISO_DATA="
set "_VSISO_CODECLI="
set "_VSISO_PROFDIR="
set "_VSISO_USERDIR="
set "_VSISO_USERSET="
set "_VSISO_SEEDSRC="
exit /b 0

:: ---------------------------------------------------------------------------
:seed_user_settings
rem A fresh isolated --user-data-dir does NOT inherit the global user settings,
rem so (a) it defaults to update.mode:default and auto-downloads VS Code updates
rem     - which grab the Inno Setup 'vscode-updating' mutex and block launchers -
rem and (b) it misses the user-scope Vim keybindings that ONLY take effect in
rem     user (not workspace) settings. Seed BOTH by copying the canonical
rem     lib\vsprofiles\user-settings.json, once, IF the user settings.json is
rem     absent (never clobber settings the user accumulated via the UI). Copying
rem     a template (vs echo) keeps the JSON readable and dodges cmd's <>-escaping.
set "_VSISO_USERDIR=%_VSISO_DATA%\User"
set "_VSISO_USERSET=%_VSISO_USERDIR%\settings.json"
set "_VSISO_SEEDSRC=%~dp0..\lib\vsprofiles\user-settings.json"
if exist "%_VSISO_USERSET%" goto :eof
if not exist "%_VSISO_SEEDSRC%" (
    echo [vscode-isolation] WARN: seed template missing: %_VSISO_SEEDSRC%
    goto :eof
)
if not exist "%_VSISO_USERDIR%" mkdir "%_VSISO_USERDIR%" >nul 2>&1
copy /y "%_VSISO_SEEDSRC%" "%_VSISO_USERSET%" >nul
echo [vscode-isolation] seeded isolated user settings from template into %_VSISO_USERSET%
goto :eof

:: ---------------------------------------------------------------------------
:ensure_gitignore
rem %1 = repo dir. Only touch a real git repo; add .vsisolation/ once.
setlocal
set "_R=%~1"
if not exist "%_R%\.git" ( endlocal & goto :eof )
set "_GI=%_R%\.gitignore"
if not exist "%_GI%" (
    > "%_GI%" echo .vsisolation/
    echo [vscode-isolation] created %_GI% with .vsisolation/
    endlocal & goto :eof
)
findstr /x /c:".vsisolation/" "%_GI%" >nul 2>&1
if errorlevel 1 (
    >> "%_GI%" echo .vsisolation/
    echo [vscode-isolation] appended .vsisolation/ to %_GI%
)
endlocal & goto :eof

:: ---------------------------------------------------------------------------
:provision
rem Install common.txt + <profile>.txt into the ext dir, once (marker-guarded).
set "_VSISO_MARK=%_VSISO_EXT%\.wcde-provisioned"
if exist "%_VSISO_MARK%" (
    echo [vscode-isolation] extensions already provisioned for %_VSISO_PROFILE%
    goto :eof
)
set "_VSISO_CODECLI=%WCDE_VSCODE_PATH%\bin\code.cmd"
if not exist "%_VSISO_CODECLI%" set "_VSISO_CODECLI=%WCDE_VSCODE_EXE_PATH%"
set "_VSISO_PROFDIR=%~dp0..\lib\vsprofiles"
echo [vscode-isolation] provisioning extensions for %_VSISO_PROFILE% ...
call :install_list "%_VSISO_PROFDIR%\common.txt"
call :install_list "%_VSISO_PROFDIR%\%_VSISO_PROFILE%.txt"
if "%WCDE_VSISO_DRYRUN%"=="1" (
    echo [vscode-isolation] DRYRUN: not writing provisioned marker
    goto :eof
)
> "%_VSISO_MARK%" echo provisioned %_VSISO_PROFILE%
goto :eof

:: ---------------------------------------------------------------------------
:install_list
rem %1 = manifest file. One extension id per line; # starts a comment.
setlocal enabledelayedexpansion
set "_LIST=%~1"
if not exist "%_LIST%" (
    echo [vscode-isolation] no manifest: %_LIST% ^(skipped^)
    endlocal & goto :eof
)
for /f "usebackq eol=# tokens=1 delims= " %%E in ("%_LIST%") do (
    if not "%%E"=="" (
        if "%WCDE_VSISO_DRYRUN%"=="1" (
            echo [vscode-isolation] DRYRUN install %%E
        ) else (
            echo [vscode-isolation] install %%E
            call "%_VSISO_CODECLI%" --extensions-dir "%_VSISO_EXT%" --install-extension %%E --force
        )
    )
)
endlocal & goto :eof
