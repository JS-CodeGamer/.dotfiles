[[ -n ${1+x} ]] && use_color=$1 || use_color=false

# Aliases with colors
[[ $use_color == true ]] && alias ls='ls -F --color=always' || alias ls='ls -F'
[[ $use_color == true ]] && alias grep='grep --colour=always'
[[ $use_color == true ]] && alias egrep='egrep --colour=always'
[[ $use_color == true ]] && alias fgrep='fgrep --colour=always'

# Genral Aliases
## ls
alias la='ls -A'
alias ll='ls -al'

## python
alias py='python'
alias pym='python -m'
alias pip='pym pip'

## yay
alias ys='yay -S'
alias yu='yay -Syu'
alias yq='yay -Q'
alias yr='yay -R'

## openvpn3
alias vpnc='openvpn3 session-start --persist-tun --dco true -c'
alias vpnd='openvpn3 session-manage -D -c'
alias vpnr='openvpn3 session-manage --restart -c'
alias vpnl='openvpn3 sessions-list'