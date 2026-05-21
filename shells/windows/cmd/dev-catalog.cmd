:: dev-catalog.cmd - Print the generated command catalog from any default Windows shell in the repo.
@echo off
setlocal

set "CATALOG_PATH=%~dp0..\..\..\catalog.md"

if not exist "%CATALOG_PATH%" (
    echo Catalog file not found: "%CATALOG_PATH%"
    exit /b 1
)

type "%CATALOG_PATH%"
set "EXITCODE=%ERRORLEVEL%"

endlocal & exit /b %EXITCODE%