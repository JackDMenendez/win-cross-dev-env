:: vs-dev.cmd - Launch a Visual Studio developer command shell on top of the repo baseline.
@echo off
setlocal
prompt (vs-dev)$_$p$g
rem --- Load global baseline environment ---
call "%~dp0env\requires.cmd" global win-dev
if %errorlevel% neq 0 (
    echo Error: %errorlevel% - required dependencies not found. Please ensure that you have the necessary tools installed.
    exit /b 1
)
rem --- No MSYS2, no MinGW, no UCRT64 ---
rem --- This is a Visual Studio 2026 Windows dev shell ---
pushd "C:\Program Files\Microsoft Visual Studio\18\Community\"
call "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat"
popd
rem --- Launch a native Windows command prompt ---
cmd /k "title Visual Studio 2026 Dev Shell"

set EXITCODE=%ERRORLEVEL%
endlocal & exit /b %EXITCODE%