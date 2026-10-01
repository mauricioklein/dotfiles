#--------------------------------------------------------------#
##          Starship Prompt - Direct Load                    ##
#--------------------------------------------------------------#

# Source the pre-generated starship integration directly
if [[ -f ~/.dotfiles/zsh/cache/starship-init.zsh ]]; then
  source ~/.dotfiles/zsh/cache/starship-init.zsh
elif command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi
