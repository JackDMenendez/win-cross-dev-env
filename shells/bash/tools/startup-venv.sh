#!/usr/bin/env bash

# Tracks the default per-user venv and repo-local venvs for interactive shells.

case $- in
    *i*) ;;
    *) return 0 2>/dev/null || exit 0 ;;
esac

if [ "${DEV_SHELL_STARTUP_VENV_LOADED:-0}" = "1" ]; then
    return 0 2>/dev/null || exit 0
fi

export DEV_SHELL_STARTUP_VENV_LOADED=1

_dev_shell_venv_suffix() {
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

export DEV_SHELL_VENV_SUFFIX="${DEV_SHELL_VENV_SUFFIX:-$(_dev_shell_venv_suffix)}"
export DEV_SHELL_DEFAULT_VENV="${DEV_SHELL_DEFAULT_VENV:-$HOME/.venv-$DEV_SHELL_VENV_SUFFIX}"

_dev_shell_script_dir=${BASH_SOURCE[0]%/*}
if [ -z "$_dev_shell_script_dir" ] || [ "$_dev_shell_script_dir" = "${BASH_SOURCE[0]}" ]; then
    _dev_shell_script_dir=.
fi
DEV_SHELL_BASH_ROOT=$(cd "$_dev_shell_script_dir/.." && pwd)
readonly DEV_SHELL_BASH_ROOT
unset _dev_shell_script_dir

_dev_shell_normalize_path() {
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

    preferred_paths+=("/c/Program Files/Git/cmd" "$DEV_SHELL_BASH_ROOT/tools" "$DEV_SHELL_BASH_ROOT")

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

_dev_shell_has_activate() {
    local venv_path=$1
    [ -f "$venv_path/bin/activate" ] || [ -f "$venv_path/Scripts/activate" ]
}

_dev_shell_find_local_venv() {
    local dir="${PWD}"
    local preferred_name=".venv-$DEV_SHELL_VENV_SUFFIX"
    local fallback_name=".venv"

    while [ -n "$dir" ] && [ "$dir" != "." ]; do
        if _dev_shell_has_activate "$dir/$preferred_name"; then
            printf '%s\n' "$dir/$preferred_name"
            return 0
        fi

        if _dev_shell_has_activate "$dir/$fallback_name"; then
            printf '%s\n' "$dir/$fallback_name"
            return 0
        fi

        if [ "$dir" = "/" ]; then
            break
        fi

        dir=$(dirname "$dir")
    done

    return 1
}

_dev_shell_find_default_venv() {
    if _dev_shell_has_activate "$DEV_SHELL_DEFAULT_VENV"; then
        printf '%s\n' "$DEV_SHELL_DEFAULT_VENV"
        return 0
    fi

    if [ "$DEV_SHELL_DEFAULT_VENV" != "$HOME/.venv" ] && _dev_shell_has_activate "$HOME/.venv"; then
        printf '%s\n' "$HOME/.venv"
        return 0
    fi

    return 1
}

_dev_shell_clear_venv_tracking() {
    unset DEV_SHELL_ACTIVE_VENV_KIND
    unset DEV_SHELL_ACTIVE_VENV_PATH
}

_dev_shell_activate_venv() {
    local venv_path=$1
    local venv_kind=$2
    local activate_script=

    if [ -f "$venv_path/bin/activate" ]; then
        activate_script="$venv_path/bin/activate"
    elif [ -f "$venv_path/Scripts/activate" ]; then
        activate_script="$venv_path/Scripts/activate"
    else
        return 1
    fi

    if [ "${VIRTUAL_ENV:-}" != "$venv_path" ] && declare -F deactivate >/dev/null; then
        deactivate >/dev/null 2>&1 || true
    fi

    if [ "${VIRTUAL_ENV:-}" != "$venv_path" ]; then
        # shellcheck disable=SC1090
        . "$activate_script"
    fi

    _dev_shell_normalize_path
    export DEV_SHELL_ACTIVE_VENV_KIND="$venv_kind"
    export DEV_SHELL_ACTIVE_VENV_PATH="$venv_path"
}

dev_shell_sync_venv() {
    local local_venv=
    local default_venv=

    if local_venv=$(_dev_shell_find_local_venv); then
        _dev_shell_activate_venv "$local_venv" "local"
        return 0
    fi

    if default_venv=$(_dev_shell_find_default_venv); then
        _dev_shell_activate_venv "$default_venv" "default"
        return 0
    fi

    if [ -n "${VIRTUAL_ENV:-}" ] && declare -F deactivate >/dev/null; then
        deactivate >/dev/null 2>&1 || true
    fi

    _dev_shell_clear_venv_tracking
    _dev_shell_normalize_path
}

__dev_shell_prompt_venv_hook() {
    dev_shell_sync_venv
}

case ";${PROMPT_COMMAND:-};" in
    *";__dev_shell_prompt_venv_hook;"*) ;;
    *)
        if [ -n "${PROMPT_COMMAND:-}" ]; then
            PROMPT_COMMAND="__dev_shell_prompt_venv_hook; ${PROMPT_COMMAND}"
        else
            PROMPT_COMMAND="__dev_shell_prompt_venv_hook"
        fi
        ;;
esac

dev_shell_sync_venv