#!/usr/bin/env bash

set -e

DOTFILES="$HOME/dotfiles"

# Ensure submodules are cloned
git -C "$DOTFILES" submodule update --init --recursive

link() {
    mkdir -p "$(dirname "$2")"
    [ -e "$2" ] && mv "$2" "$2.bak"
    ln -s "$1" "$2"
}

link "$DOTFILES/aws/config" "$HOME/.aws/config"
link "$DOTFILES/claude/skills" "$HOME/.claude/skills"
link "$DOTFILES/claude/settings.json" "$HOME/.claude/settings.json"
link "$DOTFILES/git/gitignore-global" "$HOME/.gitignore-global"
link "$DOTFILES/git/gitconfig" "$HOME/.gitconfig"
link "$DOTFILES/nvim" "$HOME/.config/nvim"
link "$DOTFILES/shell/bashrc" "$HOME/.bashrc"
link "$DOTFILES/shell/bashrc.d" "$HOME/.bashrc.d"
link "$DOTFILES/tmux/tmux.conf" "$HOME/.tmux.conf"

read -rp "Install packages via Homebrew? [y/N] " ans
[[ "$ans" =~ ^[Yy]$ ]] && "$DOTFILES/brew/bundle.sh"
