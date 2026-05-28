abbr 3days 'khal list -o (date +"%d.%m.%Y") 3d'
abbr 4k 'gnome-monitor-config set -LpM DP-2 -m "3840x2160@59.997" -s 1.25'
abbr b "bookmarks | fzf | cut -d ' ' -f 1 | xargs xdg-open"
abbr ba 'bookmarks'
abbr dvga 'podman run --rm -t -p 5000:5000 docker.io/dolevf/dvga'
abbr external-ip 'curl https://ipinfo.io/'
abbr f "fd --type f | fzf | sed 's/\ /\\\ /g' | xargs nvim"
abbr fedora 'distrobox-enter fedora-stoeps'
abbr fullhd 'gnome-monitor-config set -LpM DP-2 -s 1.0 -m "1920x1080@60.000"'
abbr gmail 'neomutt -F ~/.config/neomutt/neomuttrc_gmail'
abbr juiceshop 'podman run --rm -p 3000:3000 docker.io/bkimminich/juice-shop'
abbr kali 'distrobox-enter kali'
abbr nextweek 'khal list -o (date -dnext-monday +%d.%m.%Y) 7d 2>/dev/null'
abbr r 'cd (git rev-parse --show-toplevel)'
abbr sage 'sage -n jupyter --ip=0.0.0.0 --port=8888'
abbr tmux_work 'tmuxp load ~/.config/tmux/tmuxp-work.yml'
abbr today 'khal list -o (date +"%d.%m.%Y") 1d 2>/dev/null'
abbr tomorrow 'khal list -o (date -d "+1 days" +"%d.%m.%Y") 1d 2>/dev/null'
abbr ubuntu 'distrobox-enter ubuntu'
abbr vf 'fd --type f --hidden --exclude .git | fzf-tmux -p | xargs nvim'
abbr yt-mp3 'youtube-dl -t mp3 -x'
abbr yt-mp4 'youtube-dl -t mp4'
abbr loremw 'curl -s -X POST https://lipsum.com/feed/json -d "amount=5" -d "what=words" -d "start=false" | jq -r ".feed.lipsum" | wl-copy'
abbr loremp 'curl -s -X POST https://lipsum.com/feed/json -d "amount=5" -d "what=paras" -d "start=false" | jq -r ".feed.lipsum" | wl-copy'
abbr weather 'curl -s wttr.in/heppenheim?1&d&F'

# Replace ls with eza
# abbr ls 'eza -al --color=always --group-directories-first --icons=always' # preferred listing
abbr la 'eza -la --color=always --group-directories-first --icons=always'  # all files and dirs
abbr ll 'eza -l --color=always --group-directories-first --icons=always'  # long format
abbr lt 'eza -aT --color=always --group-directories-first --icons=always' # tree listing
abbr l. "eza -a | grep -e '^\.'"                                     # show only dotfiles
# vimwiki abbreviations
abbr diary "cd ~/vimwiki; vim -c VimwikiMakeDiaryNote"
abbr index "cd ~/vimwiki; vim latest/index.md"
