@echo off
rem setup a basic windows cmdline environments
rem This shell provide the nvim editer and basic maintenance
rem using chocolatey
rem Some ancient GNU unix-like commands are available. There is
rem access to the other shells with each one being an isolated
rem environment.
setlocal
set WIN_RC=0
rem --- create the (win) prompt
call "%~dp0lib\set-prompt.cmd" win
rem --- Load basic win-shell baseline environment ---
call "%~dp0env\win-env.cmd"
rem --- No MSYS2, no MinGW, no UCRT64 no development ---
rem --- This is a pure Windows minimal working shell ---
rem --- Launch a native Windows command prompt ---
%ComSpec% /k "title Windows Minimal Shell"
set WIN_RC=%errorlevel%
call "%~dp0lib\restore-prompt.cmd"
if %WIN_RC% neq 0 (
    echo Windows Minimal Shell exited with code %WIN_RC%
)
endlocal & exit /b %WIN_RC%

