#!/usr/bin/env bash

# sync-repo-to-canonical.sh - Re-pin a repo venv's shared packages to the
# canonical venv's versions for the current MSYSTEM. A package is "shared" when
# it is pip-installed (venv-local) in BOTH the repo venv and the canonical venv;
# such packages are aligned to the canonical version. Canonical-only packages are
# NOT added, repo-only packages are left untouched, and editable/VCS installs are
# never modified. Comparing venv-local-to-venv-local deliberately ignores pacman
# system-site packages (already shared via C:\msys64) so we never try to pip-build
# something like matplotlib that has no wheel. See canonical-venv-superset-policy.

set -euo pipefail

show_help() {
    echo "Usage: $(basename "$0") [-h|--help] [-n|--dry-run] [repo-dir]"
    echo "Aligns a repo venv's package versions to the canonical ~/.venv-<suffix>"
    echo "for the current MSYSTEM. Only packages pip-installed in BOTH the repo venv"
    echo "and the canonical venv are re-pinned to the canonical version; nothing is"
    echo "added or removed. Editable (-e) and direct/VCS-reference installs are skipped."
    echo ""
    echo "  repo-dir   Repo dir containing .venv-<suffix> (or .venv). Default: CWD."
    echo "  -n         Dry run: report the version changes, change nothing."
    echo ""
    echo "Syncs the live venv only; it does NOT edit the repo's virtual-env-requirements.txt."
    echo ""
    echo "Environment Variables Used:"
    echo "  MSYSTEM  - Determines the subsystem/suffix (UCRT64, MINGW64, CLANG64, MSYS)"
}

DRY_RUN=0
REPO_DIR=
while [ "$#" -gt 0 ]; do
    case "$1" in
        -h|--help) show_help; exit 0 ;;
        -n|--dry-run) DRY_RUN=1; shift ;;
        -*) echo "Unknown option: $1" >&2; show_help >&2; exit 2 ;;
        *) REPO_DIR="$1"; shift ;;
    esac
done
[ -n "$REPO_DIR" ] || REPO_DIR="$PWD"

case "${MSYSTEM:-}" in
    UCRT64) VENV_SUFFIX=ucrt64 ;;
    MINGW64) VENV_SUFFIX=mingw64 ;;
    CLANG64) VENV_SUFFIX=clang64 ;;
    MSYS) VENV_SUFFIX=msys ;;
    *) echo "Unsupported MSYSTEM for repo venv sync: ${MSYSTEM:-unset}" >&2; exit 1 ;;
esac

CANONICAL_VENV="$HOME/.venv-$VENV_SUFFIX"
CANONICAL_PYTHON="$CANONICAL_VENV/bin/python"
if [ ! -x "$CANONICAL_PYTHON" ]; then
    echo "Canonical venv not found at $CANONICAL_VENV" >&2
    echo "Create it with build-canonical-venv.sh first." >&2
    exit 1
fi

# Locate the repo venv python.
repo_python=
for cand in "$REPO_DIR/.venv-$VENV_SUFFIX/bin/python" "$REPO_DIR/.venv-$VENV_SUFFIX/Scripts/python.exe" \
            "$REPO_DIR/.venv/bin/python" "$REPO_DIR/.venv/Scripts/python.exe"; do
    if [ -x "$cand" ]; then repo_python="$cand"; break; fi
done
if [ -z "$repo_python" ]; then
    echo "No repo venv (.venv-$VENV_SUFFIX or .venv) with a python found under $REPO_DIR" >&2
    exit 1
fi

repo_venv_dir="$(cd "$(dirname "$repo_python")/.." && pwd -P)"
# Refuse to "sync" the canonical venv to itself.
if [ "$repo_venv_dir" = "$(cd "$CANONICAL_VENV" && pwd -P)" ]; then
    echo "Target is the canonical venv itself ($CANONICAL_VENV); nothing to sync." >&2
    exit 1
fi

# Parse a pip freeze on stdin -> "<normalized>\t<name>\t<version>" for index pins
# only (skip editable and direct/VCS references). tr -d '\r' handles Windows CRLF.
_freeze_triples='import sys, re
for line in sys.stdin:
    line = line.strip()
    if not line or line.startswith("#") or line.startswith("-e"):
        continue
    if " @ " in line:
        continue
    m = re.match(r"^([A-Za-z0-9._-]+)\s*==\s*(.+)$", line)
    if not m:
        continue
    name, ver = m.group(1), m.group(2)
    print(re.sub(r"[-_.]+", "-", name).lower() + "\t" + name + "\t" + ver)'

# Canonical version map: normalized name -> version (+ canonical spelling).
declare -A can_ver=() can_name=()
while IFS=$'\t' read -r norm name ver; do
    [ -n "$norm" ] || continue
    can_ver["$norm"]="$ver"
    can_name["$norm"]="$name"
done < <("$CANONICAL_PYTHON" -m pip freeze --local 2>/dev/null | "$CANONICAL_PYTHON" -c "$_freeze_triples" | tr -d '\r')

# Walk the repo venv; plan a re-pin where the canonical has a different version.
specs=()
report=()
while IFS=$'\t' read -r norm name ver; do
    [ -n "$norm" ] || continue
    canv="${can_ver[$norm]:-}"
    [ -n "$canv" ] || continue            # repo-only package -> leave untouched
    [ "$canv" != "$ver" ] || continue     # already at the canonical version
    specs+=("${can_name[$norm]}==$canv")
    report+=("$name  $ver -> $canv")
done < <("$repo_python" -m pip freeze --local 2>/dev/null | "$repo_python" -c "$_freeze_triples" | tr -d '\r')

if [ "${#specs[@]}" -eq 0 ]; then
    echo "Repo venv $repo_venv_dir is already in sync with canonical $VENV_SUFFIX (no shared packages differ)."
    exit 0
fi

echo "Re-pinning ${#specs[@]} shared package(s) in $repo_venv_dir to canonical $VENV_SUFFIX versions:"
for r in "${report[@]}"; do echo "  $r"; done

if [ "$DRY_RUN" -eq 1 ]; then
    echo "Dry run: not installing. Re-run without -n to apply."
    exit 0
fi

"$repo_python" -m pip install "${specs[@]}"
echo "Done. Shared packages in $repo_venv_dir now match canonical $VENV_SUFFIX."
