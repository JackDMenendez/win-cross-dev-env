@echo off
setlocal

call "%~dp0env\global-env.cmd"
call "%~dp0env\win-dev-env.cmd"

call "%~dp0..\tools\build-repo-venv.cmd" %*
set "BUILD_REPO_RC=%ERRORLEVEL%"

endlocal & exit /b %BUILD_REPO_RC%