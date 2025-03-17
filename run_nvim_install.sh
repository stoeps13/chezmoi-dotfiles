#!/usr/bin/env bash

dir=$(mktemp -d)
cd $dir
curl -sS -L -O https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
tar xzf $dir/nvim-linux-x86_64.tar.gz -C ~/.local/share/
echo "Install or update neovim"
if [ -L ~/.local/bin/nvim ]; then
  rm ~/.local/bin/nvim
fi
ln -s ~/.local/share/nvim-linux-x86_64/bin/nvim ~/.local/bin/nvim

if [ -z /usr/bin/npm ]; then
  echo "Install yarn!"
  npm install yarn
fi

