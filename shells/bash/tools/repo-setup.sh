#!/usr/bin/env bash

# Usage: new-repo.sh <github-url> <project-dir>
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
        "$PWD/.venv-$suffix/bin/python"
        "$PWD/.venv-$suffix/Scripts/python.exe"
        "$PWD/.venv/bin/python"
        "$PWD/.venv/Scripts/python.exe"
        "$HOME/.venv-$suffix/bin/python"
        "$HOME/.venv-$suffix/Scripts/python.exe"
        "$HOME/.venv/bin/python"
        "$HOME/.venv/Scripts/python.exe"
    )

    local candidate
    for candidate in "${candidates[@]}"; do
        if [ -x "$candidate" ]; then
            cygpath -m "$candidate"
            return
        fi
    done

    echo "ERROR: No Python interpreter found for $MSYSTEM"
    exit 1
}

URL="$1"
DIR="$2"

if [ -z "$URL" ] || [ -z "$DIR" ]; then
    echo "Usage: new-repo.sh <github-url> <project-dir>"
    exit 1
fi

# Detect subsystem
case "$MSYSTEM" in
    UCRT64)
        TERMINAL="UCRT64"
        COMPILER=""
        ;;
    MINGW64)
        TERMINAL="MINGW64"
        COMPILER="\"C_Cpp.default.compilerPath\": \"C:/msys64/mingw64/bin/g++.exe\","
        ;;
    *)
        echo "ERROR: Unsupported MSYSTEM: $MSYSTEM"
        exit 1
        ;;
esac

echo "Cloning $URL into $DIR"
git clone "$URL" "$DIR"

cd "$DIR"

# Determine canonical python for venv creation
case "$MSYSTEM" in
    UCRT64)
        canonical_python="/ucrt64/bin/python"
        CC="/ucrt64/bin/gcc"
        CXX="/ucrt64/bin/g++"
        PKG_CONFIG_PATH="/ucrt64/tools/pkgconfig:/ucrt64/share/pkgconfig"
        ;;
    MINGW64)
        canonical_python="/mingw64/bin/python"
        CC="/mingw64/bin/gcc"
        CXX="/mingw64/bin/g++"
        PKG_CONFIG_PATH="/mingw64/tools/pkgconfig:/mingw64/share/pkgconfig"
        ;;
    CLANG64)
        canonical_python="/clang64/bin/python"
        CC="/clang64/bin/clang"
        CXX="/clang64/bin/clang++"
        PKG_CONFIG_PATH="/clang64/tools/pkgconfig:/clang64/share/pkgconfig"
        ;;
    MSYS)
        canonical_python="/usr/bin/python"
        CC="/usr/bin/gcc"
        CXX="/usr/bin/g++"
        PKG_CONFIG_PATH="/usr/tools/pkgconfig:/usr/share/pkgconfig"
        ;;
    *)
        echo "ERROR: Unsupported MSYSTEM for canonical python: $MSYSTEM"
        exit 1
        ;;
esac

suffix=$(venv_suffix)
venv_dir=".venv-$suffix"

# Create venv if it doesn't exist
if [ ! -d "$venv_dir" ]; then
    echo "Creating $venv_dir"
    "$canonical_python" -m venv --system-site-packages "$venv_dir"
fi

# Install requirements if file exists
if [ -f "virtual-env-requirements.txt" ]; then
    echo "Installing requirements from virtual-env-requirements.txt"
    # For MSYS2 subsystems, install heavy packages via pacman to avoid compilation issues
    pacman_packages=""
    if grep -q "^pandas==" virtual-env-requirements.txt; then
        pacman_packages="$pacman_packages mingw-w64-ucrt-x86_64-python-pandas"
    fi
    if grep -q "^scipy==" virtual-env-requirements.txt; then
        pacman_packages="$pacman_packages mingw-w64-ucrt-x86_64-python-scipy"
    fi
    if grep -q "^pillow==" virtual-env-requirements.txt; then
        pacman_packages="$pacman_packages mingw-w64-ucrt-x86_64-python-pillow"
    fi
    if [ -n "$pacman_packages" ]; then
        echo "Installing packages via pacman: $pacman_packages"
        pacman -S --noconfirm $pacman_packages || echo "Some packages not available via pacman, proceeding with pip"
        # Create a temporary requirements file without the pacman-installed packages
        grep -v "^pandas==" virtual-env-requirements.txt | grep -v "^scipy==" | grep -v "^pillow==" > virtual-env-requirements-temp.txt
        requirements_file="virtual-env-requirements-temp.txt"
    else
        requirements_file="virtual-env-requirements.txt"
    fi
    CC="$CC" CXX="$CXX" PKG_CONFIG_PATH="$PKG_CONFIG_PATH" "$venv_dir/bin/python" -m pip install --no-cache-dir -r "$requirements_file"
    # Clean up temp file if created
    [ -f "virtual-env-requirements-temp.txt" ] && rm virtual-env-requirements-temp.txt
fi

PYTHON="$(resolve_python)"

mkdir -p .vscode

cat > .vscode/settings.json <<EOF
{
    "python.defaultInterpreterPath": "$PYTHON",
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
        }
    },
    $COMPILER
    "files.eol": "lf"
}
EOF

echo "Repo initialized for $MSYSTEM"
echo "VS Code settings created"

# Activate the venv in the current shell
source "$venv_dir/bin/activate"

