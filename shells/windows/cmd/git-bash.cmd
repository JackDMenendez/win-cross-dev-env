:: git-bash.cmd - Launch git bash shell
@echo off
setlocal
call "%~dp0env\git-bash-env.cmd"
git bash -defterm -no-start -here -msys
set EXITCODE=%ERRORLEVEL%
endlocal & exit /b %EXITCODE%
