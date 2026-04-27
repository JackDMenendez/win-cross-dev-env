@echo off
setlocal

if "%~1"=="" (
    echo Usage: %~nx0 ^<tex-file^> [additional-latexmk-args]
    exit /b 1
)

call "%~dp0env\global-env.cmd"
call "%~dp0env\texlive-env.cmd"

set "PATH=C:\Strawberry\perl\bin;C:\Strawberry\c\bin;%PATH%"

where latexmk >nul 2>&1
if errorlevel 1 (
    echo latexmk was not found on PATH after loading the TeX Live environment.
    exit /b 1
)

latexmk -pdf -interaction=nonstopmode %*
set EXITCODE=%ERRORLEVEL%

endlocal & exit /b %EXITCODE%