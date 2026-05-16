# -------------------------
# Date helper
# -------------------------

_log_date() {
    if [[ "${USE_DATE:-false}" == "true" ]]; then
        printf '[%s] ' "$(date '+%Y-%m-%d %H:%M:%S')"
    fi
}

# -------------------------
# Standard Logs
# -------------------------

log() {
  printf "%b\n" "$(toggle --color white)${BOLD}[LOG] $(_log_date)$*${RESET}"
}

logDebug() {
  printf "%b\n" "$(toggle --color gray)${BOLD}$(toggle --emoji bug)[DEBUG] $(_log_date)$*${RESET}"
}

logSuccess() {
  printf "%b\n" "$(toggle --color emerald)${BOLD}$(toggle --emoji check_mark_button)[SUCCESS] $(_log_date)$*${RESET}"
}

logWarn() {
  printf "%b\n" "$(toggle --color orange)${BOLD}$(toggle --emoji warning)[WARN] $(_log_date)$*${RESET}"
}

logError() {
  printf "%b\n" "$(toggle --color pink)${BOLD}$(toggle --emoji cross_mark)[ERROR] $(_log_date)$*${RESET}" >&2
}

logFatal() {
  printf "%b\n" "$(toggle --color red)${BOLD}$(toggle --emoji radioactive)[FATAL] $(_log_date)$*${RESET}" >&2
}

# -------------------------
# Contextual Logs
# -------------------------

logQuestion() {
  printf "%b\n" "$(toggle --color blue)${BOLD}$(toggle --emoji red_question_mark)[QUESTION] $(_log_date)$*${RESET}"
}

logRequest() {
  printf "%b\n" "$(toggle --color blue)${BOLD}$(toggle --emoji satellite_antenna)[REQUEST] $(_log_date)Please $*${RESET}"
}

logUpload() {
  printf "%b\n" "$(toggle --color blue)${BOLD}$(toggle --emoji outbox_tray)[UPLOAD] $(_log_date)$*${RESET}"
}

logDownload() {
  printf "%b\n" "$(toggle --color blue)${BOLD}$(toggle --emoji inbox_tray)[DOWNLOAD] $(_log_date)$*${RESET}"
}

logWait() {
  printf "%b\n" "$(toggle --color purple)${BOLD}$(toggle --emoji hourglass_not_done)[WAIT] $(_log_date)$*${RESET}"
}

logAttempt() {
  printf "%b\n" "$(toggle --color purple)${BOLD}$(toggle --emoji bullseye)[ATTEMPT] $(_log_date)$*${RESET}"
}

logChoice() {
  printf "%b\n" "$(toggle --color yellow)${BOLD}$(toggle --emoji game_die)[CHOICE] $(_log_date)$*${RESET}"
}

logGreetings() {
  printf "%b\n" "$(toggle --color violet)${BOLD}$(toggle --emoji wave)[GREETINGS] $(_log_date)$* $(toggle --emoji sparkles)${RESET}"
}

# -------------------------
# Structural Logs
# -------------------------

logLogo() {
  printf "%b" "$(toggle --color violet)"
  center_text <<< "$1"
  printf "%b\n" "${RESET}"
}

logTitle() {
  printf "\n%b\n\n" "$(toggle --color stone)${BOLD}${UNDERLINE}# $*${RESET}"
}

logHeading() {
  printf "\n%b\n" "$(toggle --color white)${BOLD}== $* ==${RESET}"
}

logParagraph() {
  printf "%b\n" "$(toggle --color neutral)$*${RESET}"
}

logLink() {
  printf "%b\n" "$(toggle --color cyan)$(toggle --emoji pushpin)${BOLD}[LINK] ${UNDERLINE}${ITALIC}$*${RESET}"
}

logCopyright() {
  local colored_text
  colored_text="$(toggle --color lime)$(toggle --emoji copyright)${ITALIC}$*${RESET}"
  center_text <<< "$colored_text"
}

logSeparator() {
  local pattern="${1:--}"
  local cols
  cols=$(tput cols 2>/dev/null || echo 80)
  local line
  line=$(printf "%${cols}s" "" | tr ' ' "$pattern")
  printf "%b\n" "$(toggle --color white)${line:0:$cols}${RESET}"
}

logBreak() {
  echo ""
}

logReturn() {
  local msg="${1:-Press Enter to return to the menu...}"
  local prompt_msg
  prompt_msg="$(toggle --color yellow)${BOLD}$(toggle --emoji return)[MENU] $(_log_date)$msg${RESET}"
  read -rp "$prompt_msg"
}
