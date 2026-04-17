#!/usr/bin/env bash

set -euo pipefail

BREW_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
ROLES=(core essential gui)

DRY_RUN=0
ASSUME_YES=0
SELECTED_ROLES=()

FLATPAK_OK=0
FLATPAK_CHECKED=0

usage() {
    cat <<EOF
Usage: bundle.sh [--dry-run] [--yes] [--role <name>]...

  --dry-run       Report what would change without installing
  --yes           Skip confirmation prompts (still respects --role)
  --role <name>   Install a specific role (repeatable). Defaults to interactive prompts.

Available roles: ${ROLES[*]}
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run) DRY_RUN=1; shift ;;
        --yes|-y) ASSUME_YES=1; shift ;;
        --role) SELECTED_ROLES+=("$2"); shift 2 ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown argument: $1" >&2; usage; exit 2 ;;
    esac
done

confirm() {
    local prompt="$1"
    if [[ "$ASSUME_YES" -eq 1 ]]; then
        return 0
    fi
    local ans
    read -rp "$prompt [y/N] " ans
    [[ "$ans" =~ ^[Yy]$ ]]
}

ensure_brew() {
    if command -v brew &>/dev/null; then
        return 0
    fi
    echo "Homebrew is not installed."
    if ! confirm "Install Homebrew now?"; then
        echo "Skipping brew install. Exiting."
        exit 0
    fi
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    for candidate in /home/linuxbrew/.linuxbrew/bin/brew /opt/homebrew/bin/brew /usr/local/bin/brew; do
        if [[ -x "$candidate" ]]; then
            eval "$("$candidate" shellenv)"
            break
        fi
    done
    if ! command -v brew &>/dev/null; then
        echo "Homebrew install finished but 'brew' is not on PATH. Open a new shell and re-run." >&2
        exit 1
    fi
}

ensure_flatpak() {
    if [[ "$FLATPAK_CHECKED" -eq 1 ]]; then
        return "$((1 - FLATPAK_OK))"
    fi
    FLATPAK_CHECKED=1

    if ! command -v flatpak &>/dev/null; then
        cat >&2 <<EOF
flatpak is not installed. Install it first, then re-run:
  Fedora Atomic:  rpm-ostree install flatpak && systemctl reboot
  Fedora/others:  sudo dnf install flatpak

Skipping flatpak-bearing roles for this run.
EOF
        FLATPAK_OK=0
        return 1
    fi

    if flatpak remote-list --columns=name 2>/dev/null | grep -qx flathub; then
        FLATPAK_OK=1
        return 0
    fi

    echo "Flathub remote is not configured."
    if ! confirm "Add flathub (user scope)?"; then
        echo "Skipping flatpak-bearing roles for this run."
        FLATPAK_OK=0
        return 1
    fi
    flatpak remote-add --if-not-exists --user flathub \
        https://dl.flathub.org/repo/flathub.flatpakrepo
    FLATPAK_OK=1
    return 0
}

parse_entries() {
    local file="$1" kind="$2"
    grep -E "^[[:space:]]*${kind}[[:space:]]+\"[^\"]+\"" "$file" 2>/dev/null \
        | sed -E "s/^[[:space:]]*${kind}[[:space:]]+\"([^\"]+)\".*/\1/" \
        || true
}

