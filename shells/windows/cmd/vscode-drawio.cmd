:: vscode-drawio.cmd - Launch VS Code with the draw.io diagram editor plus the
:: full toolset vscode-lean provides (Lean 4 / Mathlib / graphviz / LaTeX / ucrt64).
@echo off
setlocal enabledelayedexpansion
call "%~dp0lib\vscode-launcher-lib.cmd" "%~1"
if %errorlevel% neq 0 goto COMPLETE
rem --- Same requires chain as vscode-lean.cmd, plus `drawio`. drawio-env sets
rem     WCDE_DRAWIO_ACTIVE so setup-vscode.cmd writes the *.svg -> draw.io editor
rem     association; msys2-tools stays last so ucrt64/msys2 is appended to PATH. ---
call "%~dp0env\requires.cmd" global win pwsh git-cli python miktex vsvim nvim lean mathlib graphviz drawio vscode msys2-tools
if %errorlevel% neq 0 exit /b 1
set "WCDE_VSCODE_PROFILE=drawio"
call "%~dp0..\tools\vscode-isolation.cmd" "!TARGET!"
call "%~dp0..\tools\setup-vscode.cmd" %*
call "%WCDE_VSCODE_EXE_PATH%" %WCDE_VSCODE_DEV_SHELL_ARGS% %*
:COMPLETE
endlocal & exit /b %ERRORLEVEL%
