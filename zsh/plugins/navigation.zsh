#--------------------------------------------------------------#
##          Zoxide - Pre-generated Direct Load               ##
#--------------------------------------------------------------#

# Source the pre-generated zoxide integration
if [[ -f ~/.dotfiles/zsh/cache/zoxide-init.zsh ]]; then
  source ~/.dotfiles/zsh/cache/zoxide-init.zsh
else
  echo "Warning: Zoxide cache not found. Run ~/.dotfiles/bootstrap.sh"
fi
