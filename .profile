export LANG=en_US.UTF-8

export XDG_CONFIG_HOME=$HOME/.config
export XDG_BIN_HOME=$HOME/.local/bin
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share
export XDG_STATE_HOME=$HOME/.local/state

export SCRIPT_PREF=$HOME/.local/bin
export PATH=$SCRIPT_PREF:$PATH

export MANROFFOPT="-c"

export EDITOR="nvim" VISUAL="nvim"

if [ "$BASH" ]; then
  [[ -f ~/.bashrc ]] && . ~/.bashrc
fi

# # compositor selection
# if uwsm check may-start && uwsm select; then
#   exec systemd-cat -t uwsm_start uwsm start default
# fi

# directly start hyprland
if uwsm check may-start; then
  exec systemd-cat -t uwsm_start uwsm start hyprland.desktop
fi

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/jagteshver/.lmstudio/bin"
