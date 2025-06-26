#!/bin/bash

## check for shell interactivity
[[ $- != *i* ]] && return

export HISTFILESIZE=100000 # 100k

# go bin
if [ -d "$HOME/go/bin" ]; then
  export PATH=$PATH:"$HOME/go/bin"
fi

# check if a prog exists or not
check() {
  if command -v "$1" >/dev/null; then
    return 0
  else
    return 1
  fi
}

export SELECTOR="fuzzel -d"
export PAGER=less
export MANPAGER=less

## bat -- cat replacement
check bat && {
  # export MANPAGER="sh -c 'col -bx | bat -plman'"
  # use less for man pages cuz it gives better results
  #   with colored-man-pages oh my bash plugin
  export BAT_CONFIG_PATH=$XDG_CONFIG_HOME/bat/bat.conf
  alias cat='bat --style header,snip,changes'
  alias bh='bat -pl help' # bathelp
  if check fzf; then
    export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :50 {}'"
  fi
}

## neovim
alias n="nvim"
alias v="vim"

## nvm -- node version manager
export NVM_DIR=$XDG_CONFIG_HOME/nvm
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

## fzf -- fuzy search
if check fzf; then
  # [ -f "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.bash ] &&
  #   source "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.bash ||
  eval "$(fzf --bash)"

  export FZF_DEFAULT_OPTS='-m'
  if check fd; then
    export FZF_DEFAULT_COMMAND='fd --hidden --strip-cwd-prefix --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type=d --hidden --strip-cwd-prefix --exclude .git'
    _fzf_compgen_path() {
      fd --hidden --exclude .git . "$1"
    }
    _fzf_compgen_dir() {
      fd --dir --hidden --exclude .git . "$1"
    }
  elif check rg; then
    export FZF_DEFAULT_COMMAND='rg --files --hidden'
  else
    export FZF_DEFAULT_COMMAND="find . -regextype 'posix-extended' -iregex '\.(git|node_modules).*' -type d -prune -o -print"
  fi
fi

# pyenv
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init - bash)"
fi

shopt -s histappend checkwinsize expand_aliases
set +o noclobber

if check app2unit-open; then
  alias xdg-open=app2unit-open
fi

# Use bash-completion, if available
[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] &&
  . /usr/share/bash-completion/bash_completion

# Advanced command-not-found
[ -r /usr/share/doc/find-the-command/ftc.bash ] &&
  . /usr/share/doc/find-the-command/ftc.bash

alias less='less -RF'
alias du='du -had1'
alias df='df -h'     # human-readable sizes
alias free='free -m' # show sizes in MB
alias clear='command clear; seq 1 $(tput cols) | sort -R | sparklines | lolcat'
alias c='clear'

## ls
check eza &&
  alias ls='eza --color --group-directories-first --icons' # use exa if available
alias la='ls -A'                                           # all files and dirs
alias ll='ls -al'                                          # long format
alias lt='ls -aT'                                          # tree listing using exa
alias l.='ls -d .*'                                        # show only dotfiles
alias l='la'

## grep
alias grep='grep --colour'
alias fgrep='grep -F'
alias egrep='grep -E'

## python
alias py='python'
alias pym='python -m'
alias pip='python -m pip'

## pacman, yay
check yay && alias pacman='yay'
alias ys='pacman -S'
alias yu='pacman -Syu'
alias yq='pacman -Q'
alias yr='pacman -R'
alias yf='pacman -F'
alias rmpkg="sudo pacman -Rdd"
alias fixpacman="sudo rm /var/lib/pacman/db.lck"

## reflector
alias mirror="sudo reflector -f 30 -l 30 -n 10 --verbose --save /etc/pacman.d/mirrorlist"
alias mirrord="sudo reflector -l 50 -n 20 --sort delay --save /etc/pacman.d/mirrorlist"
alias mirrors="sudo reflector -l 50 -n 20 --sort score --save /etc/pacman.d/mirrorlist"
alias mirrora="sudo reflector -l 50 -n 20 --sort age --save /etc/pacman.d/mirrorlist"

## git
source /usr/share/bash-completion/completions/git
alias g='git'
__git_complete g git

# config
alias config="git --git-dir='$HOME/.cfg/' --work-tree='$HOME'"
__git_complete config git

# iptables
alias ipt='sudo iptables -nvL --line-numbers'

## Useful aliases
### credit: bashrc from garduda linux
alias wget='wget -c'
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'
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
alias tb='nc termbin.com 9999'

# Cleanup orphaned packages
alias cleanup='sudo pacman -Rns $(pacman -Qtdq)'

# Get the error messages from journalctl
alias jctl="journalctl -p 3 -xb"

# Recent installed packages
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"

