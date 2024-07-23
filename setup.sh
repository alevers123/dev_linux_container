#!/bin/bash
#
DIR="$(dirname "$(realpath "$0")")"
bash $DIR/zsh-in-docker.sh
mkdir ~/.config && mkdir ~/.tmux 
git clone https://github.com/LazyVim/starter ~/.config/nvim
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

wget https://raw.githubusercontent.com/tony/tmux-config/master/.tmux.conf  -P ~/

echo "# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'erikw/tmux-powerline'
set -g @plugin 'AngryMorrocoy/tmux-neolazygit'
set -g @treemux-tree-nvim-init-file '~/.tmux/plugins/treemux/configs/treemux_init.lua'
set -g @plugin 'kiyoon/treemux'

# Other examples:
# set -g @plugin 'github_username/plugin_name'
# set -g @plugin 'github_username/plugin_name#branch'
# set -g @plugin 'git@github.com:user/plugin'
# set -g @plugin 'git@bitbucket.com:user/plugin'

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'" >> .tmux.conf


tmux start-server && \
tmux new-session -d && \
sleep 1 && \
bash ~/.tmux/plugins/tpm/scripts/install_plugins.sh && \
tmux kill-server
