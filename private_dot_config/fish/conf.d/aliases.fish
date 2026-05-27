
# alias 3days='khal list -o (date +"%d.%m.%Y") 3d'
# alias 4k='gnome-monitor-config set -LpM DP-2 -m "3840x2160@59.997" -s 1.25'
# alias b="bookmarks | fzf | cut -d ' ' -f 1 | xargs xdg-open"
# alias ba='bookmarks'
# alias dvga='podman run --rm -t -p 5000:5000 docker.io/dolevf/dvga'
# alias external-ip='curl https://ipinfo.io/'
# alias f="fd --type f | fzf | sed 's/\ /\\\ /g' | xargs nvim"
# alias fedora='distrobox-enter fedora-stoeps'
# alias fullhd='gnome-monitor-config set -LpM DP-2 -s 1.0 -m "1920x1080@60.000"'
# alias gmail='neomutt -F ~/.config/neomutt/neomuttrc_gmail'
# alias juiceshop='podman run --rm -p 3000:3000 docker.io/bkimminich/juice-shop'
# alias kali='distrobox-enter kali'
# alias nextweek='khal list -o (date -dnext-monday +%d.%m.%Y) 7d 2>/dev/null'
# alias r='cd (git rev-parse --show-toplevel)'
# alias sage='sage -n jupyter --ip=0.0.0.0 --port=8888'
# alias tmux_work='tmuxp load ~/.config/tmux/tmuxp-work.yml'
# alias today='khal list -o (date +"%d.%m.%Y") 1d 2>/dev/null'
# alias tomorrow='khal list -o (date -d "+1 days" +"%d.%m.%Y") 1d 2>/dev/null'
# alias ubuntu='distrobox-enter ubuntu'
# alias vf='fd --type f --hidden --exclude .git | fzf-tmux -p | xargs nvim'
# alias yt-mp3='youtube-dl -t mp3 -x'
# alias yt-mp4='youtube-dl -t mp4'
# alias loremw='curl -s -X POST https://lipsum.com/feed/json -d "amount=5" -d "what=words" -d "start=false" | jq -r ".feed.lipsum" | wl-copy'
# alias loremp='curl -s -X POST https://lipsum.com/feed/json -d "amount=5" -d "what=paras" -d "start=false" | jq -r ".feed.lipsum" | wl-copy'
# alias weather='curl -s wttr.in/heppenheim?1&d&F'
# 
# # Replace ls with eza
# alias ls='eza -al --color=always --group-directories-first --icons=always' # preferred listing
# alias la='eza -a --color=always --group-directories-first --icons=always'  # all files and dirs
# alias ll='eza -l --color=always --group-directories-first --icons=always'  # long format
# alias lt='eza -aT --color=always --group-directories-first --icons=always' # tree listing
# alias l.="eza -a | grep -e '^\.'"                                     # show only dotfiles

# Make alias for vim to neovim (save muscle memory in ssh and server sessions)
function vim
    nvim $argv
end

# ── Functions (can't be aliases) ──────────────────────────────────────────────

function fix
    git diff --name-only | uniq | xargs $EDITOR
end

function tpane
    tmux rename-window (echo $hostname | awk -F '.' '{print $1}')
end
