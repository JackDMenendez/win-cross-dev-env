@echo off
setlocal

call "%~dp0env\global-env.cmd"
call "%~dp0env\win-dev-env.cmd"

call "%~dp0..\tools\build-canonical-venv.cmd" %*
set "BUILD_CANONICAL_RC=%ERRORLEVEL%"

endlocal & exit /b %BUILD_CANONICAL_RC%