# Function to safely remove a file
safe_file_remove() {
    local file=$1
    if [[ -f "$file" ]]; then
        while true; do
            read -rp "Do you want to remove $file? [Y]es/[N]o/[C]ancel: " choice
            case "$choice" in
                [Yy]* )
                    sudo rm "$file"
                    echo "Removed $file"
                    return 0
                    ;;
                [Nn]* )
                    echo "Skipping $file"
                    return 0
                    ;;
                [Cc]* )
                    echo "Uninstallation cancelled by user."
                    exit 1
                    ;;
                * )
                    echo "Please enter Y, N, or C."
                    ;;
            esac
        done
    else
        echo "File $file does not exist, skipping."
    fi
}

safe_folder_remove() {
    local dir="$1"

    # Check if directory exists
    if [[ ! -d "$dir" ]]; then
        echo "Directory $dir does not exist, skipping."
        return 0
    fi

    # Prevent catastrophic deletions
    case "$dir" in
        "/"|"/usr"|"/usr/local"|"/home"|"/bin"|"/etc")
            echo "Error: refusing to remove critical directory: $dir"
            exit 1
            ;;
    esac

    while true; do
        read -rp "Do you want to remove directory $dir ? [Y]es/[N]o/[C]ancel: " choice
        case "$choice" in
            [Yy]* )
                sudo rm -rf -- "$dir"
                echo "Removed directory $dir"
                return 0
                ;;
            [Nn]* )
                echo "Skipping $dir"
                return 0
                ;;
            [Cc]* )
                echo "Uninstallation cancelled by user."
                exit 1
                ;;
            * )
                echo "Please enter Y, N, or C."
                ;;
        esac
    done
}
