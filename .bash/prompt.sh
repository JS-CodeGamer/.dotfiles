#!/bin/bash

# dircolors --print-database uses its own built-in database
## instead of using /etc/DIR_COLORS.

# Try to use the external file first to take advantage of
## user addons.

# Use internal bash globbing instead of external grep binary.
safe_term=${TERM//[^[:alnum:]]/?} # sanitize TERM

match_lhs=""
[ -f ~/.dir_colors ] && match_lhs="$match_lhs$(<~/.dir_colors)"
[ -f /etc/DIR_COLORS ] && match_lhs="$match_lhs$(</etc/DIR_COLORS)"
[ -z "$match_lhs" ] &&
  command -v dircolors >/dev/null &&
  match_lhs=$(dircolors --print-database)
[[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] &&
  use_color=true

if $use_color; then
  # Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
  if command -v dircolors >/dev/null; then
    if [ -f ~/.dir_colors ]; then
      eval $(dircolors -b ~/.dir_colors)
    elif [ -f /etc/DIR_COLORS ]; then
      eval $(dircolors -b /etc/DIR_COLORS)
    fi
  fi

  if [ ${EUID} = 0 ]; then
    PS1='\[\033[01;31m\][\h\[\033[01;36m\] \W\[\033[01;31m\]]\n--->\[\033[00m\] '
  else
    PS1='\[\033[01;35m\][\u@\h\[\033[01;33m\] \W\[\033[01;35m\]]\n--->\[\033[00m\] '
  fi

else
  if [ ${EUID} = 0 ]; then
    # show root@ when we don't have colors
    PS1='\u@\h \W ~> '
  else
    PS1='\u@\h \w ~> '
  fi
fi

# Load starship prompt if starship is installed
if  [ -x /usr/bin/starship ]; then
    __main() {
        local major="${BASH_VERSINFO[0]}"
        local minor="${BASH_VERSINFO[1]}"

        if ((major > 4)) || { ((major == 4)) && ((minor >= 1)); }; then
            source <("/usr/bin/starship" init bash --print-full-init)
        else
            source /dev/stdin <<<"$("/usr/bin/starship" init bash --print-full-init)"
        fi
    }
    __main
    unset -f __main
fi

