# Chezmoi Dotfiles

This repository contains the personal configuration files and machine setup scripts managed by Chezmoi for multiple workstations.

## Stack

- Chezmoi templates and externals
- POSIX shell scripts
- Arch Linux package and Fisher setup scripts
- `pre-commit` with standard checks and Betterleaks

## Layout

- `.chezmoi.toml.tmpl` — Chezmoi configuration and template data.
- `.chezmoiscripts/` — scripts run after apply or when their inputs change.
- `.chezmoiexternals/` — externally fetched files, archives, and Git repositories.
- `dot_*` and `private_*` — managed home-directory files; `*.tmpl` files are templated.
- `dot_gitconfig-work` and `dot_gitconfig-personal` — Git settings included by repository path.
- `README.md` — bootstrap and installation notes.

## Running it

Install Chezmoi and apply the repository with:

```bash
chezmoi init --apply https://github.com/stoeps13/chezmoi-dotfiles
```

From an existing checkout, preview and apply changes with:

```bash
chezmoi diff
chezmoi apply
```

Install development hooks once after cloning:

```bash
pre-commit install
```

## Testing

Run the configured repository checks with:

```bash
pre-commit run --all-files
```

For template or script changes, use `chezmoi diff` and, when safe on the target machine, `chezmoi apply` to validate rendered output and script behavior. There is no application test suite.

## Conventions

- Preserve Chezmoi naming conventions such as `dot_`, `private_`, and `*.tmpl`.
- Keep shell scripts executable and include a shebang.
- Run pre-commit before committing; it checks file hygiene, symlinks, private keys, and secrets.
- Chezmoi is configured for automatic local commits but not automatic pushes (`autoPush = false`).

## Gotchas

- Treat all `private_*` files and templates as sensitive. They may render credentials, SSH keys, mail settings, or WireGuard configuration; do not expose or commit rendered secrets.
- Template values can depend on the hostname. `.chezmoi.toml.tmpl` sets `distrobox` only for host `lnx-stwsh`.
- Git includes match the case-sensitive paths `~/Projects/work/**` and `~/Projects/personal/**`.
- Files under `.chezmoiscripts/` can execute during `chezmoi apply`; review scripts before applying changes.
- `.chezmoiexternals/` may download or clone content during apply, so inspect external URLs and revisions when changing them.
- Do not hand-edit files in the destination home directory when the source file is managed here; edit the Chezmoi source and apply it.
- `betterleaks` is required by the pre-commit configuration and must be installed separately from `pre-commit`.
