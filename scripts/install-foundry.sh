#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cargo_root="$repo_root/codex-rs"
install_root="${CARGO_HOME:-$HOME/.cargo}"
target_dir="${CARGO_TARGET_DIR:-$cargo_root/target}"
use_locked=true
build_mode="release"

args=("$@")
passthrough_args=()
for ((i = 0; i < ${#args[@]}; i++)); do
  case "${args[i]}" in
    --locked|--frozen)
      use_locked=false
      passthrough_args+=("${args[i]}")
      ;;
    --debug)
      build_mode="debug"
      ;;
    --force)
      ;;
    --target-dir)
      if ((i + 1 >= ${#args[@]})); then
        printf 'Missing value for --target-dir\n' >&2
        exit 1
      fi
      target_dir="${args[i + 1]}"
      passthrough_args+=("${args[i]}" "${args[i + 1]}")
      ((i += 1))
      ;;
    --target-dir=*)
      target_dir="${args[i]#--target-dir=}"
      passthrough_args+=("${args[i]}")
      ;;
    --root)
      if ((i + 1 >= ${#args[@]})); then
        printf 'Missing value for --root\n' >&2
        exit 1
      fi
      install_root="${args[i + 1]}"
      ((i += 1))
      ;;
    --root=*)
      install_root="${args[i]#--root=}"
      ;;
    *)
      passthrough_args+=("${args[i]}")
      ;;
  esac
done

cd "$cargo_root"
cargo_args=(build -p codex-cli --bin foundry)
if ((${#passthrough_args[@]})); then
  cargo_args+=("${passthrough_args[@]}")
fi
if [[ "$use_locked" == true ]]; then
  cargo_args+=(--locked)
fi
if [[ "$build_mode" == "release" ]]; then
  cargo_args+=(--release)
fi
cargo "${cargo_args[@]}"

install_bin_dir="$install_root/bin"
mkdir -p "$install_bin_dir"
build_bin="$(find "$target_dir" -type f -path "*/$build_mode/foundry" -print -quit)"
if [[ -z "$build_bin" ]]; then
  printf 'Built foundry binary not found under %s\n' "$target_dir" >&2
  exit 1
fi
install -m 755 "$build_bin" "$install_bin_dir/foundry"

install_bin="$install_root/bin/foundry"
printf 'Installed foundry to %s\n' "$install_bin"
