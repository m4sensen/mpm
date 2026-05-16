#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

trap 'echo "Error on line $LINENO. Exit code: $?" >&2' ERR

# -----------------------------
# Privilege Check
# -----------------------------
if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root (e.g., with sudo)." >&2
    exit 1
fi

# -----------------------------
# Paths & User Context
# -----------------------------
readonly PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly INSTALL_DIR="/usr/local/lib/mpm"
readonly SYMLINK="/usr/local/bin/mpm"

readonly TARGET_USER="${SUDO_USER:-$USER}"

# -----------------------------
# Helpers
# -----------------------------
confirm_action() {
    local prompt="$1"
    local choice
    while true; do
        read -rp "$prompt [S]kip/[R]eplace/[C]ancel: " choice
        case "$choice" in
            [Ss]*) return 1 ;;
            [Rr]*) return 0 ;;
            [Cc]*) exit 1 ;;
            *) echo "Invalid option. Please enter S, R, or C." ;;
        esac
    done
}

safe_copy() {
    local src="${1:?src required}"
    local dest="${2:?dest required}"
    local perms="${3:-644}"

    [[ -e "$src" ]] || { echo "Source not found: $src" >&2; exit 1; }

    if [[ -e "$dest" ]]; then
        if confirm_action "Target $dest exists. Replace?"; then
            rm -rf -- "$dest"
        else
            echo "Skipping $dest"
            return 0
        fi
    fi

    cp -r -- "$src" "$dest"
    chown -R root:root "$dest"

    if [[ -d "$dest" ]]; then
        find "$dest" -type d -exec chmod 755 {} +
        find "$dest" -type f -exec chmod "$perms" {} +
        find "$dest" -name "*.sh" -exec chmod 755 {} +
        [[ -f "$dest/main" ]] && chmod 755 "$dest/main"
    else
        chmod "$perms" "$dest"
    fi

    echo "Installed: $src → $dest"
}

# -----------------------------
# Install app files
# -----------------------------
echo "Installing mpm..."

safe_copy "$PROJECT_DIR/app/mpm" "$INSTALL_DIR" 755

# -----------------------------
# Create symlink so `mpm` works from anywhere
# -----------------------------
if [[ -L "$SYMLINK" ]]; then
    rm -f "$SYMLINK"
fi
ln -sf "$INSTALL_DIR/main" "$SYMLINK"
chmod 755 "$SYMLINK"
echo "Symlink created: $SYMLINK → $INSTALL_DIR/main"

# -----------------------------
# Desktop entry + icon
# -----------------------------
[[ -f "$PROJECT_DIR/app/assets/mpm.desktop" ]] && \
    safe_copy "$PROJECT_DIR/app/assets/mpm.desktop" "/usr/share/applications/mpm.desktop" 644

[[ -f "$PROJECT_DIR/app/assets/mpm.svg" ]] && \
    safe_copy "$PROJECT_DIR/app/assets/mpm.svg" "/usr/share/icons/hicolor/scalable/apps/mpm.svg" 644

if command -v gtk-update-icon-cache &>/dev/null && [[ -d /usr/share/icons/hicolor ]]; then
    gtk-update-icon-cache /usr/share/icons/hicolor 2>/dev/null || true
fi

# -----------------------------
# Done
# -----------------------------
echo ""
echo "Installation complete. Run: mpm version"
echo "(No shell restart needed — /usr/local/bin is already in your PATH.)"
