:: vscode-quarto.cmd - Launch VS Code for a Quarto *website* / web-publishing repo.
::   Deliberately lean: only the env needed to author and render an HTML site.
::   NOT loaded here (and why):
::     win-dev-env  - pulls in MSVC (vcvars64), CMake, make, doxygen, Tcl AND
::                    pwsh-env, which puts PowerShell's bundled python.exe on PATH.
::                    A web repo compiles nothing and should get Python from the
::                    project venv (activated by setup-vscode.cmd), not from pwsh.
::     texlive-env  - LaTeX is only needed for PDF output; a website renders HTML.
::     sagemath-env - not used for web authoring.
::     win-perl-env - only a TeX/latexindent dependency.
@echo off
setlocal enabledelayedexpansion
call "%~dp0lib\vscode-launcher-lib.cmd" "%~1"
if %errorlevel% neq 0 goto COMPLETE
rem --- Load only the lean web-authoring baseline ---
call "%~dp0env\requires.cmd" global git-cli quarto vsvim nvim vscode
if %errorlevel% neq 0 exit /b 1
rem --- No MSVC, no pwsh (and its python.exe), no TeX/Sage/Perl ---
rem --- Python, if the site executes code cells, comes from the project venv ---
set "WCDE_VSCODE_PROFILE=web"
call "%~dp0..\tools\vscode-isolation.cmd" "!TARGET!"
call "%~dp0..\tools\setup-vscode.cmd" %*
call "%WCDE_VSCODE_EXE_PATH%" %WCDE_VSCODE_DEV_SHELL_ARGS% %*
:COMPLETE
endlocal & exit /b %ERRORLEVEL%
