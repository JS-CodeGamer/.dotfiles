#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

## [Completion]
## Completion scripts setup. Remove the following line to uninstall
[ -f /home/jagteshver/.config/.dart-cli-completion/bash-config.bash ] && . /home/jagteshver/.config/.dart-cli-completion/bash-config.bash || true
## [/Completion]

. "$HOME/.cargo/env"
