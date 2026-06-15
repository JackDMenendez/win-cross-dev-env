#!/usr/bin/env bash

# build-canonical-venv.sh - Rebuild the canonical Python virtual environment for the current bash subsystem.

set -euo pipefail

show_help() {
    echo "Usage: $(basename "$0") [-h|--help]"
    echo "Builds or rebuilds the canonical Python virtual environment for the current MSYSTEM."
    echo "It saves the venv-local pip packages (if the venv exists), creates a fresh venv"
    echo "with --system-site-packages so pacman-built packages stay visible, upgrades pip,"
    echo "and restores the venv-local packages from the saved requirements file."
    echo ""
    echo "Environment Variables Used:"
    echo "  MSYSTEM  - Determines the target subsystem (UCRT64, MINGW64, CLANG64, MSYS)"
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    show_help
    exit 0
fi

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
        # --local keeps inherited MSYS2 system (pacman) packages out of the
        # manifest, so the restore below never tries to pip-build something like
        # matplotlib that pacman already provides via the system site-packages.
        "$CANONICAL_PYTHON" -m pip freeze --local > "$CANONICAL_PACKAGES"
    fi

    echo "Removing existing canonical venv at $CANONICAL_VENV"
    rm -rf "$CANONICAL_VENV"
fi

echo "Creating canonical venv at $CANONICAL_VENV"
# --system-site-packages so the venv can see MSYS2's pacman-built packages
# (matplotlib, scipy, pandas, ...), which are impractical to pip-build here.
# The matching --local in pip freeze/restore keeps those out of the manifest.
python -m venv --system-site-packages "$CANONICAL_VENV"
"$CANONICAL_PYTHON" -m pip install --upgrade pip

if [ -f "$CANONICAL_PACKAGES" ]; then
    echo "Restoring canonical packages from $CANONICAL_PACKAGES"
    "$CANONICAL_PYTHON" -m pip install -r "$CANONICAL_PACKAGES"
fi