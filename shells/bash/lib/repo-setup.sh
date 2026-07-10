#!/usr/bin/env bash

# repo-setup.sh - Clone a repository, write MSYS2-flavored VS Code settings
# (subsystem bash terminal + GNU compiler), and install its requirements into the
# ONE canonical native-Windows venv (%USERPROFILE%\.venv-win), invoked by its
# Windows path from this shell. No per-subsystem venv is created: every DCL repo
# shares the canonical venv for Python (per the global CLAUDE.md canonical-
# interpreter policy). MSYS2's own python is a C/Fortran toolchain, not a project
# interpreter; when a package must be GNU-toolchain-compiled, build that venv
# explicitly via build-repo-venv.sh instead. Pass --no-venv to clone + write
# settings only, skipping the dependency install into the canonical venv.
# Usage: repo-setup.sh <github-url> <project-dir> [--no-venv]
set -euo pipefail

URL="$1"
DIR="$2"
SKIP_VENV="${3:-}"

if [ -z "$URL" ] || [ -z "$DIR" ]; then
    echo "Usage: repo-setup.sh <github-url> <project-dir> [--no-venv]"
    exit 1
fi

if [ -n "$SKIP_VENV" ] && [ "$SKIP_VENV" != "--no-venv" ]; then
    echo "Usage: repo-setup.sh <github-url> <project-dir> [--no-venv]"
    exit 1
fi

# Detect subsystem -> default terminal profile + C/C++ compiler path (the MSYS2
# toolchain side; the Python interpreter is the canonical native venv regardless).
case "$MSYSTEM" in
    UCRT64)
        TERMINAL="UCRT64"
        COMPILER="\"C_Cpp.default.compilerPath\": \"C:/msys64/ucrt64/bin/g++.exe\","
        ;;
    MINGW64)
        TERMINAL="MINGW64"
        COMPILER="\"C_Cpp.default.compilerPath\": \"C:/msys64/mingw64/bin/g++.exe\","
        ;;
    CLANG64)
        TERMINAL="CLANG64"
        COMPILER="\"C_Cpp.default.compilerPath\": \"C:/msys64/clang64/bin/clang++.exe\","
        ;;
    MSYS)
        TERMINAL="MSYS"
        COMPILER="\"C_Cpp.default.compilerPath\": \"C:/msys64/usr/bin/g++.exe\","
        ;;
    *)
        echo "ERROR: Unsupported MSYSTEM: $MSYSTEM"
        exit 1
        ;;
esac

echo "Cloning $URL into $DIR"
git clone "$URL" "$DIR"

cd "$DIR"

if [ "$SKIP_VENV" != "--no-venv" ]; then
    # --- Install into the ONE canonical native-Windows venv; never create a
    #     per-subsystem venv. The native venv runs fine invoked from this shell. ---
    win_userprofile="${USERPROFILE:-$(cygpath -w "$HOME")}"
    canonical_venv="$(cygpath -u "$win_userprofile")/.venv-win"
    canonical_python="$canonical_venv/Scripts/python.exe"

    if [ ! -x "$canonical_python" ]; then
        echo "ERROR: canonical venv not found at $canonical_venv"
        echo "Build it first (build-canonical-venv), then re-run."
        exit 1
    fi

    # Install requirements if file exists
    if [ -f "virtual-env-requirements.txt" ]; then
        echo "Installing requirements from virtual-env-requirements.txt into $canonical_venv"
        # CuPy must come from the CUDA-toolkit wheels only; a bare 'cupy' sdist
        # triggers the runaway NVCC source build (the memory bomb). Install it via
        # the known-good binary recipe and keep it out of the generic pip run.
        if grep -qiE "^[[:space:]]*cupy" virtual-env-requirements.txt; then
            echo "Detected cupy requirement - installing cupy-cuda12x[ctk] binary-only"
            "$canonical_python" -m pip install --only-binary=:all: "cupy-cuda12x[ctk]"
            grep -viE "^[[:space:]]*cupy" virtual-env-requirements.txt > virtual-env-requirements-temp.txt || true
            "$canonical_python" -m pip install -r virtual-env-requirements-temp.txt
            rm -f virtual-env-requirements-temp.txt
        else
            "$canonical_python" -m pip install -r virtual-env-requirements.txt
        fi
    fi

    echo "Installing baseline repo tooling"
    "$canonical_python" -m pip install isort

    PYTHON="$(cygpath -m "$canonical_python")"
fi

mkdir -p .vscode

cat > .vscode/settings.json <<EOF
{
EOF

if [ "$SKIP_VENV" != "--no-venv" ]; then
    cat >> .vscode/settings.json <<EOF
    "python.defaultInterpreterPath": "$PYTHON",
EOF
fi

cat >> .vscode/settings.json <<EOF
    "terminal.integrated.defaultProfile.windows": "$TERMINAL",
    "terminal.integrated.profiles.windows": {
        "UCRT64": {
            "path": "C:\\\\msys64\\\\usr\\\\bin\\\\bash.exe",
            "args": ["--login", "-i"],
            "env": {
                "MSYSTEM": "UCRT64",
                "CHERE_INVOKING": "1",
                "MSYS2_PATH_TYPE": "inherit"
            }
        },
        "MINGW64": {
            "path": "C:\\\\msys64\\\\usr\\\\bin\\\\bash.exe",
            "args": ["--login", "-i"],
            "env": {
                "MSYSTEM": "MINGW64",
                "CHERE_INVOKING": "1",
                "MSYS2_PATH_TYPE": "inherit"
            }
        },
        "CLANG64": {
            "path": "C:\\\\msys64\\\\usr\\\\bin\\\\bash.exe",
            "args": ["--login", "-i"],
            "env": {
                "MSYSTEM": "CLANG64",
                "CHERE_INVOKING": "1",
                "MSYS2_PATH_TYPE": "inherit"
            }
        },
        "MSYS": {
            "path": "C:\\\\msys64\\\\usr\\\\bin\\\\bash.exe",
            "args": ["--login", "-i"],
            "env": {
                "MSYSTEM": "MSYS",
                "CHERE_INVOKING": "1",
                "MSYS2_PATH_TYPE": "inherit"
            }
        }
    },
    $COMPILER
    "files.eol": "lf"
}
EOF

echo "Repo initialized for $MSYSTEM (Python -> canonical .venv-win)"
if [ "$SKIP_VENV" = "--no-venv" ]; then
    echo "Dependency install skipped (--no-venv)"
fi
echo "VS Code settings created"

if [ "$SKIP_VENV" = "--no-venv" ]; then
    exit 0
fi

# Activate the canonical venv in the current shell
source "$canonical_venv/Scripts/activate"
