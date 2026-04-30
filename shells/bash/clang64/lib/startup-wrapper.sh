#!/usr/bin/env bash

export DEV_SHELL_SUBSYSTEM=CLANG64

_dev_shell_wrapper_dir=${BASH_SOURCE[0]%/*}
if [ -z "$_dev_shell_wrapper_dir" ] || [ "$_dev_shell_wrapper_dir" = "${BASH_SOURCE[0]}" ]; then
	_dev_shell_wrapper_dir=.
fi

# shellcheck disable=SC1091
. "$(cd "$_dev_shell_wrapper_dir" && pwd)/../../lib/startup-venv.sh"

unset _dev_shell_wrapper_dir