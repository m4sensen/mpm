# center_text: centers lines of text (including ANSI-colored text) in the terminal
center_text() {
  local term_width
  term_width=$(tput cols 2>/dev/null || echo 80)

  while IFS= read -r line || [[ -n "$line" ]]; do
    # Strip ANSI escape codes to get the visible length
    local visible
    visible=$(printf '%s' "$line" | sed 's/\x1b\[[0-9;]*[mGKHF]//g')
    local visible_length=${#visible}

    if (( visible_length >= term_width )); then
      printf '%s\n' "$line"
    else
      local padding=$(( (term_width - visible_length) / 2 ))
      printf "%*s%s\n" "$padding" "" "$line"
    fi
  done
}
