:: build-live-tex-pdf.cmd - Build a PDF from a TeX source with latexmk under the TeX Live environment.
@echo off
setlocal

if "%~1"=="" (
    echo Usage: %~nx0 ^<tex-file^> [additional-latexmk-args]
    exit /b 1
)
call "%~dp0env\requires.cmd" global msys64 win-dev texlive
if %errorlevel% neq 0 (
    echo Error: %errorlevel% - required dependencies not found. Please ensure that you have the necessary tools installed.
    exit /b 1
)

where latexmk >nul 2>&1
if errorlevel 1 (
    echo latexmk was not found on PATH after loading the TeX Live environment.
    exit /b 1
)

latexmk -pdf -interaction=nonstopmode %*
set EXITCODE=%ERRORLEVEL%

endlocal & exit /b %EXITCODE%