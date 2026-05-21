:: build-catalog.cmd - Regenerate catalog.md from the current .cmd and .sh inventory.
@echo off
setlocal

call "%~dp0env\global-env.cmd"
call "%~dp0env\win-dev-env.cmd"

python "%~dp0..\..\..\tools\generate_catalog.py"
set "BUILD_CATALOG_RC=%ERRORLEVEL%"

endlocal & exit /b %BUILD_CATALOG_RC%