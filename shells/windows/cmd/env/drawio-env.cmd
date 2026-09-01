:: drawio-env.cmd - draw.io diagram editor environment.
::   * Always sets WCDE_DRAWIO_ACTIVE so setup-vscode.cmd associates *.svg with the
::     VS Code draw.io editor (hediet.vscode-drawio-text).
::   * If the CLASSIC desktop install exists, adds it to PATH and sets
::     WCDE_DRAWIO_EXE. The Microsoft Store (MSIX) build has NO PATH entry
::     (C:\Program Files\WindowsApps is ACL-locked and launched by AUMID) --
::     win-drawio.cmd resolves and launches that itself.
@echo off
if not "%SHELL_DRAWIO_ENV%0"=="0" exit /b 0
set SHELL_DRAWIO_ENV=1
call "%~dp0requires.cmd" global
if %errorlevel% neq 0 exit /b %errorlevel%
echo ------------ drawio
set WCDE_DRAWIO_ACTIVE=1
set "WCDE_DRAWIO_EXE="
:: Flat if-statements (not a parenthesized block) so %PATH% is not expanded at
:: parse time. The classic installer/choco build lives here; the Store build does not.
set "DRAWIO_HOME=C:\Program Files\draw.io"
if exist "%DRAWIO_HOME%\draw.io.exe" echo Adding draw.io to path
if exist "%DRAWIO_HOME%\draw.io.exe" set "PATH=%DRAWIO_HOME%;%PATH%"
if exist "%DRAWIO_HOME%\draw.io.exe" set "WCDE_DRAWIO_EXE=%DRAWIO_HOME%\draw.io.exe"
if not exist "%DRAWIO_HOME%\draw.io.exe" echo Classic draw.io not on PATH; win-drawio.cmd will use the Microsoft Store app if installed.
exit /b 0
