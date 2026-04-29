#!/usr/bin/env bash

set -euo pipefail


BREW_PATH=(
    /var/home/linuxbrew/.linuxbrew/bin/brew
    /home/linuxbrew/.linuxbrew/bin/brew
    /opt/homebrew/bin/brew
    /usr/local/bin/brew
)

PKG_MANAGER=(
    dnf
    apt
    pacman
    zypper
    yum
)

REQUIRED_BREWFILES=(
    "$HOME/dotfiles/brew/core.Brewfile"
    "$HOME/dotfiles/brew/essential.Brewfile"
)

OPTIONAL_BREWFILES=(
    "$HOME/dotfiles/brew/gui.Brewfile"
    "$HOME/dotfiles/brew/vscode.Brewfile"
)

BREWFILES=("${REQUIRED_BREWFILES[@]}" "${OPTIONAL_BREWFILES[@]}")

declare -A BREW_SPECIAL_CASES=([rg]=ripgrep [nvim]=neovim) 
declare -A CASK_SPECIAL_CASES=([code]=visual-studio-code-linux [claude]=claude-code)

HOMEBREW_BUNDLE_BREW_SKIP=""
HOMEBREW_BUNDLE_CASK_SKIP=""
HOMEBREW_BUNDLE_VSCODE_SKIP=""

confirm() {
    local prompt="$1"
    while true; do
    read -rp "$prompt [y/N]" yn
    case $yn in
        [Yy]* ) return 0;;
        [Nn]* ) return 1;;
        * ) echo "Please yes or no.";;
    esac
done
}

ensure_brew() {
    if command -v brew &>/dev/null; then
        echo "Brew already installed, skipping"
        return 0
    fi
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    for path in "${BREW_PATH[@]}"; do
        if [[ -x "$path" ]]; then
            eval "$("$path" shellenv)"
            break
        fi
    done
    if ! command -v brew &>/dev/null; then
        echo "Brew install finished but 'brew' is not on PATH. Open a new shell and re-run." >&2
        exit 1
    fi
    echo "Brew added to your path variable, continuing"
}

ensure_flatpak() {
    if command -v flatpak &>/dev/null; then
        echo "Flatpak already installed. Skipping"
        return 0
    fi
    for pkg in "${PKG_MANAGER[@]}"; do
        if command -v "$pkg" &>/dev/null; then
            if [[ "$pkg" != pacman ]]; then
                sudo "$pkg" install -y flatpak
                flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
                echo "Reboot your system and execute this file again"
                exit 0
            else
                sudo "$pkg" -S flatpak
                flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
            fi
            break
        fi
    done
}

parse() {
    grep -vE "flatpak|vscode|wallpapers|tap|#" "$@" | awk '{print $2}' | tr -dc "[:alnum:]-\n\r./@"
}

check_brew_binaries() {
    local brew_prefix; brew_prefix="$(brew --prefix)"
    for cmd in $(parse "${BREWFILES[@]}"); do
        local found; found="$(command -v "$cmd" 2>/dev/null || true)"
        if [[ -n "$found" && "$found" != "$brew_prefix"/* ]]; then
            HOMEBREW_BUNDLE_BREW_SKIP+=" $cmd"
        fi
    done
    for cmd in "${!BREW_SPECIAL_CASES[@]}"; do
        local found; found="$(command -v "$cmd" 2>/dev/null || true)"
        if [[ -n "$found" && "$found" != "$brew_prefix"/* ]]; then
            HOMEBREW_BUNDLE_BREW_SKIP+=" ${BREW_SPECIAL_CASES[$cmd]}"
        fi
    done
    export HOMEBREW_BUNDLE_BREW_SKIP
}

check_cask_binaries() {
    local brew_prefix; brew_prefix="$(brew --prefix)"
    for cmd in "${!CASK_SPECIAL_CASES[@]}"; do
        local found; found="$(command -v "$cmd" 2>/dev/null || true)"
        if [[ -n "$found" && "$found" != "$brew_prefix"/* ]]; then
            HOMEBREW_BUNDLE_CASK_SKIP+=" ${CASK_SPECIAL_CASES[$cmd]}"
        fi
    done
    export HOMEBREW_BUNDLE_CASK_SKIP
}

check_vscode_extensions() {
    if ! command -v code &>/dev/null; then
        return 0
    fi
    local installed; installed="$(code --list-extensions 2>/dev/null || true)"
    [[ -z "$installed" ]] && return 0
    while IFS= read -r ext; do
        HOMEBREW_BUNDLE_VSCODE_SKIP+=" $ext"
    done <<< "$installed"
    export HOMEBREW_BUNDLE_VSCODE_SKIP
}

select_brewfiles() {
    SELECTED_BREWFILES=("${REQUIRED_BREWFILES[@]}")
    for file in "${OPTIONAL_BREWFILES[@]}"; do
        if confirm "Install $(basename "$file")?"; then
            SELECTED_BREWFILES+=("$file")
        fi
    done
}

main() {
    ensure_brew
    ensure_flatpak
    check_brew_binaries
    check_cask_binaries
    check_vscode_extensions

    select_brewfiles
    if ((${#SELECTED_BREWFILES[@]} == 0)); then
        echo "No Brewfiles selected. Nothing to do."
        return
    fi

    echo "BREW_SKIP:  ${HOMEBREW_BUNDLE_BREW_SKIP:-(none)}"
    echo "CASK_SKIP:  ${HOMEBREW_BUNDLE_CASK_SKIP:-(none)}"
    echo "VSCODE_SKIP:${HOMEBREW_BUNDLE_VSCODE_SKIP:+ }${HOMEBREW_BUNDLE_VSCODE_SKIP:-(none)}"

    for file in "${SELECTED_BREWFILES[@]}"; do
        echo "==$(basename "$file")=="
        brew bundle --file "$file"
    done
}

main "$@"
