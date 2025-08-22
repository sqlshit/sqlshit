# simple welcome screen; press q to exit

_w_platform() {
  case "$(uname -s)" in
    Darwin) printf 'macOS' ;;
    Linux)
      if [ -f /etc/os-release ]; then
        . /etc/os-release
        printf '%s' "${NAME:-Linux}"
      else
        printf 'Linux'
      fi
      ;;
    *) printf 'Unknown OS' ;;
  esac
}

_w_title() {
  plat="$(_w_platform)"
  if [ "${SHIT_DEV:-0}" = "1" ]; then
    printf 'sqlshit-%s-dev (%s) for %s' "${SHIT_VERSION:-0.0.0}" "${SHIT_COMMIT:-dirty}" "$plat"
  else
    printf 'sqlshit-%s (%s) for %s' "${SHIT_VERSION:-0.0.0}" "${SHIT_COMMIT:-dirty}" "$plat"
  fi
}

welcome_draw() {
  ansi_cls
  ansi_goto 1 2; ansi_bold; printf '%s' "$(_w_title)"; ansi_reset
  ansi_goto 3 2; ansi_bold; printf 'welcome to sqlshit'; ansi_reset
  ansi_goto 5 2; printf 'press q to exit.'
}

welcome_loop() {
  if command -v stty >/dev/null 2>&1; then
    STTY_OLD="$(stty -g)"
    trap 'stty "$STTY_OLD" >/dev/null 2>&1 || true; ansi_reset; printf "\n"; exit 0' INT TERM EXIT
    stty -echo -icanon time 0 min 0 2>/dev/null || true
  fi

  while :; do
    ansi_init
    welcome_draw
    key=''
    IFS= read -r -n 1 key 2>/dev/null || true
    [ "$key" = "q" ] && break
    sleep 0.1
  done

  if [ -n "${STTY_OLD:-}" ]; then
    stty "$STTY_OLD" >/dev/null 2>&1 || true
  fi
  ansi_reset
  printf '\n'
}