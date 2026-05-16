#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

trap 'echo "Error on line $LINENO. Exit code: $?" >&2' ERR

# Source the mpm logging/display layer
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly MPM_DIR="$(dirname "$SCRIPT_DIR")"

require() {
    local filePath="$MPM_DIR/$1"
    if [[ ! -f "$filePath" || ! -r "$filePath" ]]; then
        echo "Fatal: cannot load $filePath" >&2
        exit 1
    fi
    source "$filePath"
}

require "init/base.sh"

# -----------------------------
# Privilege Check
# -----------------------------
if [[ $EUID -ne 0 ]]; then
    logError "This script must be run as root (e.g., with sudo)."
    exit 1
fi

# Pre-cache sudo credentials
sudo -v

# -----------------------------
# Detect distro
# -----------------------------
if [[ -f /etc/os-release ]]; then
    # shellcheck source=/dev/null
    source /etc/os-release
    DISTRO="${ID:-unknown}"
else
    logFatal "Cannot detect Linux distribution."
    exit 1
fi

# -----------------------------
# Confirm helper
# -----------------------------
confirm() {
    local prompt="$1"
    while true; do
        read -rp "$(logQuestion "$prompt [Y/N]: ")" yn
        case "$yn" in
            [Yy]*) return 0 ;;
            [Nn]*) return 1 ;;
            *) logWarn "Please answer Y or N." ;;
        esac
    done
}

# -----------------------------
# System update
# -----------------------------
logSeparator
logHeading "System Update"
logParagraph "Distro detected: $DISTRO"
logSeparator

case "$DISTRO" in
    ubuntu|debian|linuxmint|pop)
        logAttempt "Updating apt package index"
        sudo apt update

        logAttempt "Upgrading installed packages"
        sudo apt upgrade -y

        if confirm "Remove unnecessary packages?"; then
            logAttempt "Running apt autoremove and autoclean"
            sudo apt autoremove -y
            sudo apt autoclean -y
        fi
        ;;

    fedora)
        logAttempt "Running dnf upgrade"
        sudo dnf upgrade --refresh -y

        if confirm "Remove cached packages?"; then
            logAttempt "Running dnf autoremove and clean"
            sudo dnf autoremove -y
            sudo dnf clean all
        fi
        ;;

    arch|manjaro|endeavouros)
        logAttempt "Running pacman full system upgrade"
        sudo pacman -Syu --noconfirm

        if confirm "Remove orphaned packages?"; then
            logAttempt "Removing orphaned packages"
            local orphans
            orphans=$(pacman -Qdtq 2>/dev/null || true)
            if [[ -n "$orphans" ]]; then
                sudo pacman -Rns $orphans
            else
                log "No orphaned packages found."
            fi
        fi

        logAttempt "Cleaning package cache"
        sudo pacman -Sc --noconfirm
        ;;

    *)
        logFatal "Unsupported distribution: $DISTRO"
        exit 1
        ;;
esac

logSuccess "System packages updated."

# -----------------------------
# Flatpak updates
# -----------------------------
if command -v flatpak &>/dev/null; then
    logSeparator
    logAttempt "Updating Flatpak applications"
    flatpak update -y
    logSuccess "Flatpak apps updated."
fi

# -----------------------------
# Snap updates
# -----------------------------
if command -v snap &>/dev/null; then
    logSeparator
    logAttempt "Refreshing Snap packages"
    sudo snap refresh
    logSuccess "Snap packages refreshed."
fi

# -----------------------------
# Refresh GNOME icon cache
# -----------------------------
logSeparator
if [[ -d /usr/share/icons/hicolor ]]; then
    logAttempt "Updating GNOME icon cache"
    if sudo gtk-update-icon-cache /usr/share/icons/hicolor 2>/dev/null; then
        logSuccess "Icon cache updated."
    else
        logWarn "gtk-update-icon-cache not available; skipping."
    fi
fi

# Refresh GNOME shell if on X11
if [[ "${XDG_SESSION_TYPE:-}" == "x11" ]] && command -v gnome-shell &>/dev/null; then
    logAttempt "Reloading GNOME Shell (X11)"
    DISPLAY="${DISPLAY:-:0}" gnome-shell --replace &>/dev/null &
    logSuccess "GNOME Shell reload triggered."
elif [[ "${XDG_SESSION_TYPE:-}" == "wayland" ]]; then
    logWarn "Wayland session detected — log out and back in to refresh GNOME Shell."
fi

logSeparator
logSuccess "System update complete!"
logSeparator

logReturn
