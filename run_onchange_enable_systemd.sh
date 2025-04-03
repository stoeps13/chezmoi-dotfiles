#!/usr/bin/env bash
# fail with rc 0 when flatpak is not installed
type davmail >/dev/null 2>&1 || exit 0

systemctl enable --user davmail.service
