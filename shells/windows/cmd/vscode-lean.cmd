:: vscode-lean.cmd - Launch VS Code with the Lean 4 / Mathlib theorem-proving toolset on PATH.
@echo off
setlocal enabledelayedexpansion
call "%~dp0lib\vscode-launcher-lib.cmd" "%~1"
if %errorlevel% neq 0 goto COMPLETE
rem --- Load your global baseline environment ---
rem     msys2-tools is last so C:\msys64\ucrt64\bin + C:\msys64\usr\bin are
rem     APPENDED to PATH (native Windows keeps precedence; ucrt64 toolchain is
rem     still reachable for gcc/make/pkg-config etc.).
call "%~dp0env\requires.cmd" global win git-cli python miktex vsvim nvim lean mathlib graphviz vscode msys2-tools
if %errorlevel% neq 0 exit /b 1
set "WCDE_VSCODE_PROFILE=lean"
call "%~dp0..\tools\vscode-isolation.cmd" "!TARGET!"
call "%~dp0..\tools\setup-vscode.cmd" %*
call "%WCDE_VSCODE_EXE_PATH%" %WCDE_VSCODE_DEV_SHELL_ARGS% %*
:COMPLETE
endlocal & exit /b %ERRORLEVEL%

