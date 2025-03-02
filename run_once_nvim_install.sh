#!/usr/bin/env bash

dir=$(mktemp -d)
cd $dir
curl -L -O https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
tar xvzf $dir/nvim-linux-x86_64.tar.gz -C ~/.local/share/
ln -s ~/.local/share/nvim-linux-x86_64/bin/nvim ~/.local/bin/nvim
