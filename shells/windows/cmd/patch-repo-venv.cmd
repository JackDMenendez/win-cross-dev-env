:: patch-repo-venv.cmd - Wrapper that patches a repo-local Windows Python virtual environment.
@echo off
setlocal

call "%~dp0env\global-env.cmd"
call "%~dp0env\win-dev-env.cmd"

call "%~dp0..\tools\patch-repo-venv.cmd" %*
set "PATCH_REPO_RC=%ERRORLEVEL%"

endlocal & exit /b %PATCH_REPO_RC%