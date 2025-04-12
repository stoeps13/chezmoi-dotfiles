#!/usr/bin/env bash
sed -i "s/{{ \$hugo_version := \".*\" -}}/{{ \$hugo_version := \"$(curl -fsSL https://api.github.com/repos/gohugoio/hugo/releases/latest | grep tag_name | sed -E 's/.*"v([^"]+)".*/\1/')\" -}}/" ~/.local/share/chezmoi/.chezmoiexternal.toml
