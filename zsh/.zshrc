#--------------------------------------------------------------#
##          ZSH Runtime Configuration                        ##
#--------------------------------------------------------------#

# Guard against double-loading (use local variable, not exported)
[[ -n "$_DOTFILES_LOADED" ]] && return 0
typeset -g _DOTFILES_LOADED=1

DOTFILES_DIR="$HOME/.dotfiles"

#--------------------------------------------------------------#
##          Load Core Configuration (Immediate)             ##
#--------------------------------------------------------------#

# These are fast and essential
for file in $DOTFILES_DIR/zsh/core/*.zsh; do
  [[ -f "$file" ]] && source "$file"
done

#--------------------------------------------------------------#
##          Load User Configuration (Immediate)             ##
#--------------------------------------------------------------#

# These are quick and daily-use
for file in $DOTFILES_DIR/zsh/config/*.zsh; do
  [[ -f "$file" ]] && source "$file"
done

#--------------------------------------------------------------#
##          Load Mise (Immediate - Lightweight)             ##
#--------------------------------------------------------------#

# Mise is lightweight and needed for environment detection
[[ -f $DOTFILES_DIR/zsh/plugins/mise.zsh ]] && source $DOTFILES_DIR/zsh/plugins/mise.zsh

#--------------------------------------------------------------#
##          Load Pre-generated Integrations                 ##
#--------------------------------------------------------------#

# Starship prompt (pre-generated direct load)
[[ -f $DOTFILES_DIR/zsh/plugins/prompt.zsh ]] && source $DOTFILES_DIR/zsh/plugins/prompt.zsh

# Zoxide navigation (pre-generated direct load)
[[ -f $DOTFILES_DIR/zsh/plugins/navigation.zsh ]] && source $DOTFILES_DIR/zsh/plugins/navigation.zsh

# FZF history search (pre-generated direct load)
[[ -f $DOTFILES_DIR/zsh/plugins/fzf.zsh ]] && source $DOTFILES_DIR/zsh/plugins/fzf.zsh

# Worktrunk git worktree management (pre-cached shell integration)
[[ -f $DOTFILES_DIR/zsh/plugins/worktrunk.zsh ]] && source $DOTFILES_DIR/zsh/plugins/worktrunk.zsh

#--------------------------------------------------------------#
##          Local Configuration (User Overrides)            ##
#--------------------------------------------------------------#

# Allow user to add custom configuration
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Allow per-host configuration
[[ -f $DOTFILES_DIR/zsh/.zshrc.local ]] && source $DOTFILES_DIR/zsh/.zshrc.local
