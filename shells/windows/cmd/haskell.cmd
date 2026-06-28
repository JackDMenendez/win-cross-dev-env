:: haskell.cmd - Launch GHCi (Haskell interactive environment).
@echo off
setlocal

call "%~dp0env\ghcup-env.cmd"

ghci %*

set EXITCODE=%ERRORLEVEL%
endlocal & exit /b %EXITCODE%
