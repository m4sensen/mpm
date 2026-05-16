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
