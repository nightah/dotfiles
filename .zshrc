# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# theme to use
ZSH_THEME="daveverwer"

# use case-sensitive completion
CASE_SENSITIVE="true"

# disable automatic updates
DISABLE_AUTO_UPDATE="true"

# zsh auto-update in days
export UPDATE_ZSH_DAYS=12

# enable colors for ls
DISABLE_LS_COLORS="false"

# set terminal title
DISABLE_AUTO_TITLE="false"

# enable command auto-correction
ENABLE_CORRECTION="false"

# display red dots whilst waiting for completion
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="dd.mm.yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
plugins=(git)

source $ZSH/oh-my-zsh.sh

# user configuration

export PATH=$HOME/bin:/usr/local/bin:$PATH
# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
 else
   export EDITOR='gvim'
 fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.

# aliases

alias rm='rm -v'
alias mv='mv -v'
alias cp='cp -vr'
alias c='clear'
alias e='exit'
alias grep='grep --color=auto'
alias dir='dir --color=auto'
alias x='startx'
alias bm='bashmount'
alias ncp='ncmpcpp'
alias amix='alsamixer'
alias hc="herbstclient"
alias wee='weechat-curses'
alias paci='sudo pacman -S'
alias pacse='sudo pacman -Ss'
alias pacu='sudo pacman -Syu'
alias pacre='sudo pacman -R'
alias sreboot='systemctl reboot'
alias spoweroff='systemctl poweroff'
alias reset='setxkbmap fi; xmodmap ~/.xmodmap; xset r rate 350 45'
alias xp='xprop | grep "WM_WINDOW_ROLE\|WM_CLASS" && echo "WM_CLASS(STRING) = \"NAME\", \"CLASS\""'s
alias np="mpc current -f '%title% by %artist% from %album%' | xcmenu -ci"
alias yle="yle-dl --sublang fin --destdir ~/Downloads"
alias jwine="LC_ALL=ja_JP.utf8 wine"
