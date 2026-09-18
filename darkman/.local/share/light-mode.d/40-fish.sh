#!/bin/sh
# fish shell colours. fish has no terminal-background detection, so the theme
# is swapped explicitly.
# Run by darkman on the light transition.
set -eu

command -v fish >/dev/null 2>&1 || exit 0
echo y | fish -c 'fish_config theme save "Tomorrow"' >/dev/null 2>&1 || true
