# Handoff Notes

## Project Purpose

`dev-shell` is a reproducible Windows development and experiment-execution environment.

Primary motivation:

- Run falsifiable Python experiments reliably on the author's machine and on other Windows machines.
- Support research-code reproducibility for a physics paper.
- Provide a generally useful Windows development-shell framework with explicit toolchain and virtual-environment control.

## Important Context From Prior Work

- The repo is intended to be published on GitHub and referenced from the paper's README.
- The repo must not require installation at `C:\dev-shell`.
- Python environment selection must be predictable and visible, especially for MSYS2 subsystem shells.

## Virtual Environment Rules

Current intended precedence for shell activation:

1. Repo-local `.venv-<subsystem>`
2. Repo-local `.venv`
3. User-level `.venv-<subsystem>`
4. User-level `.venv`

This was aligned so subsystem shells behave more like `win-dev.cmd` when no subsystem-specific venv exists.

## Recent Changes

- Fixed stale `create-manifest.sh` wrapper paths to point at the shared helper in `shells/bash/lib/`.
- Fixed bash-side venv selection so UCRT64 and other subsystem shells can fall back to generic `.venv` locations.
- Updated bash helper scripts used for activation, reporting, VS Code setup, and repo setup to use the same precedence.
- Removed hardcoded `C:\dev-shell` and `/c/dev-shell` assumptions from the shell stack.
- Made the repo root resolve dynamically from script locations.
- Made `MY_DEV_ROOT`, `MY_TOOLS`, `MY_CACHE`, `NEOVIM_PATH`, and `VIM_PATH` overrideable with user-scoped defaults.
- Added a root `README.md` explaining purpose, usage, and relocatability.

## Key Files

- `README.md`
- `shells/windows/cmd/env/global-var.cmd`
- `shells/windows/cmd/env/ucrt64-env.cmd`
- `shells/windows/cmd/env/mingw64-env.cmd`
- `shells/windows/cmd/env/clang64-env.cmd`
- `shells/windows/cmd/env/msys64-env.cmd`
- `shells/bash/lib/startup-venv.sh`
- `shells/bash/lib/set-active-venv.sh`
- `shells/bash/lib/show-active-venv.sh`
- `shells/bash/lib/repo-setup.sh`
- `shells/bash/lib/setup-vscode.sh`
- `shells/bash/lib/create-manifest.sh`

## Recommended Validation After Moving Or Recloning

1. Launch `win-dev.cmd` and confirm the selected Python interpreter is the expected venv.
2. Launch `ucrt64.cmd` and confirm `which python` points to the expected venv instead of `/ucrt64/bin/python` when a fallback `.venv` should apply.
3. Check `show-active-venv.cmd` and `show-active-venv.sh` in the corresponding shells.
4. Verify `PATH` ordering still matches the intended shell/toolchain precedence.

## Current Validation Work

The environment is not finished yet. The next work should be explicit testing and bug fixing, not additional abstraction.

Recommended checklist:

1. Native Windows path: run the target experiment from `win-dev.cmd`, record the interpreter path, active venv, and expected output or key numeric result.
2. MSYS2 path: run the same experiment from `ucrt64.cmd` and compare both environment selection and numerical results.
3. Relocated clone path: test from a clone or copy that does not live at the root of `C:`.
4. Generic fallback path: test behavior when only `.venv` exists and no subsystem-specific `.venv-ucrt64` exists.
5. Reviewer path: test the shortest plain-Python instructions separately from the `dev-shell` workflow.
6. Failure capture: when a case fails, record the exact launcher used, `show-active-venv` output, interpreter path, and relevant `PATH` segment ordering.

## Suggested Paper Framing

Use restrained language. A reasonable claim is:

"The scripts are designed to run on standard Python installations. For Windows users who encounter environment-specific issues, this repository also includes a reproducible shell and virtual-environment workflow used to validate the reported results."

## Note For Future Sessions

Do not assume this repo lives at the root of `C:`.
If a future issue appears around shell startup or Python resolution, inspect the path-resolution and venv-selection helpers first rather than patching launcher scripts in isolation.
