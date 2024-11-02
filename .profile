export LANG=en_US.UTF-8

export XDG_CONFIG_HOME=$HOME/.config

export PATH=~/.local/bin/:$PATH

export MANROFFOPT="-c"

export EDITOR="nvim" VISUAL="nvim"

if [ "$BASH" ]; then
  [[ -f ~/.bashrc ]] && . ~/.bashrc
fi
