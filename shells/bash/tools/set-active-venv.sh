#!/usr/bin/env bash

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    echo "Source this script instead of executing it: . ${BASH_SOURCE[0]} [venv-path]" >&2
    exit 1
fi

_dev_shell_set_script_dir=${BASH_SOURCE[0]%/*}
if [ -z "$_dev_shell_set_script_dir" ] || [ "$_dev_shell_set_script_dir" = "${BASH_SOURCE[0]}" ]; then
    _dev_shell_set_script_dir=.
fi
DEV_SHELL_SET_BASH_ROOT=$(cd "$_dev_shell_set_script_dir/.." && pwd)
readonly DEV_SHELL_SET_BASH_ROOT
unset _dev_shell_set_script_dir

_dev_shell_set_venv_suffix() {
    case "${DEV_SHELL_SUBSYSTEM:-${MSYSTEM:-}}" in
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
        WINDOWS)
            printf 'win\n'
            ;;
        *)
            printf 'generic\n'
            ;;
    esac
}

_dev_shell_set_has_activate() {
    local venv_path=$1
    [ -f "$venv_path/bin/activate" ] || [ -f "$venv_path/Scripts/activate" ]
}

_dev_shell_set_find_default() {
    if _dev_shell_set_has_activate "$DEV_SHELL_DEFAULT_VENV"; then
        printf '%s\n' "$DEV_SHELL_DEFAULT_VENV"
        return 0
    fi

    if [ "$DEV_SHELL_DEFAULT_VENV" != "$HOME/.venv" ] && _dev_shell_set_has_activate "$HOME/.venv"; then
        printf '%s\n' "$HOME/.venv"
        return 0
    fi

    return 1
}

_dev_shell_set_normalize_path() {
    local preferred_paths=()
    local path_parts=()
    local normalized_path=
    local path_entry
    declare -A seen_paths=()

    case "${DEV_SHELL_SUBSYSTEM:-${MSYSTEM:-}}" in
        UCRT64)
            preferred_paths+=("/ucrt64/bin")
            ;;
        MINGW64)
            preferred_paths+=("/mingw64/bin")
            ;;
        CLANG64)
            preferred_paths+=("/clang64/bin")
            ;;
        MSYS)
            preferred_paths+=("/usr/bin")
            ;;
    esac

    if [ -n "${VIRTUAL_ENV:-}" ]; then
        if [ -d "$VIRTUAL_ENV/bin" ]; then
            preferred_paths=("$VIRTUAL_ENV/bin" "${preferred_paths[@]}")
        elif [ -d "$VIRTUAL_ENV/Scripts" ]; then
            preferred_paths=("$VIRTUAL_ENV/Scripts" "${preferred_paths[@]}")
        fi
    fi

    preferred_paths+=("/c/Program Files/Git/cmd" "$DEV_SHELL_SET_BASH_ROOT/tools" "$DEV_SHELL_SET_BASH_ROOT")

    for path_entry in "${preferred_paths[@]}"; do
        [ -n "$path_entry" ] || continue

        if [ -z "${seen_paths[$path_entry]+x}" ]; then
            seen_paths[$path_entry]=1
            normalized_path="${normalized_path:+$normalized_path:}$path_entry"
        fi
    done

    IFS=':' read -r -a path_parts <<< "$PATH"
    for path_entry in "${path_parts[@]}"; do
        [ -n "$path_entry" ] || continue

        if [ -z "${seen_paths[$path_entry]+x}" ]; then
            seen_paths[$path_entry]=1
            normalized_path="${normalized_path:+$normalized_path:}$path_entry"
        fi
    done

    PATH=$normalized_path
    export PATH
}

_dev_shell_set_activate() {
    local venv_path=$1
    local venv_kind=$2
    local activate_script=

    if [ -f "$venv_path/bin/activate" ]; then
        activate_script="$venv_path/bin/activate"
    elif [ -f "$venv_path/Scripts/activate" ]; then
        activate_script="$venv_path/Scripts/activate"
    else
        echo "No activation script found in $venv_path" >&2
        return 1
    fi

    if [ -n "${VIRTUAL_ENV:-}" ] && [ "$VIRTUAL_ENV" != "$venv_path" ] && declare -F deactivate >/dev/null; then
        deactivate >/dev/null 2>&1 || true
    fi

    if [ "${VIRTUAL_ENV:-}" != "$venv_path" ]; then
        # shellcheck disable=SC1090
        . "$activate_script"
    fi

    _dev_shell_set_normalize_path
    export DEV_SHELL_VENV_SUFFIX="${DEV_SHELL_VENV_SUFFIX:-$(_dev_shell_set_venv_suffix)}"
    export DEV_SHELL_DEFAULT_VENV="${DEV_SHELL_DEFAULT_VENV:-$HOME/.venv-$DEV_SHELL_VENV_SUFFIX}"
    export DEV_SHELL_ACTIVE_VENV_KIND="$venv_kind"
    export DEV_SHELL_ACTIVE_VENV_PATH="$venv_path"
}

_dev_shell_set_suffix=$(_dev_shell_set_venv_suffix)
export DEV_SHELL_VENV_SUFFIX="${DEV_SHELL_VENV_SUFFIX:-$_dev_shell_set_suffix}"
export DEV_SHELL_DEFAULT_VENV="${DEV_SHELL_DEFAULT_VENV:-$HOME/.venv-$DEV_SHELL_VENV_SUFFIX}"

_dev_shell_set_target=${1:-}
_dev_shell_set_kind=explicit

if [ -z "$_dev_shell_set_target" ]; then
    if _dev_shell_set_has_activate "$PWD/.venv-$DEV_SHELL_VENV_SUFFIX"; then
        _dev_shell_set_target="$PWD/.venv-$DEV_SHELL_VENV_SUFFIX"
        _dev_shell_set_kind=local
    elif _dev_shell_set_has_activate "$PWD/.venv"; then
        _dev_shell_set_target="$PWD/.venv"
        _dev_shell_set_kind=local
    elif _dev_shell_set_default=$(_dev_shell_set_find_default); then
        _dev_shell_set_target="$_dev_shell_set_default"
        _dev_shell_set_kind=default
    else
        _dev_shell_set_target="$DEV_SHELL_DEFAULT_VENV"
    fi
fi

if ! _dev_shell_set_has_activate "$_dev_shell_set_target"; then
    echo "Virtual environment not found: $_dev_shell_set_target" >&2
    unset _dev_shell_set_suffix _dev_shell_set_target _dev_shell_set_kind _dev_shell_set_default
    return 1
fi

_dev_shell_set_activate "$_dev_shell_set_target" "$_dev_shell_set_kind"
unset _dev_shell_set_suffix _dev_shell_set_target _dev_shell_set_kind _dev_shell_set_default