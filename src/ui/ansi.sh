# ansi/tput helpers (posix)

ansi_init() {
  if command -v tput >/dev/null 2>&1; then
    cols="$(tput cols 2>/dev/null || printf '80')"
    lines="$(tput lines 2>/dev/null || printf '24')"
    clear="$(tput clear 2>/dev/null || printf '\033[2J\033[H')"
    bold="$(tput bold 2>/dev/null || printf '')"
    sgr0="$(tput sgr0 2>/dev/null || printf '\033[0m')"
  else
    cols="80"; lines="24"
    clear="$(printf '\033[2J\033[H')"
    bold=""; sgr0=""
  fi
  UI_COLS="$cols"; UI_LINES="$lines"; UI_CLEAR="$clear"; UI_BOLD="$bold"; UI_SGR0="$sgr0"
}

ansi_cls()   { printf '%s' "${UI_CLEAR:-$(printf '\033[2J\033[H')}"; }
ansi_goto()  { printf '\033[%s;%sH' "$1" "$2"; }  # row col (1-based)
ansi_bold()  { printf '%s' "${UI_BOLD:-}"; }
ansi_reset() { printf '%s' "${UI_SGR0:-}"; }