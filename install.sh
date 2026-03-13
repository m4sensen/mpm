#!/bin/bash
set -euo pipefail  # strict mode

# Resolve the directory of this installer script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Destination directories
DIR="/usr/local/bin/mpm"
BIN_DIR="$DIR/bin"
LIB_DIR="$DIR/lib"

# Function to ask user confirmation
confirm_override() {
    while true; do
        read -rp "Directory $DIR already exists and is not empty. Override installation? [y/N]: " answer
        case "$answer" in
            [Yy]* ) return 0 ;;
            [Nn]* | "" ) return 1 ;;
            * ) echo "Please enter y or n." ;;
        esac
    done
}

# Handle directory existence
if [[ -d "$DIR" && -n "$(ls -A "$DIR")" ]]; then
    if confirm_override; then
        echo "Overriding installation..."
        sudo rm -rf "$DIR"
    else
        echo "Installation cancelled."
        exit 1
    fi
fi

# Always create directories
sudo mkdir -p "$BIN_DIR"
sudo mkdir -p "$LIB_DIR"
echo "Directories ready: $DIR"

# Function to safely copy a file with overwrite prompt
safe_copy() {
    local src=$1
    local dest=$2

    if [[ ! -f "$src" ]]; then
        echo "Error: Source file $src does not exist."
        exit 1
    fi

    if [[ -f "$dest" ]]; then
        while true; do
            read -rp "File $dest already exists. [S]kip/[R]eplace/[C]ancel? " choice
            case "$choice" in
                [Ss]* )
                    echo "Skipping $dest"
                    return 0
                    ;;
                [Rr]* )
                    sudo cp "$src" "$dest"
                    echo "Replaced $dest"
                    return 0
                    ;;
                [Cc]* )
                    echo "Installation cancelled by user."
                    exit 1
                    ;;
                * )
                    echo "Please enter S, R, or C."
                    ;;
            esac
        done
    else
        sudo cp "$src" "$dest"
        echo "Copied $src to $dest"
    fi
}

# Copy all files from source bin/ and lib/ to destination
if [[ -d "$SCRIPT_DIR/bin" ]]; then
    for f in "$SCRIPT_DIR/bin/"*; do
        [[ -f "$f" ]] && safe_copy "$f" "$BIN_DIR/$(basename "$f")"
    done
fi

if [[ -d "$SCRIPT_DIR/lib" ]]; then
    for f in "$SCRIPT_DIR/lib/"*; do
        [[ -f "$f" ]] && safe_copy "$f" "$LIB_DIR/$(basename "$f")"
    done
fi

# Make all files in bin executable
sudo chmod +x "$BIN_DIR"*

# Copy desktop entry and icon if they exist
if [[ -f "$SCRIPT_DIR/assets/mpm.desktop" ]]; then
    safe_copy "$SCRIPT_DIR/assets/mpm.desktop" "/usr/share/applications/mpm.desktop"
fi

if [[ -f "$SCRIPT_DIR/assets/mpm.svg" ]]; then
    safe_copy "$SCRIPT_DIR/assets/mpm.svg" "/usr/share/icons/hicolor/scalable/apps/mpm.svg"
fi

# Only proceed if the current shell is bash
if [[ -n "${BASH_VERSION:-}" ]]; then
    BASHRC="$HOME/.bashrc"
    LINE='export PATH="/usr/local/bin/mpm/bin:$PATH"'

    # Check if line already exists
    if grep -Fxq "$LINE" "$BASHRC"; then
        echo "PATH already configured in $BASHRC"
    else
        echo "" >> "$BASHRC"  # optional newline
        echo "$LINE" >> "$BASHRC"
        echo "Added PATH to $BASHRC"
    fi

    # Reload bashrc in current session
    # shellcheck disable=SC1090
    source "$BASHRC"
    echo "PATH updated. You can now run 'mpm' commands."
else
    echo "This script only modifies ~/.bashrc for Bash shells."
    echo "Please add '/usr/local/bin/mpm/bin' to your PATH manually if using another shell."
fi

echo "Installation complete successfully!"
echo "You can now run your commands using mpm"
