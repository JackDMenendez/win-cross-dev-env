@echo off
setlocal
set WIN_CHOCO_RC=0
call "%~dp0lib\set-prompt.cmd" choco
rem --- Load global baseline environment ---
call "%~dp0env\win-choco-env.cmd"
rem --- No MSYS2, no MinGW, no UCRT64 ---
rem --- This is a pure Windows shell with Chocolatey ---
rem --- Launch a native Windows command prompt ---
sudo -E %ComSpec% /k "title Windows Choco Shell"
set WIN_CHOCO_RC=%errorlevel%
call "%~dp0lib\restore-prompt.cmd"
if %WIN_CHOCO_RC% neq 0 (
    echo Windows Choco Shell exited with code %WIN_CHOCO_RC%
)
endlocal & exit /b %WIN_CHOCO_RC%
