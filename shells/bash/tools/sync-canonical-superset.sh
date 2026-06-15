#!/usr/bin/env bash

# sync-canonical-superset.sh - Make the canonical venv for the current MSYSTEM a
# SUPERSET of every repo .venv-<suffix> found under a root. It unions the repos'
# venv-local packages and pip-installs (no --upgrade) into the canonical venv
# only the ones the canonical cannot already provide -- where "provide" means
# already installed venv-local OR inherited from the MSYS2 system site-packages
# (pacman). See the canonical-venv-superset-policy.

set -euo pipefail

show_help() {
    echo "Usage: $(basename "$0") [-h|--help] [-n|--dry-run] [root-dir]"
    echo "Tops up the canonical ~/.venv-<suffix> for the current MSYSTEM so it is a"
    echo "superset of every repo .venv-<suffix> found under root-dir."
    echo ""
    echo "  root-dir   Directory to scan for <repo>/.venv-<suffix> venvs."
    echo "             Default: the parent of this dev-shell repo (e.g. C:/dev)."
    echo "  -n         Dry run: report what would be installed, change nothing."
    echo ""
    echo "Comparison is by normalized distribution name against the canonical venv's"
    echo "FULL package list, so pacman system-site packages count as already provided."
    echo "Missing packages are installed with plain 'pip install' (never --upgrade) so"
    echo "system-site/pacman versions are not shadowed. Version drift is expected."
    echo "Editable (-e) and direct/VCS-reference installs (e.g. project-local dcl_core,"
    echo "dcl_lattice_viewer) are skipped - they belong only in their own repo venv."
    echo ""
    echo "Environment Variables Used:"
    echo "  MSYSTEM             - Determines the target subsystem (UCRT64, MINGW64, CLANG64, MSYS)"
    echo "  WCDE_SUPERSET_DEPTH - find maxdepth under root-dir (default 3)"
}

DRY_RUN=0
ROOT=
while [ "$#" -gt 0 ]; do
    case "$1" in
        -h|--help) show_help; exit 0 ;;
        -n|--dry-run) DRY_RUN=1; shift ;;
        -*) echo "Unknown option: $1" >&2; show_help >&2; exit 2 ;;
        *) ROOT="$1"; shift ;;
    esac
done

case "${MSYSTEM:-}" in
    UCRT64) VENV_SUFFIX=ucrt64 ;;
    MINGW64) VENV_SUFFIX=mingw64 ;;
    CLANG64) VENV_SUFFIX=clang64 ;;
    MSYS) VENV_SUFFIX=msys ;;
    *) echo "Unsupported MSYSTEM for canonical venv superset sync: ${MSYSTEM:-unset}" >&2; exit 1 ;;
esac

CANONICAL_VENV="$HOME/.venv-$VENV_SUFFIX"
CANONICAL_PYTHON="$CANONICAL_VENV/bin/python"
CANONICAL_PACKAGES="$HOME/canonical-packages-$VENV_SUFFIX.txt"

if [ ! -x "$CANONICAL_PYTHON" ]; then
    echo "Canonical venv not found at $CANONICAL_VENV" >&2
    echo "Create it first with build-canonical-venv.sh (from this same $MSYSTEM shell)." >&2
    exit 1
fi

