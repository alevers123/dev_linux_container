#!/bin/bash
#
DIR="$(dirname "$(realpath "$0")")"
sudo wget https://raw.githubusercontent.com/deluan/zsh-in-docker/master/zsh-in-docker.sh -P $DIR
bash $DIR/zsh-in-docker.sh -x
mkdir ~/.config && mkdir ~/.tmux
git clone https://github.com/LazyVim/starter ~/.config/nvim
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

cp /opt/scripts/tmux.conf /home/$1/.tmux.conf
cp /opt/scripts/tmux.lua /home/$1/.config/nvim/lua/plugins
cp /opt/scripts/vim_tpipeline.lua /home/$1/.config/nvim/lua/plugins
cp /opt/scripts/lsps_formater.lua /home/$1/.config/nvim/lua/plugins
cp /opt/scripts/zshrc /home/$1/.zshrc

tmux start-server &&
  tmux new-session -d &&
  sleep 1 &&
  bash ~/.tmux/plugins/tpm/scripts/install_plugins.sh &&
  tmux kill-server

bash ~/.tmux/plugins/tmux-powerline/generate_config.sh
cp /opt/scripts/config.sh /home/$1/.config/tmux-powerline/config.sh
mkdir -p ~/.config/tmux-powerline/themes
cp /opt/scripts/my-theme.sh /home/$1/.config/tmux-powerline/themes
cp /opt/scripts/display_times.sh /home/$1/.tmux/plugins/tmux-powerline/segments
cp /opt/scripts/hostname.sh /home/$1/.tmux/plugins/tmux-powerline/segments
cp /opt/scripts/keymaps.lua /home/$1/.config/nvim/lua/config
cp /opt/scripts/options.lua /home/$1/.config/nvim/lua/config

LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
sudo curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
sudo tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin

LAZYDOCKER_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazydocker/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
sudo curl -Lo lazydocker.tar.gz "https://github.com/jesseduffield/lazydocker/releases/latest/download/lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz"
sudo tar xf lazydocker.tar.gz lazydocker
sudo install lazydocker /usr/local/bin

REQUIRED="0.11.0"

# Get installed version (strip leading 'v')
INSTALLED=$(nvim --version 2>/dev/null | head -n1 | awk '{print $2}' | sed 's/^v//')

# If Neovim is not installed, treat version as 0
if [ -z "$INSTALLED" ]; then
  INSTALLED="0"
fi

# Compare versions using dpkg
if dpkg --compare-versions "$INSTALLED" lt "$REQUIRED"; then
  echo "Neovim version $INSTALLED is older than $REQUIRED — upgrading…"

  sudo add-apt-repository -y ppa:neovim-ppa/unstable
  sudo apt update
  sudo apt install -y neovim
else
  echo "Neovim version $INSTALLED meets requirement ($REQUIRED). No upgrade needed."
fi

#!/usr/bin/env bash
set -euo pipefail

# Version and URL
ASM_LSP_VERSION="v0.10.1"
ASM_LSP_URL="https://github.com/bergercookie/asm-lsp/releases/download/${ASM_LSP_VERSION}/asm-lsp-x86_64-unknown-linux-gnu.tar.gz"

# Mason bin directory
MASON_BIN="/home/$1/.local/share/nvim/mason/bin"

echo "Installing asm-lsp into ${MASON_BIN}"

# Create directory if missing
mkdir -p "${MASON_BIN}"

# Download and extract
curl -L "${ASM_LSP_URL}" -o /tmp/asm-lsp.tar.gz
tar -xzf /tmp/asm-lsp.tar.gz -C /tmp

# Move binary into Mason bin
mv /tmp/asm-lsp "${MASON_BIN}/asm-lsp"

# Ensure executable
chmod +x "${MASON_BIN}/asm-lsp"

echo "asm-lsp installed successfully at ${MASON_BIN}/asm-lsp"

# 1. Plugins synchronisieren
nvim --headless "+Lazy! sync" +qa

# 2. Mason Tools separat installieren (mit automatischem Timeout nach 60s)
timeout 60s nvim --headless "+MasonToolsInstallSync" +qa || echo "Mason timeout - checking results..."

# 3. Tree-sitter separat
nvim --headless "+TSUpdateSync" +qa