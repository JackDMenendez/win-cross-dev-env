:: vscode-exp-tex.cmd - Bring up a python environment with laytex tools
@echo off
setlocal enabledelayedexpansion
call "%~dp0lib\vscode-launcher-lib.cmd" "%~1"
if %errorlevel% neq 0 goto COMPLETE
rem --- Load your global baseline environment ---
rem     msys2-tools is last so C:\msys64\ucrt64\bin + C:\msys64\usr\bin are
rem     APPENDED to PATH (native Windows keeps precedence; ucrt64 toolchain is
rem     still reachable for gcc/make/pkg-config etc.).
call "%~dp0env\requires.cmd" global win git-cli python laytex vsvim nvim vscode msys2-tools
if %errorlevel% neq 0 exit /b 1
rem --- Native Windows environment; ucrt64/usr bin appended via msys2-tools ---
rem --- Isolate this flavor: own user-data + extensions dir (see lib\vsprofiles) ---
rem     Own profile label (NOT python) so it gets its own isolated ext dir +
rem     exp-tex.txt manifest (python + LaTeX), not the pure-python flavor's set.
set "WCDE_VSCODE_PROFILE=exp-tex"
call "%~dp0..\tools\vscode-isolation.cmd" "!TARGET!"
call "%~dp0..\tools\setup-vscode.cmd" %*
call "%WCDE_VSCODE_EXE_PATH%" %WCDE_VSCODE_DEV_SHELL_ARGS% %*
:COMPLETE
endlocal & exit /b %ERRORLEVEL%
