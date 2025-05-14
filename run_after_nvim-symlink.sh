#!/usr/bin/env bash

export strFile="$HOME/.local/bin/nvim"
if [[ -L "$strFile" ]] && [[ ! -a "$strFile" ]]
then
    # broken symlink for nvim
    rm -f "$HOME/.local/bin/nvim"
    ln -s "$HOME/.local/share/nvim-linux-x86_64/bin/nvim" "$HOME/.local/bin/nvim"
elif ! [ -e "$strFile" ]
then
    # symlink not existing
    ln -s "$HOME/.local/share/nvim-linux-x86_64/bin/nvim" "$HOME/.local/bin/nvim"
fi
