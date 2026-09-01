:: vale-env.cmd - Vale prose linter (style / usage checking for Markdown, LaTeX, text).
:: Vale is a system install; this only puts it on PATH.
::   * The VS Code extension (chrischinchilla.vale-vscode) is a thin client that shells
::     out to this binary -- with no `vale` on PATH the extension is silently inert.
::     That is the wcde "missing tool is a wcde gap" rule in its purest form.
::   * Vale is config-driven PER PROJECT: a repo needs its own .vale.ini, and
::     `vale sync` must be run once there to download the StylesPath packages
::     (write-good, proselint, alex ...). This module does not do that -- env scripts
::     set variables and PATH only, they do not touch disk or start processes.
@echo off
if not "%SHELL_VALE_ENV%0"=="0" exit /b 0
set SHELL_VALE_ENV=1
call "%~dp0requires.cmd" global
if %errorlevel% neq 0 exit /b %errorlevel%
echo ------------ vale
set WCDE_VALE_ACTIVE=1
set "WCDE_VALE_EXE="
:: Flat if-statements (not a parenthesized block) so %PATH% is not expanded at parse
:: time. The Chocolatey package unpacks the real binary under lib\Vale\tools;
:: %CHOCOLATEY_PATH%\bin holds only a shim. CHOCOLATEY_PATH comes from global-var.cmd.
set "VALE_HOME=%CHOCOLATEY_PATH%\lib\Vale\tools"
if not exist "%VALE_HOME%\vale.exe" set "VALE_HOME=%ProgramFiles%\Vale"
if exist "%VALE_HOME%\vale.exe" echo Adding Vale to path
if exist "%VALE_HOME%\vale.exe" set "PATH=%VALE_HOME%;%PATH%"
if exist "%VALE_HOME%\vale.exe" set "WCDE_VALE_EXE=%VALE_HOME%\vale.exe"
if not exist "%VALE_HOME%\vale.exe" echo Warning: vale.exe not found under CHOCOLATEY_PATH\lib\Vale\tools or ProgramFiles; install it with `choco install vale`.
exit /b 0
