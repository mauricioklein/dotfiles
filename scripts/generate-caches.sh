#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CACHE_DIR="$DOTFILES_DIR/zsh/cache"

echo "Generating cache files..."

mkdir -p "$CACHE_DIR"

# Starship prompt init
if command -v starship &> /dev/null; then
  echo "  - Caching starship init..."
  starship init zsh > "$CACHE_DIR/starship-init.zsh"
else
  echo "  ⚠ Starship not found. Install it with: mise install"
fi

# Zoxide navigation init
if command -v zoxide &> /dev/null; then
  echo "  - Caching zoxide init..."
  zoxide init zsh > "$CACHE_DIR/zoxide-init.zsh"
else
  echo "  ⚠ Zoxide not found. Install it with: mise install"
fi

# FZF init
if command -v fzf &> /dev/null; then
  echo "  - Caching fzf init..."
  fzf --zsh > "$CACHE_DIR/fzf-init.zsh"
else
  echo "  ⚠ FZF not found. Install it with: mise install"
fi

# Worktrunk shell integration
if command -v wt &> /dev/null; then
  echo "  - Caching worktrunk shell init..."
  wt config shell init zsh > "$CACHE_DIR/worktrunk-init.zsh"
else
  echo "  ⚠ Worktrunk not found. Install it with: mise bootstrap packages apply"
fi

# Pre-compile zsh files for faster startup (zcompile is a zsh builtin)
if command -v zsh &> /dev/null; then
  echo "  - Pre-compiling zsh files..."
  zsh -c 'for f in "$0/.zshrc" "$0/.zshenv" "$0"/core/*.zsh "$0"/config/*.zsh; do [ -f "$f" ] && zcompile "$f"; done' "$DOTFILES_DIR/zsh"
else
  echo "  ⚠ zsh not found. Install it with: mise bootstrap packages apply"
fi

echo "Cache generation complete."
