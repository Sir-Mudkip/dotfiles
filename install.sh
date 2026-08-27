#!/usr/bin/env bash

set -e

echo "NOTE: MAKE SURE YOU HAVE CURL INSTALLED!"

pre_req(){
    if ! command -v curl &>/dev/null; then
        echo "curl is not installed"
        exit 0
    else
        echo "Starting Install"
    fi
}

DOTFILES="$HOME/dotfiles"
TOOLKIT="$HOME/toolkit"

# Ensure submodules are cloned
git -C "$DOTFILES" submodule update --init --recursive

link() {
    mkdir -p "$(dirname "$2")"
    # Already pointing where we want it, leave it alone so re-runs are a no-op
    if [ -L "$2" ] && [ "$(readlink -f "$2")" = "$(readlink -f "$1")" ]; then
        echo "Already linked: $2"
        return 0
    fi
    # Anything else in the way (real file, or a symlink elsewhere) gets backed up
    if [ -e "$2" ] || [ -L "$2" ]; then
        mv "$2" "$2.bak"
    fi
    ln -s "$1" "$2"
}

pre_req

echo "==Toolbox of Things=="

mkdir -p "$TOOLKIT"
# Clone on first run, pull on re-runs, so install.sh stays re-runnable
clone_or_pull() {
    if [ -d "$2/.git" ]; then
        echo "Updating $(basename "$2")"
        git -C "$2" pull --ff-only
    else
        git clone "$1" "$2"
    fi
}

clone_or_pull https://github.com/danielmiessler/SecLists.git "$TOOLKIT/seclists"
tar -xzvf "$TOOLKIT/seclists/Passwords/Leaked-Databases/rockyou.txt.tar.gz" -C "$TOOLKIT/seclists/Passwords/Leaked-Databases/"
clone_or_pull https://github.com/ReversecLabs/awspx.git "$TOOLKIT/awspx"
clone_or_pull https://github.com/HackTricks-wiki/hacktricks "$TOOLKIT/hacktricks"
mkdir -p "$TOOLKIT/bloodhound"
curl -fsSL https://raw.githubusercontent.com/SpecterOps/BloodHound/refs/heads/main/examples/docker-compose/docker-compose.yml > "$TOOLKIT/bloodhound/docker-compose.yml"
curl -fsSL https://raw.githubusercontent.com/SpecterOps/BloodHound/refs/heads/main/examples/docker-compose/.env.example > "$TOOLKIT/bloodhound/.env.example"
curl -fsSL https://raw.githubusercontent.com/SpecterOps/BloodHound/refs/heads/main/examples/docker-compose/bloodhound.config.json > "$TOOLKIT/bloodhound/bloodhound.config.json"

echo "==Brew And Flatpak=="

"$DOTFILES/brew/bundle.sh"

echo "==Initiating Symlinks=="

link "$DOTFILES/starship/starship.toml" "$HOME/.config/starship.toml"
link "$DOTFILES/claude/skills" "$HOME/.claude/skills"
link "$DOTFILES/claude/settings.json" "$HOME/.claude/settings.json"
link "$DOTFILES/git/gitignore-global" "$HOME/.gitignore-global"
link "$DOTFILES/git/gitconfig" "$HOME/.gitconfig"
link "$DOTFILES/nvim" "$HOME/.config/nvim"
link "$DOTFILES/shell/bashrc" "$HOME/.bashrc"
link "$DOTFILES/shell/bashrc.d" "$HOME/.bashrc.d"
link "$DOTFILES/tmux/tmux.conf" "$HOME/.tmux.conf"
link "$DOTFILES/vscode/settings.json" "$HOME/.config/Code/User/settings.json"

echo "Next steps (if not present) are Install Podman and Docker"
