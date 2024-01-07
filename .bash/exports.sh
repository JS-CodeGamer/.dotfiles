#!/bin/bash

## Global defaults
command -v bat >/dev/null && export PAGER="bat"
command -v nvim >/dev/null && export EDITOR="nvim" VISUAL="nvim"

## nvm -- node version manager
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] &&
  printf %s "${HOME}/.nvm" ||
  printf %s "${XDG_CONFIG_HOME}/nvm")"

## git
export GIT_DISCOVERY_ACROSS_FILESYSTEM=1

## bat -- cat replacement
export BAT_CONFIG_PATH=~/.config/bat/bat.conf
# export BAT_THEME="..."
# export BAT_STYLE="..."
# export BAT_PAGER="..."
## currently defined in bat config

## man
export MANROFFOPT="-c"
command -v bat >/dev/null &&
  export MANPAGER="sh -c 'col -bx | bat -plman'"

## fzf
if command -v fzf >/dev/null; then
  if command -v rg >/dev/null; then
    export FZF_DEFAULT_COMMAND='rg --files' FZF_DEFAULT_OPTS='-m'
  else
    export FZF_DEFAULT_COMMAND="find . -regextype 'posix-extended' -iregex '.*(\.git|cache|node_modules).*' -type d -prune -o -type f -print -o -type l -print"
  fi
fi

# bun
if [ -d ~/.bun ]; then
  export BUN_INSTALL=~/.bun PATH=$BUN_INSTALL/bin:$PATH
fi

# pyenv
if [ -d ~/.pyenv ]; then
  export PYENV_ROOT=~/.pyenv
  command -v pyenv >/dev/null ||
    export PATH=$PYENV_ROOT/bin:$PATH
fi

# local bin
export PATH=$PATH:~/.local/bin

# cargo bin
if command -v cargo >>/dev/null;
then
  export PATH=$PATH:~/.cargo/bin
fi
