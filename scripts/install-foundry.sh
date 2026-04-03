#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cargo_root="$repo_root/codex-rs"
install_root="${CARGO_HOME:-$HOME/.cargo}"

args=("$@")
for ((i = 0; i < ${#args[@]}; i++)); do
  case "${args[i]}" in
    --root)
      if ((i + 1 < ${#args[@]})); then
        install_root="${args[i + 1]}"
      fi
      ;;
    --root=*)
      install_root="${args[i]#--root=}"
      ;;
  esac
done

cd "$cargo_root"
cargo install --path cli --force "$@"

install_bin="$install_root/bin/foundry"
if command -v foundry >/dev/null 2>&1; then
  install_bin="$(command -v foundry)"
fi

printf 'Installed foundry to %s\n' "$install_bin"
