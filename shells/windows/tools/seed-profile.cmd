:: seed-profile.cmd - Snapshot your CURRENT default VS Code extension set into a
::   profile manifest, so a fresh isolation profile can reproduce it.
::     seed-profile.cmd ps        -> writes shells\windows\lib\vsprofiles\ps.txt
::   Reads the DEFAULT VS Code install's extensions (%USERPROFILE%\.vscode),
::   NOT any isolated profile. Run once to bootstrap a heavy profile like `ps`.
@echo off
setlocal
if "%~1"=="" (
    echo Usage: seed-profile.cmd ^<profile-label^>
    exit /b 2
)
set "_PROFILE=%~1"
set "_OUT=%~dp0..\lib\vsprofiles\%_PROFILE%.txt"

where /q code
if errorlevel 1 (
    echo Error: VS Code 'code' CLI not found in PATH. Open a launcher shell first.
    exit /b 1
)

echo # %_PROFILE%.txt - seeded from the default VS Code install on this machine.> "%_OUT%"
echo # common.txt is installed too. Edit freely; re-seed with seed-profile.cmd %_PROFILE%.>> "%_OUT%"
echo.>> "%_OUT%"
code --list-extensions >> "%_OUT%"
if errorlevel 1 (
    echo Error: `code --list-extensions` failed.
    exit /b 1
)
echo Seeded %_OUT% from the current default VS Code extension set.
endlocal
exit /b 0
