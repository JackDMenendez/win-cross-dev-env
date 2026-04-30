:: mingw64-env.cmd - Basic Windows CLI Env Setup
@echo off
if not "%SHELL_MINGW64_ENV%0"=="0" exit /b 0
set SHELL_MINGW64_ENV=1

call "%~dp0global-env.cmd"

set "DEV_SHELL_SUBSYSTEM=MINGW64"
set "DEV_SHELL_VENV_SUFFIX=mingw64"
set "DEV_SHELL_DEFAULT_VENV="
set "DEV_SHELL_ACTIVE_VENV_KIND="
set "DEV_SHELL_ACTIVE_VENV_PATH="
set "VIRTUAL_ENV="
set "VIRTUAL_ENV_PROMPT="
set "_OLD_VIRTUAL_PATH="
set "_OLD_VIRTUAL_PROMPT="

set MSYSTEM=MINGW64
set CHERE_INVOKING=1
set MSYS2_PATH_TYPE=inherit
set "PROMPT_COMMAND=unset PROMPT_COMMAND; . '%DEV_SHELL_POSIX_PATH%/shells/bash/mingw64/lib/startup-wrapper.sh'"

rem --- Compiler environment for pip builds ---
set CC=/mingw64/bin/gcc
set CXX=/mingw64/bin/g++
set PKG_CONFIG_PATH=/mingw64/lib/pkgconfig:/mingw64/share/pkgconfig

rem --- Correct PATH layering ---
rem 1. dev-shell tools
set PATH=%DEV_SHELL_PATH%\shells\bash;%PATH%
set PATH=%DEV_SHELL_PATH%\shells\bash\lib;%PATH%
rem 2. Git (Windows-native)
set PATH=%ProgramFiles%\Git\cmd;%PATH%

exit /b 0