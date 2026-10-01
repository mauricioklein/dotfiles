#--------------------------------------------------------------#
##          FZF Configuration (for tab completion)          ##
#--------------------------------------------------------------#

# Don't override default FZF behavior - it works fine
# The issue with single-row display on filtered results is a
# limitation of how FZF renders with constraints, not our config

#--------------------------------------------------------------#
##          Completion Configuration                         ##
#--------------------------------------------------------------#

# Add custom completions to fpath before compinit
fpath=(
  ~/.docker/completions(N-/)
  ~/.local/share/zsh/site-functions(N-/)
  $fpath
)

if (( ! $+functions[compdef] )); then
  autoload -Uz compinit

  # Regenerate compdump once per day.
  # A single compinit/dumpfile keeps command mappings and autoload stubs aligned.
  if [[ -f ~/.dotfiles/zsh/cache/.zcompdump ]] && \
     [[ ! -n ~/.dotfiles/zsh/cache/.zcompdump(#qN.mh+24) ]]; then
    compinit -C -d ~/.dotfiles/zsh/cache/.zcompdump
  else
    compinit -d ~/.dotfiles/zsh/cache/.zcompdump
  fi
fi

# Basic completion styling
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.dotfiles/zsh/cache
