:: calibre-env.cmd - Calibre e-book toolchain. Calibre is a system install; this only
:: puts it on PATH.
::   * The point of this module is the CLI, not the GUI: `ebook-convert` (EPUB/MOBI/AZW3
::     conversion and polishing), plus ebook-meta / ebook-polish / calibredb.
::   * Pandoc alone already emits a VALID EPUB. Calibre is for the step after that --
::     converting between e-book formats, fixing metadata, and previewing the result --
::     so a flavor that only exports DOCX/PDF does not need this module.
@echo off
if not "%SHELL_CALIBRE_ENV%0"=="0" exit /b 0
set SHELL_CALIBRE_ENV=1
call "%~dp0requires.cmd" global
if %errorlevel% neq 0 exit /b %errorlevel%
echo ------------ calibre
set WCDE_CALIBRE_ACTIVE=1
set "WCDE_CALIBRE_EXE="
:: Flat if-statements (not a parenthesized block) so %PATH% is not expanded at parse
:: time. Calibre installs to ProgramFiles\Calibre2 (the "2" is part of the name, not a
:: version suffix to be updated). Probe ebook-convert.exe, the CLI this module is for.
set "CALIBRE_HOME=%ProgramFiles%\Calibre2"
if not exist "%CALIBRE_HOME%\ebook-convert.exe" set "CALIBRE_HOME=%ProgramFiles(x86)%\Calibre2"
if exist "%CALIBRE_HOME%\ebook-convert.exe" echo Adding Calibre to path
if exist "%CALIBRE_HOME%\ebook-convert.exe" set "PATH=%CALIBRE_HOME%;%PATH%"
if exist "%CALIBRE_HOME%\ebook-convert.exe" set "WCDE_CALIBRE_EXE=%CALIBRE_HOME%\ebook-convert.exe"
if not exist "%CALIBRE_HOME%\ebook-convert.exe" echo Warning: ebook-convert.exe not found under ProgramFiles\Calibre2; install it with `choco install calibre`.
exit /b 0
