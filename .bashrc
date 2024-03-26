#!/bin/bash

## note: exports are placed before check for
##  interactivity for use in scripts

# check if a prog exists or not
check() {
	if command -v $1 >/dev/null; then
		return 0
	else
		return 1
	fi
}

#################################################
#################################################
##################             ##################
##################   EXPORTS   ##################
##################             ##################
#################################################
#################################################

## Global defaults
check bat && export PAGER="bat"
check nvim && export EDITOR="nvim" \
	VISUAL="nvim"

## xdg
export XDG_CONFIG_HOME=$HOME/.config

## nvm -- node version manager
export NVM_DIR=$XDG_CONFIG_HOME/nvm

## git
export GIT_DISCOVERY_ACROSS_FILESYSTEM=1

## bat -- cat replacement
export BAT_CONFIG_PATH=$XDG_CONFIG_HOME/bat/bat.conf

## man
export MANROFFOPT="-c"
check bat && export MANPAGER="sh -c 'col -bx | bat -plman'"

## fzf
if check fzf && check rg; then
	export FZF_DEFAULT_COMMAND='rg --files' \
		FZF_DEFAULT_OPTS='-m'
else
	export FZF_DEFAULT_COMMAND="find . -regextype 'posix-extended' -iregex '.*(\.git|cache|node_modules).*' -type d -prune -o -type f -print -o -type l -print"
fi

# bun
if [ -d "$HOME/.bun" ]; then
	export BUN_INSTALL="$HOME/.bun" \
		PATH=$BUN_INSTALL/bin:$PATH
fi

# pyenv
if [ -d "$HOME/.pyenv" ]; then
	export PYENV_ROOT="$HOME/.pyenv"
	check pyenv ||
		export PATH=$PYENV_ROOT/bin:$PATH
	eval -- "$(pyenv init --path)"
	eval -- "$(pyenv init -)"
fi

# cargo bin
if check cargo; then
	export PATH=$PATH:"$HOME/.cargo/bin"
fi

# local environment
export PATH=~/.local/bin/:$PATH
export WALLPAPER_FOLDER=$HOME/backgrounds

## check for shell interactivity
[[ $- != *i* ]] && return

shopt -s histappend checkwinsize expand_aliases

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# dart pub
export PATH="$PATH":"$HOME/.pub-cache/bin"

#################################################
#################################################
##################             ##################
##################   Options   ##################
##################             ##################
#################################################
#################################################

set +o noclobber

#################################################
#################################################
##################             ##################
##################   3rd Party ##################
##################    Scripts  ##################
##################             ##################
#################################################
#################################################

# fzf -- fuzy search
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# bash-completion (aur)
[ -f /usr/share/bash-completion/bash_completion ] &&
	. /usr/share/bash-completion/bash_completion

# nvm -- node version manager
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] &&
	printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# Advanced command-not-found
[ -r /usr/share/doc/find-the-command/ftc.bash ] &&
	. /usr/share/doc/find-the-command/ftc.bash

# Oh-My-Bash
export OSH="$HOME/.oh-my-bash"
OSH_THEME="nwinkler_random_colors"
# "powerbash10k" -- good
# "nwinkler_random_colors" -- good colors
# "edsonarios" -- minimal
ENABLE_CORRECTION="true"
OMB_DEFAULT_ALIASES="check"
OMB_USE_SUDO=true
OMB_PROMPT_SHOW_PYTHON_VENV=true
completions=(django git npm pip pip3 ssh tmux)
aliases=(general chmod docker misc)
plugins=(bashmarks git)
. "$OSH"/oh-my-bash.sh

#################################################
#################################################
##################             ##################
##################   ALIASES   ##################
##################             ##################
#################################################
#################################################

check() {
	if command -v $1 >/dev/null; then
		return 0
	else
		return 1
	fi
}

alias less='less -RF'
alias du='du -had1'
alias df='df -h'     # human-readable sizes
alias free='free -m' # show sizes in MB
alias clear="command clear; seq 1 $(tput cols) | sort -R | sparklines | lolcat"

## ls
check exa &&
	alias ls='exa --color --group-directories-first --icons' # use exa if available
alias la='ls -A'                                          # all files and dirs
alias ll='ls -al'                                         # long format
alias lt='ls -aT'                                         # tree listing using exa
alias l.='ls -d .*'                                       # show only dotfiles

## grep
alias grep='grep --colour'
alias egrep='grep -E'
alias fgrep='fgrep -F'
check rg && alias grep='rg'

## python
alias py='python'
alias pym='python -m'
alias pip='python -m pip'

## pacman, yay
alias ys='pacman -S'
alias yu='pacman -Syu'
alias yq='pacman -Q'
alias yr='pacman -R'
alias rmpkg="sudo pacman -Rdd"
alias fixpacman="sudo rm /var/lib/pacman/db.lck"
alias gitpkg='pacman -Q | grep -i "\-git" | wc -l' # List amount of -git packages
check yay && alias pacman='yay'

