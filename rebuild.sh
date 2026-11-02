#!/usr/bin/env bash
set -euo pipefail

# Run as your normal user; the script calls sudo itself.
if [ "$EUID" -eq 0 ]; then
  echo "Run this as your normal user, not with sudo." >&2
  exit 1
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
FLAKE="$HOME/.dotfiles#mac"

# Keep ~/.dotfiles pointing at this repo (skip if it already does)
[ "$DIR" -ef ~/.dotfiles ] || ln -sfn "$DIR" ~/.dotfiles

# Flakes only see git-tracked files, so mark new files as intent-to-add
git -C "$DIR" add -N . 2>/dev/null || true

if command -v darwin-rebuild >/dev/null 2>&1; then
  exec sudo -H darwin-rebuild switch --flake "$FLAKE" "$@"
elif [ -x /run/current-system/sw/bin/darwin-rebuild ]; then
  exec sudo -H /run/current-system/sw/bin/darwin-rebuild switch --flake "$FLAKE" "$@"
else
  # First run: nix-darwin isn't installed yet, so bootstrap it through nix
  exec sudo -H nix --extra-experimental-features 'nix-command flakes' \
    run github:nix-darwin/nix-darwin/nix-darwin-26.05#darwin-rebuild -- \
    switch --flake "$FLAKE" "$@"
fi
