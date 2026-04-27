@echo off
setlocal

rem --- Load your global baseline environment ---
call "%~dp0env\global-env.cmd"
call "%~dp0env\win-dev-env.cmd"
call "%~dp0env\texlive-env.cmd"
call "%~dp0env\sagemath-env.cmd"
call "%~dp0env\win-perl-env.cmd"
rem --- No MSYS2 paths added here ---
rem --- This is a pure Windows environment ---
rem --- Launch native Windows VS Code ---
call "%USERPROFILE%\AppData\Local\Programs\Microsoft VS Code\Code.exe" %*
set EXITCODE=%ERRORLEVEL%

endlocal & exit /b %EXITCODE%

