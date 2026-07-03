#!/usr/bin/env bash

# repo-setup.sh - Clone a repository, prepare VS Code settings, and optionally create a subsystem-local repo venv.
# Usage: repo-setup.sh <github-url> <project-dir> [--no-venv]
set -euo pipefail

venv_suffix() {
    case "$MSYSTEM" in
        UCRT64)
            printf 'ucrt64\n'
            ;;
        MINGW64)
            printf 'mingw64\n'
            ;;
        CLANG64)
            printf 'clang64\n'
            ;;
        MSYS)
            printf 'msys\n'
            ;;
        *)
            echo "ERROR: Unsupported MSYSTEM: $MSYSTEM"
            exit 1
            ;;
    esac
}

resolve_python() {
    local suffix
    suffix=$(venv_suffix)

    local candidates=(
        "$PWD/.venv-$suffix/bin/python.exe"
        "$PWD/.venv-$suffix/bin/python"
        "$PWD/.venv-$suffix/Scripts/python.exe"
        "$PWD/.venv/bin/python.exe"
        "$PWD/.venv/bin/python"
        "$PWD/.venv/Scripts/python.exe"
        "$HOME/.venv-$suffix/bin/python.exe"
        "$HOME/.venv-$suffix/bin/python"
        "$HOME/.venv-$suffix/Scripts/python.exe"
        "$HOME/.venv/bin/python.exe"
        "$HOME/.venv/bin/python"
        "$HOME/.venv/Scripts/python.exe"
    )

    local candidate
    for candidate in "${candidates[@]}"; do
        if [ -x "$candidate" ]; then
            if [[ "$candidate" == "$PWD/"* ]]; then
                printf '${workspaceFolder}/%s\n' "${candidate#"$PWD/"}"
            else
                cygpath -m "$candidate"
            fi
            return
        fi
    done

    echo "ERROR: No Python interpreter found for $MSYSTEM"
    exit 1
}

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

# Detect subsystem -> default terminal profile + C/C++ compiler path.
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

suffix=$(venv_suffix)
venv_dir=".venv-$suffix"

if [ "$SKIP_VENV" != "--no-venv" ]; then
    # Determine canonical python for venv creation
    case "$MSYSTEM" in
        UCRT64)
            canonical_python="/ucrt64/bin/python"
            CC="/ucrt64/bin/gcc"
            CXX="/ucrt64/bin/g++"
            PKG_CONFIG_PATH="/ucrt64/tools/pkgconfig:/ucrt64/share/pkgconfig"
            PACMAN_PREFIX="mingw-w64-ucrt-x86_64-"
            ;;
        MINGW64)
            canonical_python="/mingw64/bin/python"
            CC="/mingw64/bin/gcc"
            CXX="/mingw64/bin/g++"
            PKG_CONFIG_PATH="/mingw64/tools/pkgconfig:/mingw64/share/pkgconfig"
            PACMAN_PREFIX="mingw-w64-x86_64-"
            ;;
        CLANG64)
            canonical_python="/clang64/bin/python"
            CC="/clang64/bin/clang"
            CXX="/clang64/bin/clang++"
            PKG_CONFIG_PATH="/clang64/tools/pkgconfig:/clang64/share/pkgconfig"
            PACMAN_PREFIX="mingw-w64-clang-x86_64-"
            ;;
        MSYS)
            canonical_python="/usr/bin/python"
            CC="/usr/bin/gcc"
            CXX="/usr/bin/g++"
            PKG_CONFIG_PATH="/usr/tools/pkgconfig:/usr/share/pkgconfig"
            PACMAN_PREFIX=""
            ;;
        *)
            echo "ERROR: Unsupported MSYSTEM for canonical python: $MSYSTEM"
            exit 1
            ;;
    esac

    # Create venv if it doesn't exist
    if [ ! -d "$venv_dir" ]; then
        echo "Creating $venv_dir"
        "$canonical_python" -m venv --system-site-packages "$venv_dir"
    fi

    venv_python="$venv_dir/bin/python"
    if [ ! -x "$venv_python" ] && [ -x "$venv_dir/Scripts/python.exe" ]; then
        venv_python="$venv_dir/Scripts/python.exe"
    fi

    # Install requirements if file exists
    if [ -f "virtual-env-requirements.txt" ]; then
        echo "Installing requirements from virtual-env-requirements.txt"

        # GPU guard: CuPy is native-Windows-only in this environment. There is no
        # wheel for the MSYS2 platform tag (mingw_x86_64_ucrt_gnu) and no pacman
        # package, so pip falls back to building the sdist -- a runaway parallel
        # NVCC/C++ compile that spawns thousands of processes and exhausts system
        # RAM. Never let that happen here: strip cupy from the requirements and
        # point the user at the canonical Windows venv (.venv-win, via vscode-ps.cmd).
        if grep -qiE "^[[:space:]]*cupy" virtual-env-requirements.txt; then
            echo "############################################################"
            echo "# SKIPPING cupy: not buildable under $MSYSTEM (would exhaust RAM)."
            echo "# Use the canonical Windows venv (.venv-win) via vscode-ps.cmd for GPU work."
            echo "############################################################"
        fi

        # Working copy with cupy stripped (see guard above); heavy packages are
        # further removed below when installed via pacman instead of compiling.
        grep -viE "^[[:space:]]*cupy" virtual-env-requirements.txt > virtual-env-requirements-temp.txt || true

        # For MSYS2 subsystems, install heavy packages via pacman to avoid compilation issues
        pacman_packages=""
        if grep -q "^pandas==" virtual-env-requirements-temp.txt; then
            pacman_packages="$pacman_packages ${PACMAN_PREFIX}python-pandas"
        fi
        if grep -q "^scipy==" virtual-env-requirements-temp.txt; then
            pacman_packages="$pacman_packages ${PACMAN_PREFIX}python-scipy"
        fi
        if grep -q "^pillow==" virtual-env-requirements-temp.txt; then
            pacman_packages="$pacman_packages ${PACMAN_PREFIX}python-pillow"
        fi
        if [ -n "$pacman_packages" ]; then
            echo "Installing packages via pacman: $pacman_packages"
            pacman -S --noconfirm $pacman_packages || echo "Some packages not available via pacman, proceeding with pip"
            # Drop the pacman-installed packages from the pip requirements too.
            grep -v "^pandas==" virtual-env-requirements-temp.txt | grep -v "^scipy==" | grep -v "^pillow==" > virtual-env-requirements-temp2.txt || true
            mv virtual-env-requirements-temp2.txt virtual-env-requirements-temp.txt
        fi

        # --only-binary on cupy is a backstop: even a transitive cupy dependency
        # fails fast instead of triggering the runaway source build.
        CC="$CC" CXX="$CXX" PKG_CONFIG_PATH="$PKG_CONFIG_PATH" "$venv_python" -m pip install --no-cache-dir \
            --only-binary=cupy,cupy-cuda11x,cupy-cuda12x \
            -r virtual-env-requirements-temp.txt
        rm -f virtual-env-requirements-temp.txt
    fi

    echo "Installing baseline repo tooling"
    "$venv_python" -m pip install --no-cache-dir isort

    PYTHON="$(resolve_python)"
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

echo "Repo initialized for $MSYSTEM"
if [ "$SKIP_VENV" = "--no-venv" ]; then
    echo "Virtual environment setup skipped"
fi
echo "VS Code settings created"

if [ "$SKIP_VENV" = "--no-venv" ]; then
    exit 0
fi

# Activate the venv in the current shell
source "$venv_dir/bin/activate"

