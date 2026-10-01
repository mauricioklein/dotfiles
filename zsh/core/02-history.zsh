#--------------------------------------------------------------#
##          History Configuration                            ##
#--------------------------------------------------------------#

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=$HISTSIZE
HISTORY_IGNORE="(ls|cd|pwd|zsh|exit|cd ..)"
LISTMAX=1000

setopt append_history
setopt share_history
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Do not add root commands to history
if [ "$UID" = 0 ]; then
  unset HISTFILE
  SAVEHIST=0
fi
