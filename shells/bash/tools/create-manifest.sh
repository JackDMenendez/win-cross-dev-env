#!/usr/bin/env bash

set -euo pipefail

case "$MSYSTEM" in
    MSYS)
        PREFIX="msys64"
        PACKAGE_REGEX='^(?!mingw-w64-).+'
        ;;
    UCRT64)
        PREFIX="ucrt64"
        PACKAGE_REGEX='^mingw-w64-ucrt-x86_64-'
        ;;
    MINGW64)
        PREFIX="mingw64"
        PACKAGE_REGEX='^mingw-w64-x86_64-'
        ;;
    CLANG64)
        PREFIX="clang64"
        PACKAGE_REGEX='^mingw-w64-clang-x86_64-'
        ;;
    *)
        echo "Unknown MSYSTEM: $MSYSTEM"
        exit 1
        ;;
esac

_dev_shell_manifest_script_dir=${BASH_SOURCE[0]%/*}
if [ -z "$_dev_shell_manifest_script_dir" ] || [ "$_dev_shell_manifest_script_dir" = "${BASH_SOURCE[0]}" ]; then
    _dev_shell_manifest_script_dir=.
fi
_dev_shell_manifest_bash_root=$(cd "$_dev_shell_manifest_script_dir/.." && pwd)
BASE="$_dev_shell_manifest_bash_root/$PREFIX"
unset _dev_shell_manifest_script_dir _dev_shell_manifest_bash_root

mkdir -p "$BASE"

filter_packages() {
    perl -ne "print if /$PACKAGE_REGEX/"
}

echo "Saving explicit package list to $BASE/pkg-$PREFIX.txt"
pacman -Qqet | filter_packages > "$BASE/pkg-$PREFIX.txt"

echo "Restoring packages..."
if [[ -s "$BASE/pkg-$PREFIX.txt" ]]; then
    pacman -S --needed - < "$BASE/pkg-$PREFIX.txt"
else
    echo "No matching explicit packages for $MSYSTEM"
fi

echo "Saving full manifest to $BASE/manifest-$PREFIX.txt"
pacman -Q | filter_packages > "$BASE/manifest-$PREFIX.txt"

echo "Done for $MSYSTEM"
