@echo off
setlocal
prompt (vs-dev)$_$p$g
rem --- Load global baseline environment ---
call "%~dp0env\global-env.cmd"
call "%~dp0env\win-dev-env.cmd"
rem --- No MSYS2, no MinGW, no UCRT64 ---
rem --- This is a Visual Studio 2026 Windows dev shell ---
pushd "C:\Program Files\Microsoft Visual Studio\18\Community\"
call "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat"
popd
rem --- Launch a native Windows command prompt ---
cmd /k "title Visual Studio 2026 Dev Shell"

set EXITCODE=%ERRORLEVEL%

endlocal & exit /b %EXITCODE%

