# Install neovim extensions
log -i "Installing neovim extensions"
nvim --headless '+Lazy! sync' +qa

# Install common tools
log -i "Installing rust binaries that I use:"
pkgs=(ripgrep eza bat alacritty tealdeer convfmt matugen)
for i in ${pkgs[@]} rustup cargo; do log -i $i; done
log -n "Note: please have gcc, make and cmake installed"
# rustup and cargo
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -yq
. "$HOME/.cargo/env"
cargo install --locked ${pkgs[@]}
unset pkgs
# Setup tealdeer
tldr --update

log -i "Installing fzf:"
curl -Lo "$HOME/.local/fzf-install" "https://raw.githubusercontent.com/junegunn/fzf/master/install"
bash "$HOME/.local/fzf-install" --all --xdg
rm -f "$HOME/.local/fzf-install"
