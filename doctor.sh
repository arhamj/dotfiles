#!/usr/bin/env bash
# Drift alarm: verifies the live system still points at this repo and that
# homebrew installs match configuration.nix. Exits non-zero on any drift.
set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
FAIL=0

note()  { printf '%s\n' "$*"; }
ok()    { note "  ok:   $*"; }
bad()   { note "  DRIFT: $*"; FAIL=1; }

note "==> ~/.dotfiles stable path"
if [ "$(readlink "$HOME/.dotfiles" 2>/dev/null)" = "$DIR" ]; then
  ok "$HOME/.dotfiles -> $DIR"
else
  bad "$HOME/.dotfiles does not point at $DIR (run ./rebuild.sh)"
fi

note "==> symlinks into the repo"
check_link() { # $1 = path relative to $HOME
  local target="$HOME/$1"
  local resolved
  # Fully resolve: home-manager's mkOutOfStoreSymlink chains through the
  # nix store before reaching the repo, so a single readlink is not enough.
  resolved="$(readlink -f "$target" 2>/dev/null || true)"
  case "$resolved" in
    "$DIR"/*) ok "$1" ;;
    *) bad "$1 is not a symlink into the repo (found: ${resolved:-missing})" ;;
  esac
}
check_link ".config/ghostty/config.ghostty"
check_link ".config/ghostty/themes"
check_link ".wezterm.lua"
check_link ".hammerspoon"
check_link ".config/nvim"
check_link ".config/herdr/config.toml"
check_link ".gitconfig"
check_link ".gitignore_global"
check_link ".claude/settings.json"
check_link "AGENTS.md"
check_link ".claude/CLAUDE.md"
check_link ".codex/AGENTS.md"
check_link ".config/opencode/AGENTS.md"
check_link ".pi/agent/AGENTS.md"

note "==> homebrew vs configuration.nix"
if command -v brew >/dev/null 2>&1; then
  # installed but not declared (cleanup="zap" would delete these)
  while read -r f; do
    [ -z "$f" ] && continue
    grep -q "\"$f\"" "$DIR/configuration.nix" || bad "brew formula installed but not declared: $f"
  done < <(brew leaves)
  while read -r c; do
    [ -z "$c" ] && continue
    grep -q "\"$c\"" "$DIR/configuration.nix" || bad "brew cask installed but not declared: $c"
  done < <(brew list --cask)
  # declared but not installed (forgot to rebuild)
  while read -r d; do
    [ -z "$d" ] && continue
    brew list --formula >/dev/null 2>&1
    brew list "$d" >/dev/null 2>&1 || brew list --cask "$d" >/dev/null 2>&1 \
      || bad "declared but not installed (run ./rebuild.sh): $d"
  done < <(sed -nE 's/^[[:space:]]*"([^"]+)"$/\1/p' "$DIR/configuration.nix" | grep -v '/')
else
  note "  brew not found, skipping package checks"
fi

if [ "$FAIL" -eq 0 ]; then
  note "==> no drift detected"
else
  note "==> drift detected, see lines above"
fi
exit "$FAIL"
