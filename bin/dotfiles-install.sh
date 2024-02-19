echo ".dotfiles" >> ~/.gitignore
alias dotfiles=$(which git)' --git-dir=$HOME/.dotfiles/.git --work-tree=$HOME'
# Set core.worktree + gitdir in ~/.git to make it work with Magit
echo 'gitdir: ./.dotfiles/.git/' >> ~/.git
dotfiles config --local core.worktree $HOME
dotfiles config --local status.showUntrackedFiles no
dotfiles checkout
dotfiles status
dotfiles reset --hard
dotfiles status
