:: nvim-env.cmd - Prepend the native-Windows Neovim bin dir to PATH.
:: global-env resets PATH to bare System32, so the canonical native Neovim
:: (C:\tools\neovim) is otherwise unreachable inside a launcher. Prepending it
:: here makes ONE canonical `nvim` the winner over C:\msys64\*\bin\nvim.exe, and
:: gives the VS Code Vim extension a real `nvim` on PATH for its Neovim
:: ex-command integration (vim.enableNeovim in vsprofiles\user-settings.json).
:: Prepend (highest priority) on purpose: call this LAST in a requires list so
:: the native build wins over any toolchain nvim added by an earlier -env.
@echo off
if not "%SHELL_NVIM_ENV%0"=="0" exit /b 0
set SHELL_NVIM_ENV=1
call "%~dp0requires.cmd" global
if %errorlevel% neq 0 exit /b %errorlevel%
echo ------------ nvim
:: The following flag is used by the VS Code Vim extension to detect that a native Neovim 
:: is available on PATH. It is not used by any other shell or toolchain.
set WCDE_NVIM_ACTIVE=1
:: We need the nvim path for the vim extension integraion.
set WCDE_NVIM_PATH=C:\tools\neovim\nvim-win64\bin
set WCDE_NVIM_FULL_PATH=C:\tools\neovim\nvim-win64\bin\nvim.exe
if exist "%WCDE_NVIM_PATH%" set "PATH=%WCDE_NVIM_PATH%;%PATH%"
if exist "%WCDE_NVIM_PATH%" echo Prepended native Neovim (%WCDE_NVIM_PATH%) to PATH
if not exist "%WCDE_NVIM_PATH%" echo Warning: native Neovim not found at %WCDE_NVIM_PATH%; relying on existing PATH
exit /b 0
