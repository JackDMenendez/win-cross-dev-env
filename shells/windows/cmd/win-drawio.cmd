:: win-drawio.cmd - Open the draw.io editor rooted at a target directory. Handles
:: both the classic desktop install and the Microsoft Store (MSIX) package.
::   Usage: win-drawio.cmd [dir]   (defaults to the current directory)
:: Plain setlocal (NO delayed expansion) so the '!' in the Store AUMID survives.
@echo off
setlocal
call "%~dp0lib\vscode-launcher-lib.cmd" "%~1"
if %errorlevel% neq 0 goto COMPLETE
call "%~dp0env\requires.cmd" global drawio
if %errorlevel% neq 0 exit /b 1

rem --- Classic desktop install: run the exe with cwd = target directory. ---
if defined WCDE_DRAWIO_EXE (
    echo Starting draw.io in "%TARGET%"
    pushd "%TARGET%"
    start "draw.io" "%WCDE_DRAWIO_EXE%"
    popd
    goto COMPLETE
)

rem --- Microsoft Store / MSIX: WindowsApps is ACL-locked and version-stamped, so
rem     launch by AUMID via explorer shell:AppsFolder. Resolve the AUMID at run
rem     time (survives version/publisher changes). A Store app cannot be given a
rem     working directory from the CLI -- it just opens. ---
set "PS=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
set "WCDE_DRAWIO_AUMID="
for /f "usebackq delims=" %%A in (`%PS% -NoProfile -Command "$p=Get-AppxPackage draw.io.draw.ioDiagrams; if($p){$p.PackageFamilyName + '!draw.io.draw.ioDiagrams'}" 2^>nul`) do set "WCDE_DRAWIO_AUMID=%%A"
if not defined WCDE_DRAWIO_AUMID goto NO_DRAWIO
echo Starting the draw.io Store app for "%TARGET%"
explorer.exe "shell:AppsFolder\%WCDE_DRAWIO_AUMID%"
goto COMPLETE

:NO_DRAWIO
echo Error: draw.io not found -- neither the classic install nor the Store package.
echo Install from the Microsoft Store, or:  choco install drawio
:COMPLETE
endlocal & exit /b %ERRORLEVEL%
