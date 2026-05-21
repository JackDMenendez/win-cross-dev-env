#!/usr/bin/env bash

# dev-catalog.sh - Print the generated command catalog from any configured bash shell in the repo.

set -euo pipefail

script_dir=${BASH_SOURCE[0]%/*}
if [ -z "$script_dir" ] || [ "$script_dir" = "${BASH_SOURCE[0]}" ]; then
    script_dir=.
fi

catalog_path=$(cd "$script_dir/../../.." && pwd)/catalog.md

if [ ! -f "$catalog_path" ]; then
    echo "Catalog file not found: $catalog_path" >&2
    exit 1
fi

cat "$catalog_path"