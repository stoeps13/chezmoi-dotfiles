#!/usr/bin/env bash

export strFile="$HOME/.local/bin/nvim"
if [[ -L "$strFile" ]] && [[ ! -a "$strFile" ]]
then
    echo 'Nvim symlink not working'
    rm -f "$HOME/.local/bin/nvim"
    ln -s "$HOME/.local/share/nvim-linux-x86_64/bin/nvim" "$HOME/.local/bin/nvim"
elif ! [ -e "$strFile" ]
then
    ln -s "$HOME/.local/share/nvim-linux-x86_64/bin/nvim" "$HOME/.local/bin/nvim"
fi
