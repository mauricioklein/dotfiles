#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd -P)"
MISE_INSTALLER=""
GIT_CONFIG_TMP=""

cleanup() {
  local status=$?
  if [[ -n "$MISE_INSTALLER" ]]; then
    rm -f "$MISE_INSTALLER"
  fi
  if [[ -n "$GIT_CONFIG_TMP" ]]; then
    rm -f "$GIT_CONFIG_TMP"
  fi
  return "$status"
}
trap cleanup EXIT

echo "==================================================================="
echo "  Dotfiles Bootstrap (mise-powered)"
echo "==================================================================="
echo ""
echo "Dotfiles location: $DOTFILES_DIR"
echo ""

# ── Step 0: Ensure mise is available ──
if ! command -v mise >/dev/null 2>&1; then
  echo "mise not found — installing the official mise binary"
  if ! command -v curl >/dev/null 2>&1; then
    echo "✗ Error: curl is required to install mise"
    exit 1
  fi
  MISE_INSTALLER="$(mktemp "${TMPDIR:-/tmp}/mise-bootstrap.XXXXXX")"
  curl -fsSL https://mise.run -o "$MISE_INSTALLER"
  sh "$MISE_INSTALLER"
  export PATH="$HOME/.local/bin:$PATH"
  command -v mise >/dev/null 2>&1 || {
    echo "✗ Error: mise installation completed but the binary was not found"
    exit 1
  }
  echo "  ✓ mise installed"
fi

# ── Step 1: Chicken-and-egg — mise needs its config before it can manage dotfiles ──
echo "── Step 1: Bootstrap symlinks"

# ~/.dotfiles → repo (zsh config references this path)
# -n: don't follow an existing dir symlink, replace it (idempotent re-runs)
ln -sfn "$DOTFILES_DIR" "$HOME/.dotfiles"
echo "  ✓ ~/.dotfiles → $DOTFILES_DIR"

# mise config → repo root (relative sources resolve from repo root)
# Clean up broken symlink leftover from pre-mise-dotfiles era
[[ -L "$HOME/.config/mise" && ! -e "$HOME/.config/mise" ]] && rm "$HOME/.config/mise"
mkdir -p "$HOME/.config/mise"
ln -sf "$DOTFILES_DIR/mise.toml" "$HOME/.config/mise/config.toml"
echo "  ✓ ~/.config/mise/config.toml → mise.toml"

# Trust the config (required when symlink points outside ~/.config/mise/)
mise trust "$DOTFILES_DIR/mise.toml" 2>/dev/null || true
echo "  ✓ mise.toml trusted"

# ── Step 2: Preserve Git identity outside the repository ──
echo ""
echo "── Step 2: Git identity"
GIT_CONFIG_LOCAL="$HOME/.gitconfig.local"
if [[ ! -e "$GIT_CONFIG_LOCAL" && ! -L "$GIT_CONFIG_LOCAL" ]]; then
  GIT_NAME="$(git config --global --includes --get user.name 2>/dev/null || true)"
  GIT_EMAIL="$(git config --global --includes --get user.email 2>/dev/null || true)"

  [[ -n "$GIT_NAME" ]] || read -r -p "  Git name: " GIT_NAME
  [[ -n "$GIT_EMAIL" ]] || read -r -p "  Git email: " GIT_EMAIL
  [[ -n "$GIT_NAME" && -n "$GIT_EMAIL" ]] || {
    echo "✗ Error: both Git name and email are required"
    exit 1
  }

  GIT_CONFIG_TMP="$(mktemp "${TMPDIR:-/tmp}/gitconfig-local.XXXXXX")"
  (
    umask 077
    git config --file "$GIT_CONFIG_TMP" user.name "$GIT_NAME"
    git config --file "$GIT_CONFIG_TMP" user.email "$GIT_EMAIL"
  )
  mv "$GIT_CONFIG_TMP" "$GIT_CONFIG_LOCAL"
  GIT_CONFIG_TMP=""
  echo "  ✓ ~/.gitconfig.local created"
else
  echo "  - ~/.gitconfig.local already exists (skipping)"
fi

# Mise will not replace an existing regular file with a symlink. Preserve the
# old managed copies rather than force-overwriting a possibly local file.
preserve_for_symlink() {
  local target="$1" backup="${1}.dotfiles-backup"

  if [[ -e "$target" && ! -L "$target" ]]; then
    if [[ -e "$backup" || -L "$backup" ]]; then
      echo "✗ Error: backup already exists: $backup"
      echo "  Move it aside after reviewing it, then rerun bootstrap"
      exit 1
    fi
    mv "$target" "$backup"
    echo "  ✓ preserved existing $target as $backup"
  fi
}
preserve_for_symlink "$HOME/.gitconfig"
preserve_for_symlink "$HOME/.hushlogin"

# ── Step 3: mise bootstrap (packages, dotfiles, tools, bootstrap task) ──
echo ""
echo "── Step 3: mise bootstrap"
mise bootstrap
echo "  ✓ Bootstrap complete"

echo ""
echo "==================================================================="
echo "  ✓ Bootstrap complete!"
echo "==================================================================="
echo ""
echo "Start a new shell to see changes:"
echo "  exec zsh"
echo ""
echo "Verify startup speed:"
echo "  time zsh -i -c exit"
echo "  (Should be <150ms)"
