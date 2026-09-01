:: pandoc-env.cmd - Pandoc universal document converter (Markdown -> DOCX / EPUB /
:: ODT / HTML / RTF / LaTeX ...). Pandoc is a system install; this only puts it on PATH.
::   * The Chocolatey package just runs the upstream per-user MSI, which installs to
::     %LOCALAPPDATA%\Pandoc; `pandoc` then resolves ONLY through a shim in
::     %CHOCOLATEY_PATH%\bin. Pointing at the real directory keeps a lean flavor from
::     having to pull in the whole win-choco chain (and ghcup with it) for one tool.
::   * PDF output shells out to a TeX engine -- a caller that wants PDF must also put
::     `miktex` in its requires list.
@echo off
if not "%SHELL_PANDOC_ENV%0"=="0" exit /b 0
set SHELL_PANDOC_ENV=1
call "%~dp0requires.cmd" global
if %errorlevel% neq 0 exit /b %errorlevel%
echo ------------ pandoc
:: WCDE_PANDOC_ACTIVE marks Pandoc as active for this session (parallels the other
:: *_ACTIVE markers; available to setup-vscode.cmd if ever needed).
set WCDE_PANDOC_ACTIVE=1
set "WCDE_PANDOC_EXE="
:: Flat if-statements (not a parenthesized block) so %PATH% is not expanded at
:: parse time. Per-user MSI location first, then a system-wide install.
set "PANDOC_HOME=%LOCALAPPDATA%\Pandoc"
if not exist "%PANDOC_HOME%\pandoc.exe" set "PANDOC_HOME=%ProgramFiles%\Pandoc"
if exist "%PANDOC_HOME%\pandoc.exe" echo Adding Pandoc to path
if exist "%PANDOC_HOME%\pandoc.exe" set "PATH=%PANDOC_HOME%;%PATH%"
if exist "%PANDOC_HOME%\pandoc.exe" set "WCDE_PANDOC_EXE=%PANDOC_HOME%\pandoc.exe"
if not exist "%PANDOC_HOME%\pandoc.exe" echo Warning: pandoc.exe not found under LOCALAPPDATA or ProgramFiles; install it with `choco install pandoc`.
exit /b 0
