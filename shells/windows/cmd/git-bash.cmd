:: git-bash.cmd - Launch Git Bash with the repo's Windows-side PATH bootstrap.
@echo off
setlocal
call "%~dp0env\git-bash-env.cmd"
git bash -defterm -no-start -here -msys
set EXITCODE=%ERRORLEVEL%
endlocal & exit /b %EXITCODE%
