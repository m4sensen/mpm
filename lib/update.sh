#!/bin/bash
set -euo pipefail

# -----------------------------
# Cross-distro updater script
# -----------------------------
# Works with Ubuntu/Debian, Fedora, Arch/Manjaro
# Supports flatpak, snap, system cleaning, and GNOME icon refresh
# -----------------------------

echo "Starting system updater..."

# Detect distro
if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    DISTRO=$ID
else
    echo "Cannot detect Linux distribution."
    exit 1
fi

# -----------------------------
# Function: Ask yes/no
# -----------------------------
confirm() {
    local prompt="$1"
    while true; do
        read -rp "$prompt [Y/N]: " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer Y or N.";;
        esac
    done
}

# -----------------------------
# System update
# -----------------------------
echo "Updating system packages for $DISTRO..."

case "$DISTRO" in
    ubuntu|debian|linuxmint)
        sudo apt update
        sudo apt upgrade -y
        if confirm "Do you want to remove unnecessary packages?"; then
            sudo apt autoremove -y
            sudo apt autoclean -y
        fi
        ;;
    fedora)
        sudo dnf upgrade --refresh -y
        if confirm "Do you want to remove cached packages?"; then
            sudo dnf autoremove -y
            sudo dnf clean all
        fi
        ;;
    arch|manjaro)
        sudo pacman -Syu --noconfirm
        if confirm "Do you want to remove orphaned packages?"; then
            sudo pacman -Rns $(pacman -Qdtq || true)
        fi
        sudo pacman -Sc --noconfirm
        ;;
    *)
        echo "Unsupported distro: $DISTRO"
        exit 1
        ;;
esac

# -----------------------------
# Flatpak updates
# -----------------------------
if command -v flatpak &>/dev/null; then
    echo "Updating Flatpak apps..."
    flatpak update -y
fi

# -----------------------------
# Snap updates
# -----------------------------
if command -v snap &>/dev/null; then
    echo "Updating Snap apps..."
    sudo snap refresh
fi

# -----------------------------
# Clean icon cache & refresh GNOME
# -----------------------------
echo "Refreshing GNOME icon cache and shell..."
if [[ -d /usr/share/icons/hicolor ]]; then
    sudo gtk-update-icon-cache /usr/share/icons/hicolor
fi

# Refresh GNOME shell if on X11
if [[ "$XDG_SESSION_TYPE" == "x11" ]]; then
    echo "Reloading GNOME Shell (X11)..."
    if command -v gnome-shell &>/dev/null; then
        # This will only reload the shell
        DISPLAY=$DISPLAY gnome-shell --replace &>/dev/null &
    fi
else
    echo "On Wayland, log out and log back in to refresh GNOME shell."
fi

echo "System update complete!"

# Pause and wait for Enter
read -rp "Press Enter to exit..."