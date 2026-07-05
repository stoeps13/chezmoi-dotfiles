source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

function vg
    set RELOAD 'reload:rg --column --color=always --smart-case {q} || :'
    set OPENER 'if test $FZF_SELECT_COUNT -eq 0
        nvim {1} +{2}
    else
        nvim +cw -q {+f}
    end'

    fzf --disabled --ansi --multi \
        --bind "start:$RELOAD" --bind "change:$RELOAD" \
        --bind "enter:become:$OPENER" \
        --bind "ctrl-o:execute:$OPENER" \
        --bind 'alt-a:select-all,alt-d:deselect-all,ctrl-/:toggle-preview' \
        --delimiter : \
        --preview 'bat --style=full --color=always --highlight-line {2} {1}' \
        --preview-window '~4,+{2}+4/3,<80(up)' \
        --query "$argv"
end

function bwu
  set -xU BW_SESSION (bw unlock --raw $argv[1])
end

# direnv
direnv hook fish | source

# Disable fish greeting (default: fastfetch), add emtpy function
function fish_greeting
    
end

set -x XDG_CONFIG_HOME "/home/stoeps/.config"
set -x EDITOR "/usr/bin/nvim"

# Update tmux window name to current directory
function fish_prompt_update_tmux --on-event fish_prompt
    if set -q TMUX
        tmux rename-window (basename (pwd))
    end
end
function fish_cd_update_tmux --on-variable PWD
    if set -q TMUX
        tmux rename-window (basename (pwd))
    end
end

fish_ssh_agent
# if type -q keychain
#     SHELL=(which fish) keychain --quiet --eval id_ed25519 | source
# end
set -gx KIMCHI_API_KEY castai_v1_11acaf4bfb798c1ef584899bb1f7b739fdca1c7446c547264703e1f0baac8d1e_375fb16a

function fish_remove_path
    if set -l index (contains -i $argv[1] $fish_user_paths)
        set --erase --universal fish_user_paths[$index]
        echo "Updated fish_user_paths: $fish_user_paths"
    else
        echo "$argv[1] not found in fish_user_paths: $fish_user_paths"
    end
end
