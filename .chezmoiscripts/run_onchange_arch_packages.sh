{{- if or (eq .chezmoi.osRelease.id "cachyos") (eq .chezmoi.osRelease.id "arch") (ne .profile "devcontainer") -}}
#!/bin/sh

set -e -u

{{- if .packages.arch.pacman }}
{{- range .packages.arch.pacman }}
if ! dpkg -l {{ . | quote }} >/dev/null 2>&1; then
    echo "Installing pacman package: {{ . }}"
    sudo pacman -Sy --noconfirm {{ . | quote }}
fi
{{- end }}
{{- end }}

{{- if .packages.arch.yay }}
{{- range .packages.arch.yay }}
if ! dpkg -l {{ . | quote }} >/dev/null 2>&1; then
    echo "Installing AUR package: {{ . }}"
    yay -Sy --noconfirm {{ . | quote }}
fi
{{- end }}
{{- end }}


{{ end -}}
