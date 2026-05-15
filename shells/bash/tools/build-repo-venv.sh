#!/usr/bin/env bash

set -euo pipefail

show_help() {
    echo "Usage: $(basename "$0") [-h|--help] [repo-dir]"
    echo "Rebuilds a repo-local Python virtual environment for the current MSYSTEM."
    echo "It preserves packages already installed in the venv when one exists,"
    echo "creates a fresh venv, upgrades pip, and restores the saved package set."
    echo "If no repo venv exists yet, it creates the preferred repo-local venv and"
    echo "installs virtual-env-requirements.txt when present."
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
            echo "Unsupported MSYSTEM for repo venv build: ${MSYSTEM:-unset}"
            exit 1
            ;;
    esac
}

creator_python() {
    local suffix=$1
    local candidates=(
        "$HOME/.venv-$suffix/bin/python"
        "$HOME/.venv-$suffix/Scripts/python.exe"
    )

    case "${MSYSTEM:-}" in
        UCRT64)
            candidates+=("/ucrt64/bin/python")
            ;;
        MINGW64)
            candidates+=("/mingw64/bin/python")
            ;;
        CLANG64)
            candidates+=("/clang64/bin/python")
            ;;
        MSYS)
            candidates+=("/usr/bin/python")
            ;;
    esac

    local candidate
    for candidate in "${candidates[@]}"; do
        if [ -x "$candidate" ]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done

    echo "No Python interpreter found for ${MSYSTEM:-unset}"
    exit 1
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
    target_venv="$preferred_venv"
fi

target_python="$target_venv/bin/python"
if [ ! -x "$target_python" ] && [ -x "$target_venv/Scripts/python.exe" ]; then
    target_python="$target_venv/Scripts/python.exe"
fi

requirements_snapshot=
cleanup_snapshot() {
    if [ -n "$requirements_snapshot" ] && [ -f "$requirements_snapshot" ]; then
        rm -f "$requirements_snapshot"
    fi
}
trap cleanup_snapshot EXIT

if [ -d "$target_venv" ] && [ -x "$target_python" ]; then
    requirements_snapshot=$(mktemp)
    echo "Saving repo packages to $requirements_snapshot"
    "$target_python" -m pip freeze --local > "$requirements_snapshot"
fi

if [ -d "$target_venv" ]; then
    echo "Removing existing repo venv at $target_venv"
    rm -rf "$target_venv"
fi

build_python=$(creator_python "$suffix")
echo "Creating repo venv at $target_venv"
"$build_python" -m venv --system-site-packages "$target_venv"

target_python="$target_venv/bin/python"
if [ ! -x "$target_python" ] && [ -x "$target_venv/Scripts/python.exe" ]; then
    target_python="$target_venv/Scripts/python.exe"
fi

"$target_python" -m pip install --upgrade pip

if [ -n "$requirements_snapshot" ] && [ -s "$requirements_snapshot" ]; then
    echo "Restoring repo packages from saved snapshot"
    "$target_python" -m pip install -r "$requirements_snapshot"
elif [ -f "$repo_dir/virtual-env-requirements.txt" ]; then
    echo "Installing requirements from $repo_dir/virtual-env-requirements.txt"
    "$target_python" -m pip install -r "$repo_dir/virtual-env-requirements.txt"
fi
