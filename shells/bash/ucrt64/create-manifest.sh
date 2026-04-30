#!/usr/bin/env bash

set -euo pipefail

_dev_shell_wrapper_dir=${BASH_SOURCE[0]%/*}
if [ -z "$_dev_shell_wrapper_dir" ] || [ "$_dev_shell_wrapper_dir" = "${BASH_SOURCE[0]}" ]; then
	_dev_shell_wrapper_dir=.
fi

exec "$(cd "$_dev_shell_wrapper_dir/../tools" && pwd)/create-manifest.sh"
