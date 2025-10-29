#!/bin/bash

while getopts ":s:" opt; do
  case $opt in
  s)
    STOWPKG="$OPTARG"
    ;;
  \?)
    echo "Invalid option: -$OPTARG" >&2
    exit 1
    ;;
  esac
done

git clone "$GIT_URL" --depth 1 --single-branch ~/.config/dotfiles

STOW_C="stow -t $HOME -d $HOME/.config/dotfiles --dotfiles"

cat "${STOWPKG:-~/.config/dotfiles/.stowpkgs}" | grep -v '^:' | xargs $STOW_C

cat "${STOWPKG:-~/.config/dotfiles/.stowpkgs}" | grep '^:' | xargs $STOW_C --no-folding
