# Shell Environment Classes

This section, `shells/windows/cmd/env` contains *xxxx-env.cmd* files that setup the environment for each variety of CLI or application.

## Purpose

Enhance reproducibility of experiments, runtime, and tests by third parties.

### The Windows Environment Damages Reproducibility of Experiments, Runtime, and Tests

At one point the windows path contained three different versions of Python.exe.
This happens because some applications ironically solve the same problem by
installing their own canonical version of Python into the system path.

## Design

The shell environment consists of windows CLI scripts that encapsulate contracts
much like abstract classes. The shell environment scripts specify variables and paths
that act like properties and methods. The environment scripts can invoke one or more
other environment scripts providing inheritance.

### Scope

**Visibility** - All members of an environment script are public, i.e., do not use `setlocal` and
`endlocal` to set scope in  these scripts.

**Boundaries** - Environment scripts should restrict themselves to changing windows environment
of variables and path but not disk files or starting other processes. It is okay to call other
`xxxx-env.cmd` files which is like inheritance.

**Concrete Scripts** - call `xxxx-env.cmd` files but have a much wider scope.

## Example:

The following file provides the necessary abstract environment contract for running the git bash shell and be called by any concrete script. This file creates a minimal path using `gobal-env.cmd`, adds the path for accessing github applications

`:: git-bash-env.cmd - Prepare the Windows-side PATH used to start Git Bash.`
`@echo off`
`rem Basic Windows CLI Env Setup`
`if not "%SHELL_GIT_BASH_ENV%0"=="0" exit /b 0`
`set SHELL_GIT_BASH_ENV=1`
`call "%~dp0global-env.cmd"`
`rem --- GIT BASH Basic Working PATH ---`
`set PATH=%path%;%ProgramFiles%\Git\cmd`
`if exist "%ProgramFiles%\GitHub CLI\gh.exe" set PATH=%path%;%ProgramFiles%\GitHub CLI`
`if exist "%ProgramFiles(x86)%\GitHub CLI\gh.exe" set PATH=%path%;%ProgramFiles(x86)%\GitHub CLI`
`if exist "%LOCALAPPDATA%\Programs\GitHub CLI\gh.exe" set PATH=%path%;%LOCALAPPDATA%\Programs\GitHub CLI`
`rem --- Development Shell Path ===`
`set "PATH=%PATH%;%DEV_SHELL_WIN_PATH%\cmd"`
`set "PATH=%PATH%;%DEV_SHELL_WIN_PATH%\lib"`
`rem --- Return to caller ---`
`exit /b 0`

The following file is a concrete script that inherits `git-bash-env.cmd`, opens the git bash environment. Notice that `setlocal` and `endlocal` reset, hiding the environment from the command line.

`:: git-bash.cmd - Launch Git Bash with the repo's Windows-side PATH bootstrap`.
`@echooff`
`setlocal`
`call"%~dp0env\git-bash-env.cmd"`
`git bash -defterm -no-start -here -msys`
`setEXITCODE=%ERRORLEVEL%`
`endlocal&exit /b %EXITCODE%`

## Guard Clause Pattern: Idempotency

Environment scripts use a guard clause pattern to ensure they can be safely called multiple times without reinitializing. This is critical for reproducibility and script composition.

```batch
if not "%SHELL_GIT_BASH_ENV%0"=="0" exit /b 0
set SHELL_GIT_BASH_ENV=1
```

**Why this matters:** 
- If a script is called directly and via inheritance, the guard clause prevents duplicate PATH entries and variable reassignments.
- The check compares against `"0"` (with a dummy `0` appended) to safely handle both initialized and uninitialized variables.
- The variable name uses the pattern `SHELL_<SUBSYSTEM>_ENV` for consistency.

**When adding new environment scripts:** Always include this guard clause near the top, immediately after `@echo off` and any comments.

### Caveat: boolean guards are unsafe when a parent resets PATH

The boolean guard above prevents the script *body* from running a second time. That
is correct only when the work it skips is still in effect. It is **not** safe for a
PATH-adding script whose parent unconditionally rebuilds PATH, because the flag can
survive a PATH reset:

- `global-env.cmd` sets `PATH=%SystemRoot%\System32;%SystemRoot%` every time it runs.
- A subsystem script (e.g. `ucrt64-env.cmd`) calls `global-env.cmd` **before** the
  tool scripts. If a tool's `SHELL_*_ENV` flag was inherited as `1` from the parent
  process, the reset wipes the tool from PATH and the guard then makes the tool
  script exit early — so the tool is never re-added. Silent failure.

