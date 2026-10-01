#--------------------------------------------------------------#
##          Worktrunk - Git Worktree Management              ##
#--------------------------------------------------------------#

# Shell integration (function wrapper + completions)
if [[ -f ~/.dotfiles/zsh/cache/worktrunk-init.zsh ]]; then
  source ~/.dotfiles/zsh/cache/worktrunk-init.zsh
else
  echo "Warning: Worktrunk cache not found. Run ~/.dotfiles/bootstrap.sh"
fi

alias wtl='wt list'
alias wtr='wt remove'
alias wts='wt switch'

_wt_complete_subcommand() {
  local subcommand="$1"
  local original_current=$CURRENT
  local -a original_words rewritten_words

  original_words=("${words[@]}")
  rewritten_words=(wt "$subcommand")

  if (( ${#original_words[@]} > 1 )); then
    rewritten_words+=("${(@)original_words[2,-1]}")
  fi

  words=("${rewritten_words[@]}")
  CURRENT=$((original_current + 1))
  _wt_lazy_complete

  words=("${original_words[@]}")
  CURRENT=$original_current
}

_wtl_complete() {
  _wt_complete_subcommand list
}

_wtr_complete() {
  _wt_complete_subcommand remove
}

_wts_complete() {
  _wt_complete_subcommand switch
}

if (( $+functions[compdef] )); then
  compdef _wtl_complete wtl
  compdef _wtr_complete wtr
  compdef _wts_complete wts
fi
