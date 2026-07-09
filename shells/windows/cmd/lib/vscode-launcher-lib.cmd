:: vscode-launcher-lib.cmd - Validate target directory for long-form launchers
:: 
:: Usage:
::   For long-form launchers (with target validation):
::     @echo off
::     setlocal enabledelayedexpansion
::     call "%~dp0lib\vscode-launcher-lib.cmd" "%~1"
::     if %errorlevel% neq 0 goto COMPLETE
::     call "%~dp0env\requires" global win git-cli ... vscode ...
::     if %errorlevel% neq 0 exit /b 1
::     set "WCDE_VSCODE_PROFILE=ps"
::     call "%~dp0..\tools\vscode-isolation.cmd" "%TARGET%"
::     call "%~dp0..\tools\setup-vscode.cmd" %*
::     call "%WCDE_VSCODE_EXE_PATH%" %WCDE_VSCODE_DEV_SHELL_ARGS% %*
::     :COMPLETE
::     endlocal & exit /b %ERRORLEVEL%
::
::   For short-form launchers (minimal, no validation):
::     @echo off
::     setlocal
::     call "%~dp0env\requires.cmd" global ... vscode
::     if %errorlevel% neq 0 exit /b 1
::     set "WCDE_VSCODE_PROFILE=miktex"
::     call "%~dp0..\tools\vscode-isolation.cmd" "%~1"
::     call "%WCDE_VSCODE_EXE_PATH%" %WCDE_VSCODE_DEV_SHELL_ARGS% %*
::     endlocal & exit /b %ERRORLEVEL%
::
:: Validates target directory (if provided) and sets TARGET variable.
:: Returns: 0 on success, 1 if target not found
@echo off
set "TARGET="
if "x%~1"=="x" (
    echo No target directory provided. Using current directory: %CD%
    set "TARGET=%CD%"
    exit /b 0
)
rem --- Target provided. Keep these as flat statements (NOT inside a parenthesized
rem     block): cmd expands %TARGET% at parse time for a whole block, which would
rem     read the pre-set empty value and always fail the exist-check. ---
set "TARGET=%~f1"
echo Target directory provided: %TARGET%
if not exist "%TARGET%" (
    echo Error: Target directory not found: %TARGET%
    exit /b 1
)
exit /b 0
