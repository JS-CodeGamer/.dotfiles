#!/bin/bash

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

## ls
# Replace ls with exa
alias ls='exa --color=always --group-directories-first --icons' # use exa if available
alias la='ls -A' # all files and dirs
alias ll='ls -al' # long format
alias lt='ls -aT' # tree listing using exa
alias l.='ls -d .*' # show only dotfiles

## grep
alias grep='grep --colour=always'
alias egrep='grep -E'
alias fgrep='fgrep -F'
check rg && alias grep='rg'

## python
alias py='python'
alias pym='python -m'
alias pip='python -m pip'

## pacman, yay & paru
alias ys='pacman -S'
alias yu='pacman -Syu'
alias yq='pacman -Q'
alias yr='pacman -R'
check paru && alias pacman='paru'

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
alias cat='bat --style header,snip,changes,header'
alias bathelp='bat -pl help'

## neovim
alias nv="nvim"
alias v="vim"

# iptables
alias ipt='sudo iptables -nvL --line-numbers'


## Useful aliases
### credit: bashrc from garduda linux
alias grubup="sudo update-grub"
alias fixpacman="sudo rm /var/lib/pacman/db.lck"
alias tarnow='tar -acf '
alias untar='tar -zxvf '
alias wget='wget -c '
alias rmpkg="sudo pacman -Rdd"
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
alias grep='ugrep --color=auto'
alias fgrep='ugrep -F --color=auto'
alias egrep='ugrep -E --color=auto'
alias hw='hwinfo --short'                          # Hardware Info
alias big="expac -H M '%m\t%n' | sort -h | nl"     # Sort installed packages according to size in MB (expac must be installed)
alias gitpkg='pacman -Q | grep -i "\-git" | wc -l' # List amount of -git packages
alias ip='ip -color'

# Get fastest mirrors
alias mirror="sudo reflector -f 30 -l 30 --number 10 --verbose --save /etc/pacman.d/mirrorlist"
alias mirrord="sudo reflector --latest 50 --number 20 --sort delay --save /etc/pacman.d/mirrorlist"
alias mirrors="sudo reflector --latest 50 --number 20 --sort score --save /etc/pacman.d/mirrorlist"
alias mirrora="sudo reflector --latest 50 --number 20 --sort age --save /etc/pacman.d/mirrorlist"

# Help people new to Arch
alias apt='man pacman'
alias apt-get='man pacman'
alias please='sudo'
alias tb='nc termbin.com 9999'
alias helpme='cht.sh --shell'
alias pacdiff='sudo -H DIFFPROG=meld pacdiff'

# Cleanup orphaned packages
alias cleanup='sudo pacman -Rns $(pacman -Qtdq)'

# Get the error messages from journalctl
alias jctl="journalctl -p 3 -xb"

# Recent installed packages
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"
