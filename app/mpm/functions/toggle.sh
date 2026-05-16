# -------------------------
# Toggle system
# -------------------------

toggle() {

case "$1" in

# -------------------------
# Emoji toggle
# -------------------------
"--emoji")
    if [[ "${USE_EMOJIS}" == "true" ]]; then
        local name="${2^^}_EMOJI"
        printf "%s" "${!name:-}"
    fi
    ;;

# -------------------------
# Color toggle
# -------------------------
"--color")
    if [[ "${USE_COLORS}" == "true" ]]; then

        local name="${2,,}"
        local ground="${3:-38}"

        local r g b
        
        IFS=' ' read -r r g b <<< "${COLORS[$name]:-0 0 0}"

        printf "\033[%s;2;%s;%s;%sm" "$ground" "$r" "$g" "$b"
    fi
    ;;

# -------------------------
# Date toggle
# -------------------------
"--date")
    if [[ "${USE_DATE}" == "true" ]]; then
        printf "%s" "$DATE"
    fi
    ;;

# -------------------------
# Unknown command
# -------------------------
*)
    printf "%b\n" "[FATAL] Unknown command: $1"
    exit 1
    ;;

esac
}