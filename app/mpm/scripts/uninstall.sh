#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

trap 'echo "Error on line $LINENO. Exit code: $?" >&2' ERR

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
require "variables/paths.sh"
require "functions/safe-remove.sh"

# -----------------------------
# Privilege Check
# -----------------------------
if [[ $EUID -ne 0 ]]; then
    logError "This script must be run as root (e.g., with sudo)."
    exit 1
fi

logSeparator
logHeading "MPM Uninstaller"
logWarn "This will remove mpm from your system."
logSeparator

while true; do
    read -rp "$(logQuestion "Are you sure you want to uninstall mpm? [Y/N]: ")" answer
    case "$answer" in
        [Yy]*) break ;;
        [Nn]*|"")
            log "Uninstall cancelled."
            exit 0
            ;;
        *) logWarn "Please enter Y or N." ;;
    esac
done

logBreak

# Remove symlink
if [[ -L "$mpm_symlink" ]]; then
    logAttempt "Removing symlink $mpm_symlink"
    rm -f "$mpm_symlink"
    logSuccess "Removed $mpm_symlink"
else
    log "$mpm_symlink not found, skipping."
fi

# Remove installed app files
logAttempt "Removing mpm install directory"
safe_folder_remove "$mpm_install_dir"

# Remove desktop entry
logAttempt "Removing desktop entry"
safe_file_remove "$desktop_file"

# Remove icon
logAttempt "Removing application icon"
safe_file_remove "$icon_file"

# Refresh icon cache
if command -v gtk-update-icon-cache &>/dev/null && [[ -d /usr/share/icons/hicolor ]]; then
    logAttempt "Refreshing GNOME icon cache"
    gtk-update-icon-cache /usr/share/icons/hicolor 2>/dev/null || true
fi

logSeparator
logSuccess "mpm has been uninstalled."
logSeparator
