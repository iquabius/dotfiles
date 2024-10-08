# This throws errors in Archcraft because Byobu is not installed.
# status --is-login; and status --is-interactive; and exec byobu-launcher

# set PATH "$HOME/.dropbox-bin" $PATH

if test -d "$HOME/bin"
  set PATH "$HOME/bin" $PATH
end

if test -d "$HOME/.local/bin"
  set PATH "$HOME/.local/bin" $PATH
end

if test -e "/home/linuxbrew/.linuxbrew/bin/brew"
  eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
end

if test -e "/opt/homebrew/bin/brew"
  eval (/opt/homebrew/bin/brew shellenv)
  # Make sure /opt/homebrew/bin occurs before /usr/bin in PATH
  fish_add_path /opt/homebrew/bin
end

# We can skip completion setup if fish is installed with brew
# https://docs.brew.sh/Shell-Completion#configuring-completions-in-fish
if test -d (brew --prefix)"/share/fish/completions"
    set -p fish_complete_path (brew --prefix)/share/fish/completions
end

if test -d (brew --prefix)"/share/fish/vendor_completions.d"
    set -p fish_complete_path (brew --prefix)/share/fish/vendor_completions.d
end

if test -e (brew --prefix asdf)/libexec/asdf.fish
   source (brew --prefix asdf)/libexec/asdf.fish
end

# https://github.com/ajeetdsouza/zoxide#fish
if type -q zoxide
  zoxide init fish | source
end

# https://github.com/starship/starship
# brew install starship
if type -q starship
  starship init fish | source
end

# https://github.com/axetroy/dvm
if test -d "$HOME/.deno/bin"
  set PATH "$HOME/.deno/bin" $PATH
end

set GOPATH "$HOME/go"
if test -d "$GOPATH/bin"
  set PATH "/usr/local/go/bin" "$GOPATH/bin" $PATH
end

# TeX Live installation
if test -d "/usr/local/texlive/2023"
  set MANPATH "/usr/local/texlive/2023/texmf-dist/doc/man"
  set INFOPATH "/usr/local/texlive/2023/texmf-dist/doc/info"
  set PATH "/usr/local/texlive/2023/bin/x86_64-linux" $PATH
end

set JAVA_HOME "/opt/jdk/jdk-21.0.1/"
if test -d "$JAVA_HOME"
  set PATH "$JAVA_HOME/bin" $PATH
end

# values are already in the PATH because they are set in ~/.bashrc
set ANDROID_HOME "/opt/android/sdk"
set ANDROID_SDK_ROOT $ANDROID_HOME
if test -d "$ANDROID_HOME"
 # https://stackoverflow.com/questions/26483370#49511666
 set PATH "$ANDROID_HOME/platform-tools" "$ANDROID_HOME/emulator" "$ANDROID_HOME/cmdline-tools/bin" $PATH
end

set -g theme_display_virtualenv no

# https://stackoverflow.com/questions/64799841/how-to-stop-docker-and-kubernetes-using-docker-desktop
# macro to kill the docker desktop app and the VM (excluding vmnetd -> it's a service)
function killdocker
  ps ax | grep -i docker | egrep -iv 'grep|com.docker.vmnetd' | awk '{print $1}' | xargs kill
end

# https://www.calazan.com/docker-cleanup-commands/

# Kill all running containers.
alias dockerkillall='docker kill (docker ps -q)'

# Delete all stopped containers.
alias dockercleanc='printf "\n>>> Deleting stopped containers\n\n" & docker rm (docker ps -a -q)'

# Delete all untagged images.
alias dockercleani='printf "\n>>> Deleting untagged images\n\n" & docker rmi (docker images -q -f dangling=true)'

alias dockercleanv='docker volume ls -qf dangling=true | xargs -r docker volume rm'

# Delete all stopped containers and untagged images.
alias dockerclean='dockercleanc; and dockercleani; or or echo "Docker cleaning failed"'

alias docker-container-ip 'docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}"'

# https://ditchwindows.com/elementary-os-community-tips-and-tricks/
alias current-network-adapter 'lspci -nnk | grep 0280 -A3'

# https://ostechnix.com/how-to-use-pbcopy-and-pbpaste-commands-on-linux/
alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'

alias dotfiles=(which git)' --git-dir=$HOME/.dotfiles/.git/ --work-tree=$HOME'
alias dotfiles-code="GIT_WORK_TREE=$HOME GIT_DIR=$HOME/.dotfiles/.git/ code $HOME"

# Speed up Git workflow with keybindings: https://github.com/joseluisq/gitnow
abbr -a gaa git add -A
abbr -a gan git add .
abbr -a gau git add -u
abbr -a gcb git checkout -b
abbr -a gco git checkout
abbr -a gcr git checkout --track origin/
abbr -a gl git log --oneline
abbr -a gll git log
abbr -a gpb git push -u origin HEAD
abbr -a gp git pull --ff-only
abbr -a gprune git prune-branches
abbr -a gs git status
abbr -a gsl git status --long

# wifi-list-available
abbr -a wifi-la nmcli d wifi list
# wifi-list-configured
abbr -a wifi-lc nmcli c
# wifi-connect
abbr -a wifi-c nmcli c up
# wifi-disconnect
abbr -a wifi-d nmcli c down

# http://www.codecoffee.com/tipsforlinux/articles/22.html
function dirsize
    du -ch $argv | grep total
end

# Lists every web page in which I've taken notes with Org-roam.
function org-roam-keys
  # Adapted from https://unix.stackexchange.com/a/181264/120023
  # -r: --recursive
  # -h: --no-file-name
  # -E: --extended-regexp
  grep -rhE '#\+roam_key: (.*)$' ~/Org.d/Roam |\
  # -o: --only-matching
  grep -Eo '(http|https)(.*)$'
end
# TODO: Handle org-ref citation keys
# See https://www.orgroam.com/manual/File-Refs.html

set REACT_EDITOR "code --add"

# Generated for envman. Do not edit.
test -s "$HOME/.config/envman/load.fish"; and source "$HOME/.config/envman/load.fish"

#https://stackoverflow.com/questions/46461765/how-to-test-for-argv-count-and-value-of-argv1-in-fish-shell
#https://stackoverflow.com/questions/42950501/delete-node-modules-folder-recursively-from-a-specified-path-using-command-line
#https://fishshell.com/docs/current/cmds/argparse.html
function rmnode_modules
  if test (count $argv) -lt 1; or test $argv[1] = "--help"
    echo "Usage: remove-node_modules [OPTIONS]... [DIRECTORY]"
    echo "Remove 'node_modules' recursively for given directory." \n
    echo "Options:"
    echo "  --dry-run       List 'node_modules' directories without actually deleting them."
    echo "  --help          Show this help message."
  else if test $argv[1] = "--dry-run"
    echo "These are the node_module directories that will be removed if running without --dry-run option:"
    find $argv[2] -name 'node_modules' -type d -prune
  else
    echo "Removing 'node_modules' in $argv[1]"
    find $argv[1] -name 'node_modules' -type d -prune -printf ' Removed %p' -exec rm -rf '{}' +
  end
end

# pnpm
set -gx PNPM_HOME "$HOME/.local/share/pnpm"
set -gx PATH "$PNPM_HOME" $PATH
# pnpm end