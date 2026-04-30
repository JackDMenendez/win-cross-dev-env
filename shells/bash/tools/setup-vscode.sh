#!/usr/bin/env bash

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
            echo "Unknown MSYSTEM: $MSYSTEM"
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

    echo "No Python interpreter found for $MSYSTEM"
    exit 1
}

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
        echo "Unknown MSYSTEM: $MSYSTEM"
        exit 1
        ;;
esac

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

echo "VS Code settings created for $MSYSTEM"
