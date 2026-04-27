@echo off
setlocal
set WIN_PERL_RC=0
call "%~dp0lib\set-prompt.cmd" perl
rem --- Load global baseline environment ---
call "%~dp0env\win-perl-env.cmd"
rem --- No MSYS2, no MinGW, no UCRT64 ---
rem --- This is a pure Windows shell with Strawberry Perl ---
rem --- Launch a native Windows command prompt ---
%ComSpec% /k "title Windows Perl Shell"
set WIN_PERL_RC=%errorlevel%
call "%~dp0lib\restore-prompt.cmd"
if %WIN_PERL_RC% neq 0 (
    echo Windows Perl Shell exited with code %WIN_PERL_RC%
)
endlocal & exit /b %WIN_PERL_RC%
