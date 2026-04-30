#!/usr/bin/env bash

set -euo pipefail

venv_suffix=${DEV_SHELL_VENV_SUFFIX:-}
if [ -z "$venv_suffix" ]; then
	case "${DEV_SHELL_SUBSYSTEM:-${MSYSTEM:-}}" in
		UCRT64)
			venv_suffix=ucrt64
			;;
		MINGW64)
			venv_suffix=mingw64
			;;
		CLANG64)
			venv_suffix=clang64
			;;
		MSYS)
			venv_suffix=msys
			;;
		WINDOWS)
			venv_suffix=win
			;;
		*)
			venv_suffix=generic
			;;
	esac
fi

default_venv=${DEV_SHELL_DEFAULT_VENV:-$HOME/.venv-$venv_suffix}
active_kind=${DEV_SHELL_ACTIVE_VENV_KIND:-}
active_path=${DEV_SHELL_ACTIVE_VENV_PATH:-}
subsystem=${DEV_SHELL_SUBSYSTEM:-${MSYSTEM:-}}
fallback_default_venv=$HOME/.venv

if [ -z "$active_kind" ]; then
	if [ -f "$PWD/.venv-$venv_suffix/bin/activate" ] || [ -f "$PWD/.venv-$venv_suffix/Scripts/activate" ]; then
		active_kind=local
		active_path=$PWD/.venv-$venv_suffix
	elif [ -f "$PWD/.venv/bin/activate" ] || [ -f "$PWD/.venv/Scripts/activate" ]; then
		active_kind=local
		active_path=$PWD/.venv
	elif [ -f "$default_venv/bin/activate" ] || [ -f "$default_venv/Scripts/activate" ]; then
		active_kind=default
		active_path=$default_venv
	elif [ "$default_venv" != "$fallback_default_venv" ] && { [ -f "$fallback_default_venv/bin/activate" ] || [ -f "$fallback_default_venv/Scripts/activate" ]; }; then
		active_kind=default
		active_path=$fallback_default_venv
	fi
fi

printf 'DEV_SHELL_SUBSYSTEM=%s\n' "$subsystem"
printf 'DEV_SHELL_DEFAULT_VENV=%s\n' "$default_venv"
printf 'DEV_SHELL_ACTIVE_VENV_KIND=%s\n' "$active_kind"
printf 'DEV_SHELL_ACTIVE_VENV_PATH=%s\n' "$active_path"
printf 'VIRTUAL_ENV=%s\n' "${VIRTUAL_ENV:-}"