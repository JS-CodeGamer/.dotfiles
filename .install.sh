#!/bin/bash

## Vars
POSITIONAL_ARGS=()
GIT_REMOTE="git@github.com:JS-CodeGamer/.dotfiles.git"
GIT_DIR="$HOME/.cfg"
BACKUP_DIR="$HOME/bak"
PERSONAL=false

## Functions

function backup {
  mkdir -p $(dirname "$BACKUP_DIR/$1")
  mv -vf "$1" "$BACKUP_DIR/$1"
}

function config { git --git-dir=$GIT_DIR --work-tree=$HOME $@; }

function log {
  case $1 in
  -i)
    shift
    echo "[INFO]: " $@
    ;;
  -e)
    shift
    echo "[ERROR]: " $@
    ;;
  *)
    shift
    echo "[MISC]: " $@
    ;;
  esac
}

while [[ $# -gt 0 ]]; do
  case $1 in
  -r | --git-remote)
    GIT_REMOTE="$2"
    shift # past argument
    shift # past value
    ;;
  -g | --git-dir)
    GIT_DIR="$2"
    shift # past argument
    shift # past value
    ;;
  -b | --backup-dir)
    SEARCHPATH="$2"
    shift # past argument
    shift # past value
    ;;
  -p) # Personal setup, will use ssh for git cloning
    PERSONAL=true
    shift
    ;;
  -* | --*)
    echo "Unknown option $1"
    exit 1
    ;;
  *)
    POSITIONAL_ARGS+=("$1") # save positional arg
    shift                   # past argument
    ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

if command -v apt >/dev/null; then
  log -i "Apt detected"
  log -i "Debian/Ubuntu based distro"
  log -i "trying to install git using apt"
  PKG_MGR_CMD="apt install -y"
elif command -v pacman >/dev/null; then
  log -i "Pacman detected"
  log -i "Arch based distro"
  log -i "trying to install git using pacman"
  PKG_MGR_CMD="pacman -Sy --needed --noconfirm"
# elif command -v yum >/dev/null; then
#   log -i "Yum detected"
#   log -i "RHEL based distro"
#   log -i "trying to install git using yum"
#   PKG_MGR_CMD="yum -y install"
fi

if ! command -v git >/dev/null; then
  if [ -n "$PKG_MGR_CMD" ]; then
    sudo $PKG_MGR_CMD git
  fi
  if [ -z "$PKG_MGR_CMD" ] || [ $? -ne 0 ]; then
    log -e "Git not installed"
    exit 1
  fi
fi

# Clone dotfiles from github
# Use ssh and fallback to http
if [ -d "$GIT_DIR" ]; then backup $GIT_DIR; fi
if ! $PERSONAL; then
  GIT_REMOTE="${GIT_REMOTE/git@github.com:/https://github.com/}"
fi
log -i "Cloning dotfiles from github repo: $GIT_REMOTE"
git clone --bare -q "$GIT_REMOTE" "$GIT_DIR"

log -i "Backing up old stuff to $BACKUP_DIR"
config ls-tree --name-only -r --full-tree HEAD | while read -r file; do
  if [ -f "$file" ]; then
    backup "$file"
  fi
done

log -i "Setting up config"
OLD_DIR="$(pwd)"
cd "$HOME"
config checkout --force HEAD
config config --local status.showUntrackedFiles no
config submodule update --init --recursive --remote --merge
cd "$OLD_DIR"
unset OLD_DIR

# Install neovim extensions
log -i "Installing neovim extensions"
nvim --headless '+Lazy! sync' +qa

# Install common tools
log -i "Installing common tools that I use:"
pkgs=(ripgrep eza bat alacritty tealdeer convfmt)
for i in ${pkgs[@]} rustup cargo; do log -i $i; done
log -n "Note: please have gcc, make and cmake installed"
# rustup and cargo
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -yq
. "$HOME/.cargo/env"
cargo install --locked ${pkgs[@]}
unset pkgs
# Setup tealdeer
tldr --update

log -i "Installing fzf"
curl -Lo "$HOME/.local/fzf-install" "https://raw.githubusercontent.com/junegunn/fzf/master/install"
bash "$HOME/.local/fzf-install" --all --xdg
rm -f "$HOME/.local/fzf-install"
. ~/.bashrc
printf "Done"
