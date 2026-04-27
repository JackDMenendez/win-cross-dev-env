@echo off
setlocal
prompt (win-dev)$_$p$g
rem --- Load global baseline environment ---
call "%~dp0env\global-env.cmd"
call "%~dp0env\win-dev-env.cmd"
call "%~dp0env\perl-env.cmd"
rem --- No MSYS2, no MinGW, no UCRT64 ---
rem --- This is a pure Windows dev shell ---

rem --- Launch a native Windows command prompt ---
cmd /k "title Windows Native Dev Shell"

set EXITCODE=%ERRORLEVEL%

endlocal & exit /b %EXITCODE%

