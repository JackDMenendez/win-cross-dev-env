#!/usr/bin/env bash

# patch-repo-venv.sh - Install baseline repo tooling into an existing repo-local Python virtual environment.

set -euo pipefail

show_help() {
    echo "Usage: $(basename "$0") [-h|--help] [repo-dir]"
    echo "Installs baseline repo tooling into an existing repo-local Python virtual environment."
    echo "It does not rebuild the venv."
    echo ""
    echo "Arguments:"
    echo "  repo-dir  Optional repository directory. Defaults to the current directory."
    echo ""
    echo "Environment Variables Used:"
    echo "  MSYSTEM  - Determines the target subsystem (UCRT64, MINGW64, CLANG64, MSYS)"
}

venv_suffix() {
    case "${MSYSTEM:-}" in
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
            echo "Unsupported MSYSTEM for repo venv patch: ${MSYSTEM:-unset}"
            exit 1
            ;;
    esac
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    show_help
    exit 0
fi

if [[ $# -gt 1 ]]; then
    show_help
    exit 1
fi

repo_dir=${1:-$PWD}
repo_dir=$(cd "$repo_dir" && pwd)

suffix=$(venv_suffix)
preferred_venv="$repo_dir/.venv-$suffix"
fallback_venv="$repo_dir/.venv"

if [ -d "$preferred_venv" ]; then
    target_venv="$preferred_venv"
elif [ -d "$fallback_venv" ]; then
    target_venv="$fallback_venv"
else
    echo "Repository venv not found in $repo_dir"
    exit 1
fi

target_python="$target_venv/bin/python"
if [ ! -x "$target_python" ] && [ -x "$target_venv/Scripts/python.exe" ]; then
    target_python="$target_venv/Scripts/python.exe"
fi

if [ ! -x "$target_python" ]; then
    echo "Python interpreter not found in $target_venv"
    exit 1
fi

echo "Installing baseline repo tooling into $target_venv"
"$target_python" -m pip install isort