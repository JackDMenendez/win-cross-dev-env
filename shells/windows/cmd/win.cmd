:: win.cmd - Launch the minimal native Windows shell with the shared repo command PATH.
@echo off
rem setup a basic windows cmdline environment
rem This shell provides the nvim editor and basic maintenance.
rem The old Chocolatey/unxUtils GNU commands are NO LONGER on PATH; use an
rem MSYS2 shell (UCRT64/MINGW64/CLANG64) for make/coreutils. There is access
rem to the other shells, each one being an isolated environment.
setlocal
set WIN_RC=0
rem --- create the (win) prompt
call "%~dp0lib\set-prompt.cmd" win
rem --- Load basic win-shell baseline environment ---
call "%~dp0env\requires.cmd" win vim
rem --- No MSYS2, no MinGW, no UCRT64 no development ---
rem --- This is a pure Windows minimal working shell ---
rem --- Launch a native Windows command prompt ---
%ComSpec% /k "title Windows Minimal Shell"
set WIN_RC=%errorlevel%
call "%~dp0tools\restore-prompt.cmd"
if %WIN_RC% neq 0 (
    echo Windows Minimal Shell exited with code %WIN_RC%
)
endlocal & exit /b %WIN_RC%

