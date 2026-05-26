#!/usr/bin/env bash

# run-container.sh - Run a command inside the repo-configured container image.

set -euo pipefail

show_help() {
    echo "Usage: $(basename "$0") [-h|--help] <command> [args...]"
    echo "Runs a command inside the container configured by .dev-shell/container.conf."
    echo ""
    echo "The runner searches upward from the current directory for .dev-shell/container.conf,"
    echo "mounts that repository at /workspace by default, and executes the requested command."
    echo ""
    echo "Config variables recognized:" 
    echo "  DEV_SHELL_CONTAINER_ENGINE           Optional. Defaults to docker or podman if found."
    echo "  DEV_SHELL_CONTAINER_IMAGE            Required. Image to run."
    echo "  DEV_SHELL_CONTAINER_WORKDIR          Optional. Defaults to /workspace."
    echo "  DEV_SHELL_CONTAINER_ENV_PASSTHROUGH  Optional. Space-separated environment names."
    echo "  DEV_SHELL_CONTAINER_CACHE_VOLUMES    Optional. Space-separated volume specs."
    echo "  DEV_SHELL_CONTAINER_EXTRA_ARGS       Optional. Extra engine run arguments."
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    show_help
    exit 0
fi

if [[ $# -eq 0 ]]; then
    show_help >&2
    exit 1
fi

find_container_config() {
    local dir=$PWD

    while :; do
        if [[ -f "$dir/.dev-shell/container.conf" ]]; then
            printf '%s\n' "$dir"
            return 0
        fi

        if [[ "$dir" == "/" ]]; then
            break
        fi

        dir=$(dirname "$dir")
    done

    return 1
}

if ! repo_dir=$(find_container_config); then
    echo "Container config not found. Expected .dev-shell/container.conf in the current repo or a parent directory." >&2
    exit 1
fi

config_path="$repo_dir/.dev-shell/container.conf"

# shellcheck disable=SC1090
. "$config_path"

if [[ -z "${DEV_SHELL_CONTAINER_IMAGE:-}" ]]; then
    echo "DEV_SHELL_CONTAINER_IMAGE is required in $config_path" >&2
    exit 1
fi

if [[ -z "${DEV_SHELL_CONTAINER_ENGINE:-}" ]]; then
    if command -v docker >/dev/null 2>&1; then
        DEV_SHELL_CONTAINER_ENGINE=docker
    elif command -v podman >/dev/null 2>&1; then
        DEV_SHELL_CONTAINER_ENGINE=podman
    else
        echo "No container engine found. Install docker or podman, or set DEV_SHELL_CONTAINER_ENGINE." >&2
        exit 1
    fi
fi

if ! command -v "$DEV_SHELL_CONTAINER_ENGINE" >/dev/null 2>&1; then
    echo "Configured container engine not found: $DEV_SHELL_CONTAINER_ENGINE" >&2
    exit 1
fi

container_workdir=${DEV_SHELL_CONTAINER_WORKDIR:-/workspace}

if command -v cygpath >/dev/null 2>&1; then
    repo_mount=$(cygpath -m "$repo_dir")
else
    repo_mount=$repo_dir
fi

run_args=(run --rm -i)

if [[ -t 0 && -t 1 && -z "${CI:-}" ]]; then
    run_args+=(-t)
fi

run_args+=(
    -v "$repo_mount:$container_workdir"
    -w "$container_workdir"
)

read -r -a passthrough_vars <<< "${DEV_SHELL_CONTAINER_ENV_PASSTHROUGH:-}"
for var_name in "${passthrough_vars[@]}"; do
    [[ -n "$var_name" ]] || continue

    if [[ -n "${!var_name+x}" ]]; then
        run_args+=(--env "$var_name")
    fi
done

read -r -a cache_volumes <<< "${DEV_SHELL_CONTAINER_CACHE_VOLUMES:-}"
for volume_spec in "${cache_volumes[@]}"; do
    [[ -n "$volume_spec" ]] || continue
    run_args+=(--volume "$volume_spec")
done

read -r -a extra_args <<< "${DEV_SHELL_CONTAINER_EXTRA_ARGS:-}"
for extra_arg in "${extra_args[@]}"; do
    [[ -n "$extra_arg" ]] || continue
    run_args+=("$extra_arg")
done

MSYS_NO_PATHCONV=1 MSYS2_ARG_CONV_EXCL='*' \
    "$DEV_SHELL_CONTAINER_ENGINE" "${run_args[@]}" "$DEV_SHELL_CONTAINER_IMAGE" "$@"