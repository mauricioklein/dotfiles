#!/usr/bin/env bash
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"
HOME_DOTFILES="$HOME/.dotfiles"
MISE_CONFIG="$HOME/.config/mise/config.toml"
failures=0
warnings=0

pass() {
  printf '  ✓ %s\n' "$1"
}

fail() {
  printf '  ✗ %s\n' "$1" >&2
  failures=$((failures + 1))
}

warn() {
  printf '  ⚠ %s\n' "$1"
  warnings=$((warnings + 1))
}

resolve_path() {
  local path="$1" target dir

  while [[ -L "$path" ]]; do
    target="$(readlink "$path")" || return 1
    if [[ "$target" != /* ]]; then
      target="$(dirname "$path")/$target"
    fi
    path="$target"
  done

  if [[ -d "$path" ]]; then
    (cd -P "$path" && pwd)
  else
    dir="$(cd -P "$(dirname "$path")" 2>/dev/null && pwd)" || return 1
    printf '%s/%s\n' "$dir" "$(basename "$path")"
  fi
}

check_link() {
  local label="$1" path="$2" expected="$3" actual

  if [[ ! -L "$path" ]]; then
    fail "$label is not a symlink: $path"
    return
  fi

  actual="$(resolve_path "$path" 2>/dev/null)" || {
    fail "$label cannot be resolved: $path"
    return
  }
  if [[ "$actual" != "$expected" ]]; then
    fail "$label resolves to $actual (expected $expected)"
  else
    pass "$label resolves to $expected"
  fi
}

printf '%s\n' "Dotfiles health check: $ROOT"
printf '%s\n' 'Links'
check_link '~/.dotfiles' "$HOME_DOTFILES" "$ROOT"
check_link 'Mise config' "$MISE_CONFIG" "$ROOT/mise.toml"

printf '%s\n' 'Mise state'
if command -v mise >/dev/null 2>&1; then
  # Let mise validate its complete configured inventory; do not duplicate it here.
  if mise bootstrap status --missing; then
    pass 'Mise bootstrap state is applied'
  else
    fail 'Mise bootstrap state is missing or out of sync (run mise run repair)'
  fi
else
  fail 'mise is not on PATH'
fi

printf '%s\n' 'Available updates'
if command -v mise >/dev/null 2>&1; then
  outdated="$(mise outdated --bump 2>&1)"
  outdated_status=$?
  if [[ "$outdated_status" -ne 0 ]]; then
    warn 'could not query available updates'
  elif [[ -z "$outdated" || "$outdated" == 'mise All tools are up to date' ]]; then
    pass 'no updates reported'
  else
    warn 'available updates:'
    printf '%s\n' "$outdated" | sed 's/^/    /'
  fi
fi

printf '%s\n' 'Generated files'
generated_files="$({
  for plugin in "$ROOT"/zsh/plugins/*.zsh; do
    [[ -f "$plugin" ]] || continue
    sed -n 's@.*zsh/cache/\([[:alnum:]_-]*-init\.zsh\).*@\1@p' "$plugin"
  done
} | sort -u)"
while IFS= read -r generated_file; do
  [[ -n "$generated_file" ]] || continue
  file="$ROOT/zsh/cache/$generated_file"
  if [[ -s "$file" ]]; then
    pass "generated file exists: ${file#$ROOT/}"
  else
    fail "missing generated file: ${file#$ROOT/} (run ./scripts/generate-caches.sh)"
  fi
done <<EOF
$generated_files
EOF

if [[ -s "$ROOT/zsh/cache/.zcompdump" ]]; then
  pass 'completion cache exists'
else
  warn 'completion cache is missing; the next interactive shell will rebuild it'
fi

compiled_files=(
  "$ROOT/zsh/.zshenv"
  "$ROOT/zsh/.zshrc"
  "$ROOT"/zsh/core/*.zsh
  "$ROOT"/zsh/config/*.zsh
)
for file in "${compiled_files[@]}"; do
  [[ -f "$file" ]] || continue
  zwc="$file.zwc"
  if [[ ! -f "$zwc" ]]; then
    fail "missing bytecode: ${zwc#$ROOT/} (run ./scripts/generate-caches.sh)"
  elif [[ "$file" -nt "$zwc" ]]; then
    warn "bytecode is older than source: ${zwc#$ROOT/}"
  fi
done

printf '%s\n' 'Syntax'
if command -v bash >/dev/null 2>&1; then
  for file in "$ROOT/bootstrap.sh" "$ROOT"/scripts/*.sh; do
    [[ -f "$file" ]] || continue
    if bash -n "$file"; then
      pass "bash syntax: ${file#$ROOT/}"
    else
      fail "bash syntax: ${file#$ROOT/}"
    fi
  done
else
  fail 'bash is not on PATH'
fi

if command -v zsh >/dev/null 2>&1; then
  for file in \
    "$ROOT/zsh/.zshenv" \
    "$ROOT/zsh/.zshrc" \
    "$ROOT"/zsh/core/*.zsh \
    "$ROOT"/zsh/config/*.zsh \
    "$ROOT"/zsh/plugins/*.zsh; do
    [[ -f "$file" ]] || continue
    if zsh -n "$file"; then
      pass "zsh syntax: ${file#$ROOT/}"
    else
      fail "zsh syntax: ${file#$ROOT/}"
    fi
  done
else
  fail 'zsh is not on PATH'
fi

printf '%s\n' 'Environment'
if command -v mise >/dev/null 2>&1 && mise ls --current ripgrep --json >/dev/null 2>&1; then
  expected_rg="${XDG_CONFIG_HOME:-$HOME/.config}/ripgrep/.ripgreprc"
  actual_rg="${RIPGREP_CONFIG_PATH:-}"
  if [[ "$actual_rg" != "$expected_rg" ]] && command -v zsh >/dev/null 2>&1; then
    actual_rg="$(zsh -c 'printf "%s" "${RIPGREP_CONFIG_PATH:-}"' 2>/dev/null)"
  fi
  if [[ "$actual_rg" == "$expected_rg" && -f "$expected_rg" ]]; then
    pass "RIPGREP_CONFIG_PATH points to $expected_rg"
  elif [[ "$actual_rg" != "$expected_rg" ]]; then
    fail "RIPGREP_CONFIG_PATH is '${actual_rg:-unset}' (expected $expected_rg)"
  else
    fail "managed ripgrep config is missing: $expected_rg"
  fi
else
  pass 'ripgrep is not configured; environment check skipped'
fi

printf '%s\n' 'Host rc source statements'
check_rc_sources() {
  local rc="$1" name="$2" needle absolute lines rc_status

  if [[ ! -f "$rc" ]]; then
    fail "$name is missing: $rc"
    return
  fi

  needle="\$HOME/.dotfiles/zsh/.$name"
  absolute="$HOME/.dotfiles/zsh/.$name"
  lines="$(awk -v needle="$needle" -v absolute="$absolute" '
    /^[[:space:]]*#/ { next }
    (index($0, needle) || index($0, absolute)) && $0 ~ /(^|[;&[:space:]])(\.|source)[[:space:]]+/ {
      printf "%s ", NR
      count++
    }
    END {
      if (count > 1) exit 2
      if (count == 0) exit 1
    }
  ' "$rc")"
  rc_status=$?

  case "$rc_status" in
    0) pass "$name has one active repo source statement (line $lines)" ;;
    1) fail "$name has no active repo source statement" ;;
    *) fail "$name has duplicate active repo source statements (lines $lines)" ;;
  esac
}
check_rc_sources "$HOME/.zshenv" zshenv
check_rc_sources "$HOME/.zshrc" zshrc

printf '%s\n' 'Repository status'
if git_status="$(git -C "$ROOT" status --short --untracked-files=all 2>&1)"; then
  if [[ -n "$git_status" ]]; then
    warn 'repository has changes:'
    printf '%s\n' "$git_status" | sed 's/^/    /'
  else
    pass 'repository is clean'
  fi
else
  fail 'unable to read repository status'
fi

agent_path_index=0
mise_path_index=0
path_index=0
IFS=: read -r -a path_entries <<< "${PATH:-}"
for path_entry in "${path_entries[@]}"; do
  ((path_index += 1))
  [[ "$path_entry" == "$HOME/.pi/agent/bin" ]] && agent_path_index=$path_index
  if [[ "$path_entry" == "$HOME/.local/share/mise/installs/"* || "$path_entry" == "$HOME/.local/share/mise/shims" ]]; then
    ((mise_path_index == 0)) && mise_path_index=$path_index
  fi
done
if (( agent_path_index > 0 && mise_path_index > 0 && agent_path_index < mise_path_index )); then
  warn 'agent harness PATH precedes mise-managed tools; verify command paths with type -a'
fi

printf '\n%s\n' "Result: $failures failure(s), $warnings warning(s)"
(( failures == 0 ))
