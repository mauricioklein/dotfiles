#!/usr/bin/env bash
set -euo pipefail

remove_redundant_sources() {
  local rc="$1" name="$2" tmp mode

  [[ -f "$rc" && ! -L "$rc" ]] || return 0
  tmp="$(mktemp "${rc}.repair.XXXXXX")"

  if ! awk -v name="$name" -v absolute_source="$HOME/.dotfiles/zsh/.$name" '
    function trim(value) {
      sub(/^[[:space:]]+/, "", value)
      sub(/[[:space:]]+$/, "", value)
      return value
    }
    function flush_pending() {
      if (pending == 1) {
        print pending_ifline
      } else if (pending == 2) {
        print pending_ifline
        print pending_bodyline
      }
      pending = 0
    }
    BEGIN {
      source = "$HOME/.dotfiles/zsh/." name
      absolute = absolute_source
      one_line = "[ -f \"" source "\" ] && source \"" source "\""
      dot_one_line = "[ -f \"" source "\" ] && . \"" source "\""
      ifline = "if [ -f \"" source "\" ]; then"
      dotline = ". \"" source "\""
      source_line = "source \"" source "\""
      absolute_one_line = "[ -f \"" absolute "\" ] && source \"" absolute "\""
      absolute_dot_one_line = "[ -f \"" absolute "\" ] && . \"" absolute "\""
      absolute_ifline = "if [ -f \"" absolute "\" ]; then"
      absolute_dotline = ". \"" absolute "\""
      absolute_source_line = "source \"" absolute "\""
      pending = 0
      managed = 0
    }
    {
      line = $0
      stripped = trim(line)

      if (stripped == "# >>> mise:dotfiles >>> managed by mise — do not edit between markers") {
        if (pending) flush_pending()
        managed = 1
        print
        next
      }
      if (stripped == "# <<< mise:dotfiles <<<") {
        if (pending) flush_pending()
        print
        managed = 0
        next
      }
      if (managed) {
        print
        next
      }

      if (pending == 1) {
        if (stripped == dotline || stripped == source_line ||
            stripped == absolute_dotline || stripped == absolute_source_line) {
          pending = 2
          pending_bodyline = stripped
          next
        }
        flush_pending()
      } else if (pending == 2) {
        if (stripped == "fi") {
          pending = 0
          next
        }
        flush_pending()
      }

      if (stripped == one_line || stripped == dot_one_line ||
          stripped == absolute_one_line || stripped == absolute_dot_one_line) next
      if (stripped == ifline || stripped == absolute_ifline) {
        pending = 1
        pending_ifline = stripped
        next
      }
      print
    }
    END {
      if (pending) flush_pending()
    }
  ' "$rc" > "$tmp"; then
    rm -f "$tmp"
    return 1
  fi

  if cmp -s "$rc" "$tmp"; then
    rm -f "$tmp"
    return 0
  fi

  mode="$(stat -f '%Lp' "$rc" 2>/dev/null || stat -c '%a' "$rc")"
  chmod "$mode" "$tmp"
  mv "$tmp" "$rc"
  printf '  ✓ removed redundant repo source statements from %s\n' "$rc"
}

remove_redundant_sources "$HOME/.zshenv" zshenv
remove_redundant_sources "$HOME/.zshrc" zshrc