For PATH-adding scripts, guard by **PATH membership**, not by the boolean flag. Still
publish the `SHELL_*_ENV` variable for external consumers, but decide whether to add
the directory by checking PATH directly. See `quarto-env.cmd` and `R-env.cmd`:

```batch
:: idempotent by PATH membership, NOT by an early-return boolean guard
set SHELL_R_ENV=1
set "WCDE_R_BIN_PATH=%WCDE_R_HOME%\bin\x64"
if not exist "%WCDE_R_BIN_PATH%\R.exe" goto :COMPLETE
echo %PATH% | findstr /I /C:"%WCDE_R_BIN_PATH%" >nul
if errorlevel 1 set "PATH=%PATH%;%WCDE_R_BIN_PATH%"
:COMPLETE
```

The same rule applies to the PowerShell `profile.ps1`: its `Add-GitCliEnv` and
`Add-REnv` check membership rather than returning early on `$env:SHELL_*_ENV`.

## Two MSYS2 Runtimes: Git Bash vs. Standalone MSYS2

This machine has **two independent MSYS2 installations**, and the PATH-ordering
rules in these scripts exist mainly to keep them from colliding.

| | Git for Windows (Git Bash) | Standalone MSYS2 |
|---|---|---|
| Location | `C:\Program Files\Git` | `C:\msys64` |
| Runtime | bundled `msys-2.0.dll` (e.g. 3.6.7) | `pacman`-managed `msys-2.0.dll` (e.g. 3.6.9) |
| `bash` + coreutils | `Git\usr\bin\` | `msys64\usr\bin\`, `msys64\ucrt64\bin\`, ... |
| Package manager | none (frozen, ships with Git) | `pacman` |

Git for Windows is *built on* a fork of MSYS2 and bundles its own private copy of the
runtime and coreutils. It is entirely separate from the `C:\msys64` that `pacman`
manages, and the two carry **different `msys-2.0.dll` versions**.

**The cardinal rule:** never load two different `msys-2.0.dll` into one process. Mixing
MSYS-linked binaries across the two installs (e.g. Git's `bash` calling msys64's
`grep`) produces `cygheap base mismatch detected` errors and `fork` failures.

How the scripts honor that rule:

- **`git.exe` is the safe, Windows-facing launcher.** `git-cli-env.cmd` and
  `profile.ps1` *prepend* `Git\cmd` so it wins over any MSYS2 `git`. It runs as its
  own process, so calling it from any shell is safe.
- **Git's `usr\bin` (bash/coreutils) is the dangerous part.** `git-cli-env.cmd`
  *appends* `Git\usr\bin` and `Git\mingw64\bin` at the very end so they never shadow
  MSYS2's coreutils when a subsystem shell runs with `MSYS2_PATH_TYPE=inherit`.
- **`ucrt64-env.cmd` adds only `Git\cmd`** — never `Git\usr\bin` — so inside a real
  UCRT64 shell every bash/coreutil comes from `C:\msys64` and no runtime mixing occurs.
- **Native Windows tools are immune.** R from `C:\Program Files\R` (added by
  `R-env.cmd`), the Program Files Python, and VS Code are plain Win32 programs that
  link neither runtime, so they are safe to add to any PATH. (By contrast, the
  `pacman`-installed `mingw-w64-ucrt-x86_64-r` links the 3.6.9 runtime and works only
  inside the standalone MSYS2 UCRT64 shell.)

Rule of thumb: **pick one MSYS2 world per shell, and don't put the other's `usr\bin`
on its PATH.**

## File Naming Conventions

- **Pattern:** `xxxx-env.cmd` where `xxxx` is lowercase, hyphens separate words, no spaces
- **Purpose-based naming:** Use descriptive subsystem or tool names (`git-bash-env`, `mingw64-env`, `vscode-env`)
- **Guard variable naming:** `SHELL_<SUBSYSTEM>_ENV` (uppercase, underscores, e.g., `SHELL_MINGW64_ENV`)
- **Comments:** Include a one-line description as the first line: `:: xxxx-env.cmd - Brief description`

## Quick Start / Usage Guide

### For End Users

Call an environment script from your concrete launcher script using the `call` command:

```batch
@echo off
setlocal
call "%~dp0env\mingw64-env.cmd"
:: Your commands here that need the mingw64 environment
mingw-get update
endlocal & exit /b %ERRORLEVEL%
```

### For Direct Shell Access

From Git Bash or MSYS2, source the environment directly:

```bash
# From cmd.exe invoked within bash
cmd /c "call %DEV_SHELL_WIN_PATH%/shells/windows/cmd/env/clang64-env.cmd && bash"
```

### Path Composition

Environment scripts build the PATH in **order of dependency**, not alphabetically:

1. **Minimal Windows baseline** (from `global-env.cmd`)
2. **Inherited parent environments**
3. **Subsystem-specific paths** (MSYS2, MinGW64, CLANG64, etc.)
4. **Tool-specific paths** (Git, CMake, Doxygen, etc.)

This ensures subsystem tools take precedence over system tools and avoids the "multiple Python versions" problem.

## Error Handling Guidelines

### Checking Existence Before Adding to PATH

```batch
rem Only add a tool to PATH if it exists
if exist "%ProgramFiles%\CMake\bin" set PATH=%PATH%;%ProgramFiles%\CMake\bin
```

**Why:** Prevents errors when tools are not installed, allows graceful degradation.

### Checking Script Dependencies

```batch
rem Call the parent script and capture the return code
call "%~dp0global-env.cmd"
if errorlevel 1 (
    echo Error: Failed to initialize global environment
    exit /b 1
)
```

**Why:** Early exit prevents cascading failures in dependent scripts.

### Returning Status

```batch
set GLOBAL_ENV_RC=0
rem ... initialization code ...
exit /b %GLOBAL_ENV_RC%
```

**Why:** Allows calling scripts to check success/failure without relying solely on `%ERRORLEVEL%`.

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| PATH grows unbounded | Script called multiple times without guard clause | Verify guard clause is present and uses correct variable name |
| Tool not found | Wrong PATH order or tool installed elsewhere | Use `where.exe toolname` to locate, adjust path precedence |
| Conflicting Python versions | Multiple tool-chains distribute Python | Ensure subsystem-specific paths precede system paths |
| Variable not expanding | Used single quotes instead of double quotes | Use double quotes: `"%VARIABLE%"` |

## Creating New Environment Scripts

### Minimal Template

```batch
:: my-tool-env.cmd - Setup environment for MyTool.
@echo off