is_system_path() {
    local path="$1" brew_prefix="$2"
    [[ -n "$path" && "$path" != "$brew_prefix"/* && "$path" != "$HOME"/* ]]
}

# Globals populated by analyse_role; printed by report_role and used by run_role.
BREW_TO_INSTALL=()
BREW_ALREADY=()
BREW_SYSTEM_SKIP=()       # names only, for HOMEBREW_BUNDLE_BREW_SKIP
BREW_SYSTEM_SKIP_LABEL=() # "name (/path)" for display
FLATPAK_TO_INSTALL=()
FLATPAK_ALREADY=()
ROLE_HAS_FLATPAK=0

analyse_role() {
    local file="$1"
    BREW_TO_INSTALL=()
    BREW_ALREADY=()
    BREW_SYSTEM_SKIP=()
    BREW_SYSTEM_SKIP_LABEL=()
    FLATPAK_TO_INSTALL=()
    FLATPAK_ALREADY=()
    ROLE_HAS_FLATPAK=0

    local brew_prefix
    brew_prefix="$(brew --prefix)"

    while IFS= read -r pkg; do
        [[ -z "$pkg" ]] && continue
        if brew list --formula --versions "$pkg" &>/dev/null; then
            BREW_ALREADY+=("$pkg")
            continue
        fi
        local bin_name="${pkg##*/}"
        local found
        found="$(command -v "$bin_name" 2>/dev/null || true)"
        if is_system_path "$found" "$brew_prefix"; then
            BREW_SYSTEM_SKIP+=("$pkg")
            BREW_SYSTEM_SKIP_LABEL+=("$pkg ($found)")
            continue
        fi
        BREW_TO_INSTALL+=("$pkg")
    done < <(parse_entries "$file" brew)

    while IFS= read -r id; do
        [[ -z "$id" ]] && continue
        ROLE_HAS_FLATPAK=1
        if command -v flatpak &>/dev/null && flatpak info "$id" &>/dev/null; then
            FLATPAK_ALREADY+=("$id")
        else
            FLATPAK_TO_INSTALL+=("$id")
        fi
    done < <(parse_entries "$file" flatpak)
}

report_role() {
    local file="$1"
    echo "  file: $file"
    printf '    will install (brew) (%d): %s\n' \
        "${#BREW_TO_INSTALL[@]}" "${BREW_TO_INSTALL[*]:-none}"
    if ((${#BREW_SYSTEM_SKIP_LABEL[@]})); then
        printf '    skipped (system package):\n'
        printf '      - %s\n' "${BREW_SYSTEM_SKIP_LABEL[@]}"
    fi
    printf '    already via brew (%d): %s\n' \
        "${#BREW_ALREADY[@]}" "${BREW_ALREADY[*]:-none}"
    if ((ROLE_HAS_FLATPAK)); then
        printf '    will install (flatpak) (%d): %s\n' \
            "${#FLATPAK_TO_INSTALL[@]}" "${FLATPAK_TO_INSTALL[*]:-none}"
        printf '    already via flatpak (%d): %s\n' \
            "${#FLATPAK_ALREADY[@]}" "${FLATPAK_ALREADY[*]:-none}"
    fi
}

run_role() {
    local role="$1"
    local file="$BREW_DIR/${role}.Brewfile"
    echo
    echo "=== ${role} ==="
    if [[ ! -f "$file" ]]; then
        echo "  (no Brewfile at $file — skipping)"
        return 0
    fi

    analyse_role "$file"
    report_role "$file"

    if ((ROLE_HAS_FLATPAK)) && ((${#FLATPAK_TO_INSTALL[@]})); then
        if ! ensure_flatpak; then
            if ((${#BREW_TO_INSTALL[@]} == 0)); then
                echo "  no installable brew entries remain — skipping role."
                return 0
            fi
            echo "  proceeding with brew entries only; flatpak entries skipped."
        fi
    fi

    if [[ "$DRY_RUN" -eq 1 ]]; then
        return 0
    fi
    if ((${#BREW_TO_INSTALL[@]} == 0 && ${#FLATPAK_TO_INSTALL[@]} == 0)); then
        echo "  nothing to do."
        return 0
    fi
    if ! confirm "Proceed with 'brew bundle --file=${file}'?"; then
        echo "  skipped."
        return 0
    fi

    local skip_list=""
    if ((${#BREW_SYSTEM_SKIP[@]})); then
        skip_list="${BREW_SYSTEM_SKIP[*]}"
    fi
    HOMEBREW_BUNDLE_BREW_SKIP="$skip_list" brew bundle --file="$file"
}

main() {
    ensure_brew

    local roles_to_run=()
    if ((${#SELECTED_ROLES[@]})); then
        roles_to_run=("${SELECTED_ROLES[@]}")
    else
        for role in "${ROLES[@]}"; do
            if confirm "Install '${role}' Brewfile?"; then
                roles_to_run+=("$role")
            fi
        done
    fi

    if ((${#roles_to_run[@]} == 0)); then
        echo "No roles selected. Nothing to do."
        exit 0
    fi

    for role in "${roles_to_run[@]}"; do
        run_role "$role"
    done
}

main "$@"