# xargs check for alias
alias xargs='xargs '

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

      ansi_code="${fgc};${bgc}"
      ansi_code=${ansi_code%%;}
      ansi_code=${ansi_code##;}

      if [ -n "$ansi_code" ]; then
        seq0="\e[${ansi_code}m"
      fi
      printf "  %-9s" "${seq0:-'(default)'}"
      printf " %sTEXT\e[m" "${seq0}"
      printf " \e[%s;1mBOLD\e[m" "${ansi_code}"
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
    if [ ! -f "$1" ]; then
      echo "'$1' is not a valid file"
    fi
    case $1 in
    *.tar.bz2) tar xjf "$1" ;;
    *.tar.gz) tar xzf "$1" ;;
    *.tbz2) tar xjf "$1" ;;
    *.tgz) tar xzf "$1" ;;
    *.tar) tar xf "$1" ;;
    *.bz2) bunzip2 "$1" ;;
    *.rar) unrar x "$1" ;;
    *.gz) gunzip "$1" ;;
    *.zip) unzip "$1" ;;
    *.Z) uncompress "$1" ;;
    *.7z) 7z x "$1" ;;
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

complete -A builtin -A alias -A function -c help

## edit my scripts
if [ -z "$(env | grep SCRIPT_PREF)" ]; then
  export SCRIPT_PREF=${SCRIPT_PREF:-$HOME/.local/bin}
fi
scriptedit() {
  local fname fnames
  if [ $# -lt 1 ]; then
    printf %s "Usage: scriptedit NAME[+NAME]"
  fi
  for fname in "$@"; do
    fname=${fname:+$SCRIPT_PREF/$fname}
    touch "$fname"
    chmod 744 "$fname"
    fnames="${fnames:+$fnames }$fname"
  done
  $EDITOR "$fnames"
}
_scriptedit() {
  local IFS=$'\n'
  local LASTCHAR=' '

  COMPREPLY=($(compgen -o filenames -f \
    -- "$SCRIPT_PREF/${COMP_WORDS[COMP_CWORD]}"))

  if [ ${#COMPREPLY[@]} = 1 ]; then
    [ -d "$COMPREPLY" ] && LASTCHAR=/
    COMPREPLY=$(printf %q%s "${COMPREPLY#"$SCRIPT_PREF"/}" "$LASTCHAR")
  else
    for ((i = 0; i < ${#COMPREPLY[@]}; i++)); do
      [ -d "${COMPREPLY[$i]}" ] && COMPREPLY[i]=${COMPREPLY[$i]}/
      COMPREPLY[i]=${COMPREPLY[$i]#$SCRIPT_PREF/}
    done
  fi

  return 0
}
complete -o nospace -F _scriptedit scriptedit

torrentsearch() {
  if ! rg -i "$1.*1080" /media/data/qxr_20220613/; then
    rg -i "$1" /media/data/qxr_20220613/
  fi
}

temphist() {
  set -x
  if [ "$HISTFILE" = ~/.bash_history ]; then
    HISTFILE=$(mktemp)
    export HISTFILE
    trap temphist EXIT
  else
    rm "$HISTFILE"
    export HISTFILE=~/.bash_history
    trap - EXIT
  fi
  set +x
}

if command -v ascii-image-converter >/dev/null; then
  ascii-image-converter "$HOME/images/Formal.jpg" -gnd 50,25
fi

if command -v figlet >/dev/null; then
  if command -v lolcat >/dev/null; then
    # figlet Jagteshver\'s Shell | lolcat
    figlet JShell | lolcat
  fi
fi

alias psudo='sudo env PATH="$PATH"'

export JAVA_HOME=/usr/lib/jvm/java-8-openjdk
export PATH=$PATH:$JAVA_HOME/bin

# PROMPT
# Colors
RED='\[\033[0;31m\]'
GREEN='\[\033[0;32m\]'
YELLOW='\[\033[0;33m\]'
BLUE='\[\033[0;34m\]'
WHITE='\[\033[1;37m\]'
GRAY='\[\033[0;37m\]'
BOLD='\[\033[1m\]'
RESET='\[\033[0m\]'

# Git branch + dirty state
parse_git_branch() {
  git rev-parse --is-inside-work-tree &>/dev/null || return
  local branch
  branch=$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --exact-match 2>/dev/null)
  local status
  status=$(git status --porcelain 2>/dev/null)
  if [[ -n $status ]]; then
    echo " (${YELLOW}${branch}${RED}✗${RESET})"
  else
    echo " (${GREEN}${branch}${RESET})"
  fi
}

# Python venv or Conda env
show_venv() {
  if [[ -n "$VIRTUAL_ENV" ]]; then
    echo "(${VIRTUAL_ENV##*/}) "
  elif [[ -n "$CONDA_DEFAULT_ENV" ]]; then
    echo "(${CONDA_DEFAULT_ENV}) "
  fi
}

# Set PS1 prompt
set_prompt() {
  local EXIT="$?"
  local STATUS_COLOR
  [[ $EXIT -eq 0 ]] && STATUS_COLOR=$GREEN || STATUS_COLOR=$RED

  PROMPT_DIRTRIM=2
  PS1="\n${WHITE}\t $(show_venv)${BOLD}\u@\h${RESET}:${BLUE}\w${RESET}$(parse_git_branch)\n${STATUS_COLOR}→${RESET} "
}

PROMPT_COMMAND=set_prompt