rem --- Guard clause: prevent re-initialization ---
if not "%SHELL_MY_TOOL_ENV%0"=="0" exit /b 0
set SHELL_MY_TOOL_ENV=1

rem --- Call parent environment(s) ---
call "%~dp0global-env.cmd"

rem --- Set tool-specific variables ---
set MY_TOOL_VERSION=1.0
set MY_TOOL_PATH=%ProgramFiles%\MyTool

rem --- Add to PATH if tool exists ---
if exist "%MY_TOOL_PATH%\bin" set PATH=%PATH%;%MY_TOOL_PATH%\bin

rem --- Optional: Compiler settings ---
set CC=my-gcc.exe
set CFLAGS=-Wall -O2

rem --- Return to caller ---
exit /b 0
```

### Checklist for New Scripts

- [ ] Filename follows `xxxx-env.cmd` pattern
- [ ] First line is a comment with description
- [ ] Guard clause present and uses `SHELL_<SUBSYSTEM>_ENV` variable
- [ ] Calls parent environment script(s) with full path
- [ ] Uses `if exist` checks before adding optional tools to PATH
- [ ] Sets meaningful return codes
- [ ] Ends with `exit /b 0` or `exit /b %ERRORLEVEL%`
- [ ] No `setlocal` / `endlocal` (those belong in concrete launcher scripts)
- [ ] No file system modifications or process creation

## Available Environment Scripts

| Script | Parent(s) | Purpose | Sets |
|--------|-----------|---------|------|
| `global-env.cmd` | (bootstrap) | Minimum Windows CLI baseline (System32 only) | `GLOBAL_ENV_RC` |
| `global-var.cmd` | (bootstrap) | Shared variables across all environments | `DEV_SHELL_*` variables |
| `win-env.cmd` | `global-env.cmd` | Windows native development (Git, CMake, Doxygen, MSVC) | `CC`, `CXX` |
| `win-dev-env.cmd` | `win-env.cmd` | Extended Windows development tools | Inherits from `win-env.cmd` |
| `win-admin-env.cmd` | `win-env.cmd` | Administrator-level Windows environment | `PROMPT` modifications |
| `win-choco-env.cmd` | `win-env.cmd` | Chocolatey package manager tools | `CHOCOLATEY_PATH` |
| `win-perl-env.cmd` | `win-env.cmd` | Perl development (Strawberry Perl) | Perl toolchain paths |
| `git-bash-env.cmd` | `global-env.cmd` | Git Bash shell environment | `PATH` (Git, GitHub CLI) |
| `msys64-env.cmd` | `global-env.cmd` | MSYS2 (MSYS subsystem) | `MSYSTEM`, `MSYS2_PATH_TYPE` |
| `mingw64-env.cmd` | `global-env.cmd` | MSYS2 (MinGW64 subsystem) | `MSYSTEM`, `VIRTUAL_ENV` |
| `clang64-env.cmd` | `global-env.cmd` | MSYS2 (CLANG64 subsystem, Clang/LLVM) | `CC`, `CXX`, `PKG_CONFIG_PATH` |
| `ucrt64-env.cmd` | `global-env.cmd` | MSYS2 (UCRT64 subsystem, UCRT runtime) | `MSYSTEM`, UCRT-specific paths |
| `vscode-env.cmd` | `win-env.cmd` | VS Code editor with development tools | `VSCODE_HOME` |
| `miktex-env.cmd` | `win-env.cmd` | MikTeX LaTeX distribution | `MIKTEX_*` variables |
| `texlive-env.cmd` | `win-env.cmd` | TeX Live LaTeX distribution | TeX Live paths |
| `quarto-env.cmd` | `win-env.cmd` | Quarto publishing tool | Quarto bin paths |
| `sagemath-env.cmd` | `win-env.cmd` | SageMath computer algebra system | SageMath paths |

## Interdependencies

The environment scripts form a directed acyclic graph (DAG) of dependencies. Understanding this is crucial for debugging and creating new scripts.

```
global-env.cmd ← global-var.cmd
       ↓
   ┌───┴────────────────────┬─────────────┬──────────┐
   ↓                        ↓             ↓          ↓
