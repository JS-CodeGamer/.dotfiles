# Setup fzf
# ---------
if [[ ! "$PATH" == */home/jagteshver/.local/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/jagteshver/.local/bin"
fi

eval "$(fzf --bash)"
