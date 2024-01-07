[[ $- != *i* ]] && return

shopt -s histappend checkwinsize expand_aliases

for script in ~/.bash/*.sh; do
	[[ -f $script ]] && source $script
done

xhost +local:root >/dev/null 2>&1

# fzf -- fuzy search
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# nvm -- node version manager
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# bash completion
[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion

# pyenv
eval "$(pyenv init -)"

# User configuration
export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_IN.UTF-8

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"
