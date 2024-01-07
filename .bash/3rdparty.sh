#!/bin/bash

. "$HOME/.local/bin/bashmarks.sh"

# Advanced command-not-found hook
. /usr/share/doc/find-the-command/ftc.bash

export OSH="$HOME/.oh-my-bash"
OSH_THEME="powerbash10k"
# OMB_THEME_RANDOM_IGNORED=("powerbash10k" "wanelo")
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
# DISABLE_UNTRACKED_FILES_DIRTY="true"
# SCM_GIT_DISABLE_UNTRACKED_DIRTY="true"
# SCM_GIT_IGNORE_UNTRACKED="true"
OMB_DEFAULT_ALIASES="check"
# OSH_CUSTOM=/path/to/new-custom-folder
OMB_USE_SUDO=true
OMB_PROMPT_SHOW_PYTHON_VENV=true
completions=(
  defaults
  dirs
  django
  docker
  docker-compose
  docker-machine
  git
  go
  npm
  nvm
  pip
  pip3
  ssh
  tmux
)
aliases=(
  general
  chmod
  docker
  misc
)
plugins=(
  git
  bashmarks
  golang
  tmux-autoattach
  pyenv
  bash-preexec
  npm
  nvm
  xterm
)
. "$OSH"/oh-my-bash.sh


