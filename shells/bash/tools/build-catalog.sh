#!/usr/bin/env bash

# build-catalog.sh - Regenerate catalog.md from the current .cmd and .sh inventory.

set -euo pipefail

script_dir=${BASH_SOURCE[0]%/*}
if [ -z "$script_dir" ] || [ "$script_dir" = "${BASH_SOURCE[0]}" ]; then
    script_dir=.
fi

repo_root=$(cd "$script_dir/../../.." && pwd)
python_cmd=

if command -v python >/dev/null 2>&1; then
    python_cmd=$(command -v python)
elif command -v python3 >/dev/null 2>&1; then
    python_cmd=$(command -v python3)
elif [ -x "$repo_root/.venv-win/Scripts/python.exe" ]; then
    python_cmd="$repo_root/.venv-win/Scripts/python.exe"
elif [ -x "/c/Windows/py.exe" ]; then
    python_cmd="/c/Windows/py.exe -3"
else
    echo "No Python interpreter found for build-catalog.sh" >&2
    exit 1
fi

$python_cmd "$repo_root/tools/generate_catalog.py"