## reflector
alias mirror="sudo reflector -f 30 -l 30 -n 10 --verbose --save /etc/pacman.d/mirrorlist"
alias mirrord="sudo reflector -l 50 -n 20 --sort delay --save /etc/pacman.d/mirrorlist"
alias mirrors="sudo reflector -l 50 -n 20 --sort score --save /etc/pacman.d/mirrorlist"
alias mirrora="sudo reflector -l 50 -n 20 --sort age --save /etc/pacman.d/mirrorlist"

## openvpn3
alias vpnc='openvpn3 session-start --persist-tun --dco true -c'
alias vpnd='openvpn3 session-manage -D -c'
alias vpnr='openvpn3 session-manage --restart -c'
alias vpnl='openvpn3 sessions-list'

## git
alias glog='git log --oneline --graph'
alias ga='git add' gcm='git commit' gco='git checkout'
alias gs='git status -sb' gsh='git stash' gus='git stash pop'

## bat
alias cat='bat --style header,snip,changes'
alias bh='bat -pl help' # bathelp

## neovim
alias n="nvim"
alias v="vim"

# iptables
alias ipt='sudo iptables -nvL --line-numbers'

## Useful aliases
### credit: bashrc from garduda linux
alias grubup="sudo update-grub"
alias tarnow='tar -acf'
alias untar='tar -zxvf'
alias wget='wget -c'
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'
alias upd='/usr/bin/garuda-update'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias hw='hwinfo --short'                      # Hardware Info
alias big="expac -H M '%m\t%n' | sort -h | nl" # Sort installed packages according to size in MB (expac must be installed)
alias ip='ip -color'

# Help people new to Arch
alias tb='nc termbin.com 9999'
alias helpme='cht.sh --shell'
alias pacdiff='sudo -H DIFFPROG=meld pacdiff'

# Cleanup orphaned packages
alias cleanup='sudo pacman -Rns $(pacman -Qtdq)'

# Get the error messages from journalctl
alias jctl="journalctl -p 3 -xb"

# Recent installed packages
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"

alias cloudflared="docker run -dv ~/.cloudflared:/etc/cloudflared --network host --rm cloudflare/cloudflared"

unset check

#################################################
#################################################
##################             ##################
##################  FUNCTIONS  ##################
##################             ##################
#################################################
#################################################

## colors - color lister
## usage: colors
colors() (
	printf "Color escapes are %s\n" '\e[${value};...;${value}m'
	printf "Values 30..37 are \e[0#33mforeground colors\e[m\n"
	printf "Values 40..47 are \e[43mbackground colors\e[m\n"
	printf "Value  1 gives a  \e[1mbold-faced look\e[m\n\n"

	# foreground colors
	for fgc in {30..37}; do
		# background colors
		for bgc in {40..47}; do
			fgc=${fgc#37} # white
			bgc=${bgc#40} # black

			vals="${fgc:+$fgc;}${bgc}"
			vals=${vals%%;}

			seq0="${vals:+\e[${vals}m}"
			printf "  %-9s" "${seq0:-(default)}"
			printf " ${seq0}TEXT\e[m"
			printf " \e[${vals:+${vals+$vals;}}1mBOLD\e[m"
		done
		printf "\n\n"
	done
)

## ex - archive extractor
## usage: ex <file>
ex() {
	if [ $# -eq 0 ]; then
		echo "error: no <file> provided for extraction"
		echo "usage: ex <file>"
	fi
	while [ $# -ne 0 ]; do
		if [ ! -f $1 ]; then
			echo "'$1' is not a valid file"
		fi
		case $1 in
		*.tar.bz2) tar xjf $1 ;;
		*.tar.gz) tar xzf $1 ;;
		*.tbz2) tar xjf $1 ;;
		*.tgz) tar xzf $1 ;;
		*.tar) tar xf $1 ;;
		*.bz2) bunzip2 $1 ;;
		*.rar) unrar x $1 ;;
		*.gz) gunzip $1 ;;
		*.zip) unzip $1 ;;
		*.Z) uncompress $1 ;;
		*.7z) 7z x $1 ;;
		*) echo "'$1' cannot be extracted via ex()" ;;
		esac
		shift
	done
}

## help - get help for a command
## usage: help <command>
help() {
	"$@" --help 2>&1 | bat -pl help
}

## config - access dotfiles repo same as git
## usage: config <command>
config() {
	git --git-dir="$HOME/.cfg/" --work-tree="$HOME" $@
}
# $(complete -p git | sed 's/\(.*\)git/\1config/')

## edit my scripts
scriptedit() {
	$EDITOR "$HOME/.local/bin/$1"
}
complete -W "$(ls $HOME/.local/bin)" scriptedit

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# OMP_THEME="uew.omp.json" # $(ls $(brew --prefix oh-my-posh)/themes/ | sort -R | tail -1)
# eval "$(oh-my-posh init bash --config $(brew --prefix oh-my-posh)/themes/$OMP_THEME)"
# echo using oh my posh theme: $OMP_THEME | lolcat
#
# function ompset() {
# 	oh-my-posh init bash --config $(brew --prefix oh-my-posh)/themes/$@
# }

neofetch | lolcat
