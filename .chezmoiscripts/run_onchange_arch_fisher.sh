{{ if eq .chezmoi.os "arch" -}}
#!/bin/bash

set -e -u

# Fisher is a fish function, not a binary — check via fish itself
if ! fish -c "type fisher" >/dev/null 2>&1; then
    echo "Error: fisher is not available. Ensure 'fisher' is in your brew list and has been installed."
    exit 1
fi

{{ range .packages.arch.fisher -}}
if ! grep -qF {{ . | quote }} ~/.config/fish/fish_plugins 2>/dev/null; then
    echo "Installing fisher plugin: {{ . }}"
    fish -c "fisher install {{ . | quote }}"
fi
{{ end -}}
{{ end -}}
