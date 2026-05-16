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