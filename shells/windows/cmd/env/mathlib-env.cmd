:: mathlib-env.cmd - Mathlib: the Lean mathematical library.
@echo off
if not "%SHELL_MATHLIB_ENV%0"=="0" exit /b 0
set SHELL_MATHLIB_ENV=1
:: Mathlib is meaningless without Lean, so require lean-env (which puts
:: elan/lean/lake on PATH) in addition to the global baseline. This makes the
:: env self-sufficient regardless of a launcher's require ordering.
call "%~dp0requires.cmd" global lean
if %errorlevel% neq 0 exit /b %errorlevel%
echo ------------ mathlib
:: WCDE_MATHLIB_ACTIVE marks Mathlib as active for this session; setup-vscode.cmd
:: can gate Mathlib-specific VS Code settings on it (the way it gates the vim
:: block on WCDE_VSVIM_ACTIVE).
set WCDE_MATHLIB_ACTIVE=1
:: No PATH change of its own: Mathlib is a per-project Lean library that `lake`
:: fetches into <project>\.lake\packages\mathlib -- there is no machine-wide bin
:: dir. elan/lean/lake come from lean-env (required above).
exit /b 0
