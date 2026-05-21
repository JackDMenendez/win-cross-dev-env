:: ucrt64.cmd - Launch the MSYS2 UCRT64 shell with the repo startup wrapper loaded.
@echo off
setlocal

call "%~dp0env\ucrt64-env.cmd"

C:\msys64\msys2_shell.cmd -defterm -no-start -here -ucrt64 %*

set EXITCODE=%ERRORLEVEL%
endlocal & exit /b %EXITCODE%

