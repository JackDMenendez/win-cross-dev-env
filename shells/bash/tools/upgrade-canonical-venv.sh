#!/usr/bin/env bash

# upgrade-canonical-venv.sh - Upgrade pip and the installed Python packages in the
# canonical virtual environment for the current bash subsystem (UCRT64, MINGW64,
# CLANG64, MSYS). The interpreter is left untouched; only the packages move forward.

set -euo pipefail

show_help() {
    echo "Usage: $(basename "$0") [-h|--help] [package ...]"
    echo "Upgrades the canonical Python virtual environment for the current MSYSTEM."
    echo "With no arguments it upgrades pip/setuptools/wheel and every outdated package."
    echo "With package names it upgrades only those packages."
    echo ""
    echo "Only packages installed INTO the venv are touched (pip --local). Packages"
    echo "inherited from the MSYS2 system site-packages (pacman-managed, e.g. matplotlib,"
    echo "scipy, pandas) are intentionally left alone - upgrade those with 'pacman -Syu'."
    echo ""
    echo "The current package set is saved to <manifest>.bak before upgrading, and the"
    echo "manifest is refreshed afterwards so build-canonical-venv.sh stays in sync."
    echo ""
    echo "This only moves package versions; it does NOT update the MSYS2 interpreter."
    echo "Run 'pacman -Syu' (see lib/update-packages.sh) and then build-canonical-venv.sh"
    echo "to rebuild against a newer interpreter."
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
        echo "Unsupported MSYSTEM for canonical venv upgrade: ${MSYSTEM:-unset}" >&2
        exit 1
        ;;
esac

CANONICAL_VENV="$HOME/.venv-$VENV_SUFFIX"
CANONICAL_PYTHON="$CANONICAL_VENV/bin/python"
CANONICAL_PACKAGES="$HOME/canonical-packages-$VENV_SUFFIX.txt"

if [ ! -x "$CANONICAL_PYTHON" ]; then
    echo "Canonical venv not found at $CANONICAL_VENV" >&2
    echo "Create it first with build-canonical-venv.sh (from this same $MSYSTEM shell)." >&2
    exit 1
fi

# Back up the current package set so an upgrade can be rolled back by restoring
# the .bak over the manifest and re-running build-canonical-venv.sh. --local keeps
# inherited system (pacman) packages out of the manifest.
echo "Saving pre-upgrade package set to $CANONICAL_PACKAGES.bak"
"$CANONICAL_PYTHON" -m pip freeze --local > "$CANONICAL_PACKAGES.bak"

# Upgrade pip itself first so the resolver is current. setuptools/wheel are left
# to pacman (they live in the system site-packages); --local upgrades below pick
# them up only if they were actually pip-installed into this venv.
echo "Upgrading pip in $CANONICAL_VENV"
"$CANONICAL_PYTHON" -m pip install --upgrade pip

if [ "$#" -gt 0 ]; then
    targets=("$@")
    echo "Upgrading ${#targets[@]} requested package(s): ${targets[*]}"
    "$CANONICAL_PYTHON" -m pip install --upgrade "${targets[@]}"
else
    # Ask pip (in JSON, which is stable across pip versions) for outdated packages,
    # then let the venv's own Python parse the names. --local excludes packages
    # inherited from the MSYS2 system site-packages (pacman-managed), so we never
    # try to pip-build something like matplotlib that pacman already provides.
    mapfile -t targets < <("$CANONICAL_PYTHON" -m pip list --outdated --local --format=json \
        | "$CANONICAL_PYTHON" -c 'import sys, json
for pkg in json.load(sys.stdin):
    print(pkg["name"])')

    if [ "${#targets[@]}" -eq 0 ]; then
        echo "All packages in $CANONICAL_VENV are already up to date."
    else
        echo "Upgrading ${#targets[@]} outdated package(s): ${targets[*]}"
        "$CANONICAL_PYTHON" -m pip install --upgrade "${targets[@]}"
    fi
fi

echo "Refreshing manifest $CANONICAL_PACKAGES"
"$CANONICAL_PYTHON" -m pip freeze --local > "$CANONICAL_PACKAGES"

echo "Done. Upgraded the canonical $VENV_SUFFIX venv at $CANONICAL_VENV"
