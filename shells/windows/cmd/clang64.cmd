:: clang64.cmd - Launch the MSYS2 CLANG64 shell with the repo startup wrapper loaded.
@echo off
setlocal

call "%~dp0env\clang64-env.cmd"

C:\msys64\msys2_shell.cmd -defterm -no-start -here -clang64

set EXITCODE=%ERRORLEVEL%
endlocal & exit /b %EXITCODE%
