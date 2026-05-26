# dev-shell

`dev-shell` is a reproducible Windows development and experiment-execution environment.

If you are resuming work in a fresh Copilot session, read `HANDOFF.md` after this file for recent debugging context and repo-specific handoff notes.

The main goal is to make Python-based work, including falsifiable research experiments, run predictably on your machine and on other Windows machines that clone the same repo. It does that by giving you consistent shell entry points, predictable PATH construction, and explicit virtual-environment selection.

## What It Provides

- Native Windows command shells for development tasks.
- MSYS2-based shells for `UCRT64`, `MINGW64`, `CLANG64`, and `MSYS`.
- Automatic Python virtual-environment selection for interactive shells.
- Helper scripts for creating canonical venvs, setting VS Code interpreter paths, and tracking subsystem package manifests.
- A relocatable repo layout: the shell stack no longer requires the repo to live at `C:\dev-shell`.

## Why This Exists

This repo is designed to support reproducible Python experiments and general Windows development.

For research code, the important question is not just whether the code runs once on the author's machine. The important question is whether another person can clone the same repo, enter the intended shell, and run the same experiment with the expected interpreter, environment, and supporting toolchain.

The intended paper-facing position is modest: the experiment scripts should run with normal Python tooling on a reviewer's laptop, and `dev-shell` exists as a more controlled fallback path when environment drift or Windows-specific setup problems make reproduction difficult.

## Shell Entry Points

The main Windows launchers live under `shells/windows/cmd/`.

- `win-dev.cmd`: native Windows development shell.
- `ucrt64.cmd`: MSYS2 UCRT64 shell.
- `mingw64.cmd`: MSYS2 MINGW64 shell.
- `clang64.cmd`: MSYS2 CLANG64 shell.
- `msys64.cmd`: MSYS2 MSYS shell.
- `vs-dev.cmd`: Visual Studio development shell.

To see the current command catalog from inside a shell, run `dev-catalog.cmd` in Windows command shells or `dev-catalog.sh` in bash shells. To regenerate the catalog after adding or renaming scripts, run `build-catalog.cmd` or `build-catalog.sh`.

## Virtual Environment Rules

For bash-based subsystem shells, the active Python environment is selected in this order:

1. Repo-local `.venv-<subsystem>`
2. Repo-local `.venv`
3. User-level `~/.venv-<subsystem>`
4. User-level `~/.venv`

For native Windows shells, the equivalent precedence is used with Windows paths.

This means a repo-specific environment overrides the default user environment, while still allowing a generic fallback when a subsystem-specific venv does not exist.

## Basic Sanity Checks

After launching a shell, verify the active environment before running experiments.

Windows CMD:

```bat
show-active-venv.cmd
where python
path
```

MSYS2 bash:

```bash
show-active-venv.sh
which python
env | grep '^VIRTUAL_ENV='
```

## Validation Checklist

This project is still under validation. Before relying on it as a reproducibility path for a paper or public release, test at least the following cases.

