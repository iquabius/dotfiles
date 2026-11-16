#!/bin/sh
# fish shell colours. fish has no terminal-background detection, so the theme
# is swapped explicitly.
# Run by darkman on the dark transition.
set -eu

command -v fish >/dev/null 2>&1 || exit 0
# 'theme save' writes fish_color_* as universal variables, which propagate to
# every running fish instantly. It prompts to overwrite, hence the 'echo y'.
echo y | fish -c 'fish_config theme save "Tomorrow Night Bright"' >/dev/null 2>&1 || true