# Default root = parent of the dev-shell repo (this script is at
# <repo>/shells/bash/tools/sync-canonical-superset.sh).
if [ -z "$ROOT" ]; then
    _sd=${BASH_SOURCE[0]%/*}
    [ -n "$_sd" ] && [ "$_sd" != "${BASH_SOURCE[0]}" ] || _sd=.
    ROOT="$(cd "$_sd/../../../.." && pwd)"
fi
if [ ! -d "$ROOT" ]; then
    echo "Scan root not found: $ROOT" >&2
    exit 1
fi

DEPTH="${WCDE_SUPERSET_DEPTH:-3}"
CAN_REAL="$(cd "$CANONICAL_VENV" && pwd -P)"

# Print "<name>" lines for a pip list JSON on stdin (normalized, lowercase, PEP503-ish).
_names_norm='import sys, json, re
for p in json.load(sys.stdin):
    print(re.sub(r"[-_.]+", "-", p["name"]).lower())'
# Print "<normalized>\t<original>" for index-installable pins in a pip freeze on
# stdin. Skips editable (-e) and direct-reference ( @ git+/file:/url) installs, so
# project-local packages (e.g. dcl_core, dcl_lattice_viewer) are never treated as
# superset members -- they belong only in their own repo venv.
_freeze_pairs='import sys, re
for line in sys.stdin:
    line = line.strip()
    if not line or line.startswith("#") or line.startswith("-e"):
        continue
    if " @ " in line:
        continue
    m = re.match(r"^([A-Za-z0-9._-]+)\s*==", line)
    if not m:
        continue
    name = m.group(1)
    print(re.sub(r"[-_.]+", "-", name).lower() + "\t" + name)'

echo "Scanning $ROOT (maxdepth $DEPTH) for repo .venv-$VENV_SUFFIX venvs..."
mapfile -t venvs < <(find "$ROOT" -maxdepth "$DEPTH" -type d -name ".venv-$VENV_SUFFIX" 2>/dev/null | sort)

# Everything the canonical venv can already provide (venv-local + system-site).
declare -A available=()
while IFS= read -r norm; do
    [ -n "$norm" ] && available["$norm"]=1
# tr -d '\r': the venv pythons are Windows python.exe and emit CRLF; a trailing
# CR would corrupt the dict keys (and later the install args).
done < <("$CANONICAL_PYTHON" -m pip list --format=json 2>/dev/null | "$CANONICAL_PYTHON" -c "$_names_norm" | tr -d '\r')

# Union of repo venv-local packages: normalized name -> first original spelling seen.
declare -A want=()
sources=0
for v in "${venvs[@]}"; do
    [ -n "$v" ] || continue
    vpy="$v/bin/python"
    [ -x "$vpy" ] || { echo "  skip (no python): $v" >&2; continue; }
    real="$(cd "$v" && pwd -P)"
    [ "$real" = "$CAN_REAL" ] && continue   # never treat the canonical venv as a source
    n=0
    while IFS=$'\t' read -r norm orig; do
        [ -n "$norm" ] || continue
        [ -z "${want[$norm]+x}" ] && want["$norm"]="$orig"
        n=$((n + 1))
    done < <("$vpy" -m pip freeze --local 2>/dev/null | "$vpy" -c "$_freeze_pairs" | tr -d '\r')
    sources=$((sources + 1))
    echo "  scanned $v ($n venv-local packages)"
done

if [ "$sources" -eq 0 ]; then
    echo "No repo .venv-$VENV_SUFFIX venvs found under $ROOT; nothing to do."
    exit 0
fi

# Missing = wanted by some repo but not already provided by the canonical venv.
missing=()
for norm in "${!want[@]}"; do
    [ -z "${available[$norm]+x}" ] && missing+=("${want[$norm]}")
done
mapfile -t missing < <(printf '%s\n' "${missing[@]}" | sort)

if [ "${#missing[@]}" -eq 0 ] || { [ "${#missing[@]}" -eq 1 ] && [ -z "${missing[0]}" ]; }; then
    echo "Canonical $VENV_SUFFIX venv is already a superset of the $sources repo venv(s) scanned."
    exit 0
fi

echo "Canonical $VENV_SUFFIX venv is missing ${#missing[@]} package(s) used by repos: ${missing[*]}"

if [ "$DRY_RUN" -eq 1 ]; then
    echo "Dry run: not installing. Re-run without -n to apply."
    exit 0
fi

echo "Installing into $CANONICAL_VENV (plain install; system-site deps stay satisfied)..."
"$CANONICAL_PYTHON" -m pip install "${missing[@]}"

echo "Refreshing manifest $CANONICAL_PACKAGES"
"$CANONICAL_PYTHON" -m pip freeze --local > "$CANONICAL_PACKAGES"

echo "Done. Canonical $VENV_SUFFIX venv is now a superset of the $sources repo venv(s) scanned."
