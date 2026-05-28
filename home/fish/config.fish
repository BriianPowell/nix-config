abbr -a reload 'source ~/.config/fish/conf.d/00-tide-config.fish; source ~/.config/fish/conf.d/01-dotfiles.fish; source ~/.config/fish/conf.d/z-tide-reload.fish; or true'
abbr -a l ls -lha
abbr -a lblk lsblk --output NAME,SIZE,RM,FSTYPE,FSUSE%,SERIAL,MOUNTPOINT

set -U fish_greeting

# Autosuggestions (fish "predictive" ghost text); independent of iTerm ANSI 8.
set -U fish_color_autosuggestion brblack --dim
set -Ux EDITOR vim
set -Ux PYENV_ROOT $HOME/.pyenv
set -Ux GOENV_ROOT $HOME/.goenv

command -q pyenv; and pyenv init - fish | source
command -q goenv; and goenv init - fish | source
command -q kubectl; and kubectl completion fish | source

fish_add_path /usr/local/bin
fish_add_path /usr/local/sbin
fish_add_path /opt/homebrew/bin
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.rbenv/bin
fish_add_path $HOME/.krew/bin
fish_add_path $PYENV_ROOT/bin
fish_add_path $GOENV_ROOT/bin

# fish_add_path returns 1 when paths are already present; keep source/reload success.
true
