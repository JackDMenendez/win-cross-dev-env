:: vscode-write.cmd - Launch VS Code for creative writing / long-form prose.
::   Deliberately lean, in the spirit of vscode-quarto: this flavor's toolset is an
::   authoring-and-conversion pipeline, not a compiler stack.
::   Loaded here (and why):
::     pandoc  - the manuscript pipeline: Markdown -> DOCX (what editors want), EPUB,
::               ODT, RTF, HTML.
::     miktex  - the TeX engine Pandoc shells out to for PDF; without it `pandoc -o
::               x.pdf` fails even though every other format works.
::     quarto  - HTML / website rendering of the same sources.
::     calibre - `ebook-convert`, for polishing and previewing the EPUB afterwards.
::     vale    - prose style linter; chrischinchilla.vale-vscode is a thin client over
::               this binary and does nothing without it on PATH.
::   NOT loaded here (and why):
::     python      - prose needs no interpreter, and setup-vscode.cmd writes
::                   python.defaultInterpreterPath only when `python` is in requires,
::                   so leaving it out keeps the venv out of a writing workspace.
::     win-dev     - MSVC / CMake / doxygen compile nothing in a manuscript.
::     msys2-tools - no gcc/make here; native Windows tools are the whole toolset.
::     sagemath, lean, ghcup - unrelated toolchains.
@echo off
setlocal enabledelayedexpansion
call "%~dp0lib\vscode-launcher-lib.cmd" "%~1"
if %errorlevel% neq 0 goto COMPLETE
rem --- Authoring baseline; `vscode` pulls in pwsh for the integrated terminal ---
call "%~dp0env\requires.cmd" global win git-cli pandoc miktex quarto calibre vale vsvim nvim vscode
if %errorlevel% neq 0 exit /b 1
set "WCDE_VSCODE_PROFILE=write"
call "%~dp0..\tools\vscode-isolation.cmd" "!TARGET!"
call "%~dp0..\tools\setup-vscode.cmd" %*
call "%WCDE_VSCODE_EXE_PATH%" %WCDE_VSCODE_DEV_SHELL_ARGS% %*
:COMPLETE
endlocal & exit /b %ERRORLEVEL%