1. Native Windows shell: launch `win-dev.cmd`, check `show-active-venv.cmd`, `where python`, and confirm the target experiment produces the expected result.
2. UCRT64 shell: launch `ucrt64.cmd`, check `show-active-venv.sh`, `which python`, and confirm the same experiment produces the same result.
3. Fresh non-root clone: clone or copy the repo into a path outside `C:\`, then verify the shell launchers still resolve the repo root and wrapper scripts correctly.
4. Generic venv fallback: test a repo that has `.venv` but not `.venv-ucrt64` and confirm the subsystem shell selects the generic venv instead of `/ucrt64/bin/python`.
5. Minimal reviewer path: test the shortest possible "just run the script" instructions on a machine that resembles what a reviewer would actually use.

## Relocatability

The repo root is resolved from the script locations, not from a fixed install path.

You can clone this repo outside the root of the `C:` drive. The shell scripts now derive the repo path dynamically.

Some user-specific helper directories are also configurable through environment variables:

- `DEV_SHELL_PATH`: override the resolved repo root if needed.
- `MY_DEV_ROOT`: defaults to `%USERPROFILE%\dev`.
- `MY_TOOLS`: defaults to `%USERPROFILE%\tools`.
- `MY_CACHE`: defaults to `%LOCALAPPDATA%\dev-shell\cache`.
- `NEOVIM_PATH`: defaults to `%MY_TOOLS%\neovim`.
- `VIM_PATH`: defaults to `%MY_TOOLS%\vim`.

If your local tool layout differs, set those variables before launching a shell or adjust the defaults in `shells/windows/cmd/env/global-var.cmd`.

## VS Code Helpers

Use the setup helpers to align the editor with the selected shell and interpreter.

- `shells/windows/tools/setup-vscode.cmd`
- `shells/windows/lib/repo-setup.cmd`
- `shells/bash/tools/setup-vscode.sh`
- `shells/bash/lib/repo-setup.sh`

The repo setup helpers clone a repository, prepare `.vscode/settings.json`, and create a local virtual environment by default. Pass `--no-venv` as the optional third argument for repos that do not need Python, such as a theory-only paper or book project.

## Venv Maintenance

Use the venv maintenance helpers when the underlying subsystem Python has changed and you want to rebuild either the per-user canonical venv or a selected repo-local venv.

- Bash canonical venv: `shells/bash/tools/build-canonical-venv.sh`
- Bash repo-local venv: `shells/bash/tools/build-repo-venv.sh [repo-dir]`
- Bash repo-local patch: `shells/bash/tools/patch-repo-venv.sh [repo-dir]`
- Windows canonical venv: `build-canonical-venv.cmd`
- Windows repo-local venv: `build-repo-venv.cmd [repo-dir]`
- Windows repo-local patch: `patch-repo-venv.cmd [repo-dir]`

The repo-local rebuild helpers preserve the packages already installed in the selected repo venv when one exists. If no repo-local venv exists yet, they create the preferred repo-local venv for the current shell and install `virtual-env-requirements.txt` when that file is present.

Use the repo-local patch helpers when a repo venv already exists and only needs the baseline editor tooling refreshed without a full rebuild.

## Container Execution

Container execution is treated as a separate reproducibility path, not as a replacement for the host shell and venv workflow. This is especially useful for paper reproducibility, where the goal is to freeze the exact Python environment for peer reviewers.

### Workflow for Paper Reproducibility

1. **Development**: Work normally in your host venv (`.venv-ucrt64`, `.venv-win`, etc.)

2. **Before release**: Generate a frozen Dockerfile from your current venv:
   ```bash
   bash shells/bash/lib/generate-dockerfile.sh /path/to/paper-repo
   ```
   or on Windows:
   ```cmd
   call shells\windows\lib\generate-dockerfile.cmd C:\path\to\paper-repo
   ```
   This creates:
   - `.dev-shell/requirements.txt` - All pinned package versions
   - `.dev-shell/Dockerfile` - Image template with Python version
   - `HOWTO_REPRODUCE.md` - Instructions for reviewers

3. **Release**: Commit all three files to git. Reviewers will use only the Dockerfile and HOWTO_REPRODUCE.md.

4. **Reviewers**: Follow HOWTO_REPRODUCE.md to build the image and run experiments exactly as they did during development.

### Runner Commands

- Bash runner: `shells/bash/tools/run-container.sh`
- Windows runner: `shells/windows/cmd/run-container.cmd`
- Config template: `templates/container.conf.template`
- Dockerfile generator: `shells/bash/lib/generate-dockerfile.sh` or `shells/windows/lib/generate-dockerfile.cmd`

The runner searches upward from the current directory for `.dev-shell/container.conf`, mounts that repository at `/workspace` by default, and runs the requested command inside the configured image.

### Suggested Target-Repo Layout

```text
.dev-shell/
	container.conf
	Dockerfile
	requirements.txt
scripts/
	run-experiment.sh
HOWTO_REPRODUCE.md
```

### Example Usage

After building the image (`docker build -t paper-exp:latest .`):

```bash
run-container.sh python scripts/run_experiment.py --case baseline
```

```bat
run-container.cmd python scripts\run_experiment.py --case baseline
```

Or directly:

```bash
docker run --rm -v $(pwd):/workspace paper-exp:latest python scripts/run_experiment.py --case baseline
```

### Important Constraints

- Do not mount host `.venv-*` directories into the container
- The image should provide its own Python runtime and dependencies
- Keep the container path focused on controlled batch execution
- Keep the host shell path available for normal development
- Document the workflow in HOWTO_REPRODUCE.md for reviewers who won't have this framework

## Package Manifests

Subsystem-specific package manifests are stored under `shells/bash/<subsystem>/` and generated by the shared helper in `shells/bash/tools/create-manifest.sh`.

These manifests help document and reconstruct the package state of each MSYS2 subsystem.