win-env.cmd          git-bash-env.cmd  msys64-env  [subsystems]
   ↓
 ┌─┴──────────┬──────────────┬──────────┬────────┐
 ↓            ↓              ↓          ↓        ↓
win-dev    vscode        miktex    texlive   quarto  
 ↓
win-admin, win-choco, win-perl
```

**Key points:**
- `global-env.cmd` is the root: all others depend on it directly or indirectly
- `msys64-env.cmd` and subsystem scripts (`mingw64-env.cmd`, `clang64-env.cmd`) depend only on `global-env.cmd`
- Tool environments (`vscode-env.cmd`, `miktex-env.cmd`, etc.) depend on `win-env.cmd`
- Adding a new script? Decide whether it's a Windows tool (parent: `win-env.cmd`) or a subsystem (parent: `global-env.cmd`)

## Troubleshooting

### Issue: Tool Not Found in PATH

**Symptom:** `'toolname' is not recognized as an internal or external command`

**Debug steps:**
1. Check if tool is installed: `dir /s "%ProgramFiles%\ToolName"`
2. Verify environment script exists and has the correct path
3. Check if the script's `if exist` condition is passing: add `echo` statements
4. Run `echo %PATH%` to inspect the full PATH and look for tool locations
5. Check for conflicting installations: `where.exe python` lists all Python installations

**Solution:** Update the environment script to include the correct path, or install the missing tool.

### Issue: Script Runs Twice, PATH Grows

**Symptom:** Running a launcher adds duplicate PATH entries each time

**Debug steps:**
1. Verify guard clause is present in all environment scripts
2. Check that guard variable name matches: `SHELL_<SUBSYSTEM>_ENV` (uppercase)
3. Ensure the comparison includes the dummy `0`: `if not "%SHELL_VAR%0"=="0"`

**Solution:** Add or fix the guard clause in the offending script.

### Issue: Wrong Compiler Used

**Symptom:** `cl.exe` (MSVC) is used instead of `gcc` (MinGW64)

**Debug steps:**
1. Check order of environment script calls: subsystem scripts should come after Windows tool scripts
2. Verify `CC` and `CXX` variables: `echo %CC% %CXX%`
3. Inspect `%PATH%` for competing compiler locations

**Solution:** Reorder script calls or adjust PATH precedence. Subsystem tools should override Windows tools.

### Issue: Virtual Environment Not Activated

**Symptom:** `(venv)` prompt not showing, Python packages not isolated

**Debug steps:**
1. Check if `.venv` directory exists: `dir .venv`
2. Verify `VIRTUAL_ENV` variable: `echo %VIRTUAL_ENV%`
3. Ensure environment script sets `VIRTUAL_ENV` after activating venv

**Solution:** Run `set-active-venv.sh` or manually activate the virtual environment after loading the environment script.

---

**For questions or contributions:** Review the scripts in this directory and follow the patterns and conventions documented above.
