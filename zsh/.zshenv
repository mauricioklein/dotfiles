# Guard against duplicate host rc source lines.
[[ -n "$_DOTFILES_ZSHENV_LOADED" ]] && return 0
typeset -g _DOTFILES_ZSHENV_LOADED=1

#--------------------------------------------------------------#
##          Common                                            ##
#--------------------------------------------------------------#

export LC_ALL="${LC_ALL:-en_US.UTF-8}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/.ripgreprc"

# Normalize inherited non-UTF-8 locales so terminal encoding stays consistent.
if [[ "$LANG" == *[Uu][Tt][Ff]-8 || "$LANG" == *[Uu][Tt][Ff]8 ]]; then
  export LANG
else
  export LANG="en_US.UTF-8"
fi

#--------------------------------------------------------------#
##          PATH                                              ##
#--------------------------------------------------------------#
path=(
  /usr/local/bin(N-/)
  $HOME/.bin(N-/)
  $HOME/.local/bin(N-/)
  $HOME/go/bin(N-/)
  $path
)

# Homebrew
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  path=(/opt/homebrew/bin(N-/) $path)
else
  # Linux
  path=(/home/linuxbrew/.linuxbrew/bin(N-/) $path)
fi
export PATH
export HOMEBREW_AUTO_UPDATE_SECS=604800 # Homebrew: update once a week (604800 seconds)
export HOMEBREW_NO_ENV_HINTS=1          # Homebrew: disable env hints

setopt no_global_rcs

typeset -fuz zkbd
typeset -U path PATH manpath sudo_path
typeset -xT SUDO_PATH sudo_path

#--------------------------------------------------------------#
##          Shell                                             ##
#--------------------------------------------------------------#

export PS4='+%N:%i> '

if SHELL=$(builtin command -v zsh); then
	export SHELL
else
	unset SHELL
fi

if builtin command -v vim > /dev/null 2>&1; then
	export EDITOR=${EDITOR:-vim}
else
	export EDITOR=${EDITOR:-nano}
fi
export SYSTEMD_EDITOR=$EDITOR
export PAGER=less
export LESS='--no-init -R --shift 4 --LONG-PROMPT --quit-if-one-screen'

export LS_COLORS='no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:'

#--------------------------------------------------------------#
##          Misc                                              ##
#--------------------------------------------------------------#

export INPUTRC="$XDG_CONFIG_HOME/readline/inputrc"

export NEWT_COLORS='
root=white,black
border=black,lightgray
window=lightgray,lightgray
shadow=black,gray
title=black,lightgray
button=black,cyan
actbutton=white,cyan
compactbutton=black,lightgray
checkbox=black,lightgray
actcheckbox=lightgray,cyan
entry=black,lightgray
disentry=gray,lightgray
label=black,lightgray
listbox=black,lightgray
actlistbox=black,cyan
sellistbox=lightgray,black
actsellistbox=lightgray,black
textbox=black,lightgray
acttextbox=black,cyan
emptyscale=,gray
fullscale=,cyan
helpline=white,black
roottext=lightgrey,black'

#--------------------------------------------------------------#
##          Local overrides                                  ##
#--------------------------------------------------------------#

# Allow machine-specific environment customizations
[ -f "$HOME/.zshenv.local" ] && . "$HOME/.zshenv.local"

true
