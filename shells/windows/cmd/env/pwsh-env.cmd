:: pwsh-env.cmd - Add PowerShell to the PATH if it is installed in the default location.
@echo off

if not "%SHELL_PWSH_ENV%0"=="0" exit /b 0

set SHELL_PWSH_ENV=1

rem --- Prerequisite: Load the global environment variables ---
call "%~dp0global-var.cmd"

echo Setting up PowerShell environment variables and PATH...
REM --- Global variables shared by all environments ---
SET WCDE_POWERSHELL_COMMAND=pwsh.exe
:: Changed to path to a standalone PowerShell so that the windows store version does not 
:: pollute the env with other tools.
if not defined WCDE_LOCAL_WINDOWS_APPS set WCDE_LOCAL_WINDOWS_APPS=%ProgramFiles%\PowerShell\7
SET WCDE_POWERSHELL_COMMAND_PATH="%WCDE_LOCAL_WINDOWS_APPS%\%WCDE_POWERSHELL_COMMAND%"

echo PowerShell command path set to: %WCDE_POWERSHELL_COMMAND_PATH%

REM --- Add PowerShell to the PATH if it is installed in the default location ---
if not exist %WCDE_POWERSHELL_COMMAND_PATH% (
    echo Warning: %WCDE_POWERSHELL_COMMAND% not found in %WCDE_LOCAL_WINDOWS_APPS%. PowerShell features may not work as expected.
    exit /b 1
)
echo PowerShell found at %WCDE_POWERSHELL_COMMAND_PATH%. Adding %WCDE_LOCAL_WINDOWS_APPS% to the end of the PATH.
set PATH=%path%;%WCDE_LOCAL_WINDOWS_APPS%

rem --- Return to caller ---
echo PowerShell environment variables and PATH set up.
exit /b 0
