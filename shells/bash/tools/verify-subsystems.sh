#!/usr/bin/env bash

# ------------------------------------------------------------
# verify-subsystems.sh
# Checks that each MSYS2 prefix only contains packages for that prefix
# ------------------------------------------------------------

set -euo pipefail

echo "=== MSYS2 Subsystem Prefix Checker ==="
echo

check_shared_layout() {
    echo "--- Checking shared MSYS2 layout ---"

    local required_dirs=(/usr /var/tools/pacman /ucrt64 /mingw64 /clang64)
    local missing=0

    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            echo "[ERROR] Missing expected directory: $dir"
            missing=1
        fi
    done

    if [[ $missing -eq 0 ]]; then
        echo "[OK] Shared MSYS2 layout is present"
    else
        echo "[WARNING] Shared MSYS2 layout is incomplete"
    fi

    echo
}

check_prefix() {
    local subsystem=$1
    local prefix=$2
    local expected_regex=$3

    echo "--- Checking $subsystem ($prefix) ---"

    if [[ ! -d "$prefix" ]]; then
        echo "[ERROR] Prefix not found: $prefix"
        echo
        return 1
    fi

    local contamination=0
    local found=0
    local pkg

    while read -r pkg; do
        [[ -z "$pkg" ]] && continue

        found=1

        if [[ ! "$pkg" =~ $expected_regex ]]; then
            echo "[CONTAMINATION] $pkg owns files under $prefix"
            contamination=1
        fi
    done < <(
        pacman -Ql \
            | awk -v prefix="$prefix/" '$2 ~ ("^" prefix) && $2 != prefix && $2 !~ /\/$/ { print $1 }' \
            | sort -u
    )

    if [[ $found -eq 0 ]]; then
        echo "[WARNING] No installed packages own files under $prefix"
    elif [[ $contamination -eq 0 ]]; then
        echo "[OK] $subsystem prefix is clean"
    else
        echo "[WARNING] $subsystem prefix has contamination"
    fi

    echo
}

check_shared_layout
check_prefix "UCRT64"  "/ucrt64"  '^mingw-w64-ucrt-x86_64-'
check_prefix "MINGW64" "/mingw64" '^mingw-w64-x86_64-'
check_prefix "CLANG64" "/clang64" '^mingw-w64-clang-x86_64-'

echo "=== Done ==="
