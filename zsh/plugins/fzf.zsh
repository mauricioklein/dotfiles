#--------------------------------------------------------------#
##          FZF - Tab Completion Only                        ##
#--------------------------------------------------------------#

# Note: FZF configuration for tab completion is in config/completion.zsh
# which loads immediately for better performance

# FZF key bindings require a terminal-backed line editor.
if [[ -t 0 && -t 1 && -f ~/.dotfiles/zsh/cache/fzf-init.zsh ]]; then
  source ~/.dotfiles/zsh/cache/fzf-init.zsh

  # FZF's Ctrl+R for history fuzzy search
  bindkey -M emacs '^R' fzf-history-widget
  bindkey -M viins '^R' fzf-history-widget
  bindkey -M vicmd '^R' fzf-history-widget
fi
