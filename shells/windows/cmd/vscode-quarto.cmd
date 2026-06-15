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
echo Launching VS Code from the native Windows development environment (Quarto web repo)...
echo Parameters passed to this script: %*
rem --- Whatever happens here, stays here. We want to avoid any side effects on the caller's environment, so we use setlocal and endlocal to contain all changes within this script.

setlocal enabledelayedexpansion

Set EXITCODE=0
Set TARGET=

if "x%~1"=="x" (
    echo No target directory provided. Using current directory: %CD%
    set TARGET="%CD%"
) else (
    set TARGET="%~f1"
    echo param %~1 Target directory provided: !TARGET!
    if not exist !TARGET! (
        echo Error: Target directory not found: !TARGET!
        set EXITCODE=1
        goto COMPLETE
    )
)

rem --- Load only the lean web-authoring baseline ---
call "%~dp0env\win-env.cmd"
call "%~dp0pwsh-env.cmd"
call "%~dp0env\git-cli-env.cmd"
call "%~dp0env\R-env.cmd"
call "%~dp0env\quarto-env.cmd"
call "%~dp0env\vscode-env.cmd"
rem --- No MSVC, no pwsh (and its python.exe), no TeX/Sage/Perl ---
rem --- Python, if the site executes code cells, comes from the project venv ---
rem --- Launch native Windows VS Code ---
call "%~dp0..\tools\setup-vscode.cmd" %*
echo call %WCDE_VSCODE_EXE_PATH% %WCDE_VSCODE_DEV_SHELL_ARGS% %*
call %WCDE_VSCODE_EXE_PATH% %WCDE_VSCODE_DEV_SHELL_ARGS% %*
set EXITCODE=%ERRORLEVEL%

REM --- Return to caller with the exit code from VS Code ---
:COMPLETE
endlocal & exit /b %EXITCODE%
