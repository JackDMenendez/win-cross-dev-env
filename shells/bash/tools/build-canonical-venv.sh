#!/usr/bin/env bash

set -euo pipefail

case "${MSYSTEM:-}" in
    UCRT64)
        VENV_SUFFIX=ucrt64
        ;;
    MINGW64)
        VENV_SUFFIX=mingw64
        ;;
    CLANG64)
        VENV_SUFFIX=clang64
        ;;
    MSYS)
        VENV_SUFFIX=msys
        ;;
    *)
        echo "Unsupported MSYSTEM for canonical venv build: ${MSYSTEM:-unset}"
        exit 1
        ;;
esac

CANONICAL_VENV="$HOME/.venv-$VENV_SUFFIX"
CANONICAL_PYTHON="$CANONICAL_VENV/bin/python"
CANONICAL_PACKAGES="$HOME/canonical-packages-$VENV_SUFFIX.txt"

if [ -d "$CANONICAL_VENV" ]; then
    if [ -x "$CANONICAL_PYTHON" ]; then
        echo "Saving canonical packages to $CANONICAL_PACKAGES"
        "$CANONICAL_PYTHON" -m pip freeze > "$CANONICAL_PACKAGES"
    fi

    echo "Removing existing canonical venv at $CANONICAL_VENV"
    rm -rf "$CANONICAL_VENV"
fi

echo "Creating canonical venv at $CANONICAL_VENV"
python -m venv "$CANONICAL_VENV"
"$CANONICAL_PYTHON" -m pip install --upgrade pip

if [ -f "$CANONICAL_PACKAGES" ]; then
    echo "Restoring canonical packages from $CANONICAL_PACKAGES"
    "$CANONICAL_PYTHON" -m pip install -r "$CANONICAL_PACKAGES"
fi