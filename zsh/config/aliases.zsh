#--------------------------------------------------------------#
##          Core Aliases                                     ##
#--------------------------------------------------------------#

# File operations (safe defaults)
alias cp='cp -irf'
alias mv='mv -i'
alias rm="rm -f"
alias pwd="pwd -P"  # Follow symlinks
alias sudo="sudo "  # enable aliases to be sudo'ed
alias path='echo -e ${PATH//:/\\n}'  # print each PATH entry on separate line

# cat -> bat if available
if builtin command -v bat > /dev/null 2>&1; then
  alias cat='bat --style=plain --paging=never'
fi

# ls -> eza if available
if builtin command -v eza > /dev/null 2>&1; then
  alias ls='eza'
  alias l='eza --long --header'
  alias ll='eza --long --header -a'
else
  alias ls='ls --color=auto'
  alias ll='ls -l --color=auto'
  alias l='ls -l'
fi

# Other tools
alias lg='lazygit'
alias reload='exec zsh'

#--------------------------------------------------------------#
##          Global Aliases                                   ##
#--------------------------------------------------------------#

alias -g L='| $PAGER'
alias -g H='| head'
alias -g T='| tail'

#--------------------------------------------------------------#
##          Suffix Aliases                                   ##
#--------------------------------------------------------------#

alias -s {md,markdown,txt}="$EDITOR"
alias -s py='python'
alias -s rb='ruby'
alias -s {gz,tgz,zip,lzh,bz2,tbz,Z,tar,arj,xz}=extract

# extract function for suffix aliases
extract() {
  case "$1" in
    *.tar.gz|*.tgz) tar xzf "$1" ;;
    *.tar.bz2|*.tbz) tar xjf "$1" ;;
    *.zip) unzip "$1" ;;
    *.gz) gunzip "$1" ;;
    *.tar) tar xf "$1" ;;
    *) echo "Unknown archive type: $1" ;;
  esac
}
