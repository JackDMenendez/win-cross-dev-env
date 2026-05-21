:: texlive-env.cmd - Prepend TeX Live binaries to PATH.
@echo off

rem --- isolate tool chain contaminator ---
set PATH=%path%;C:\texlive\2026\bin\windows
rem --- Global variables shared by all environments ---

rem --- Return to caller ---
exit /b 0

