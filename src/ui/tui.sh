#!/usr/bin/env sh
set -eu
# interactive dashboard (no deps; uses ansi.sh)

# shared info for header
_tui_version_line() {
  v="$(cat VERSION 2>/dev/null || printf '0.0.0')"
  c="$(git rev-parse --short HEAD 2>/dev/null || printf 'dirty')"
  # platform string duplicated here to avoid importing cli helpers
  case "$(uname -s)" in
    Darwin) p='macOS' ;;
    Linux)
      if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "${ID:-}" in
          ubuntu) p='Ubuntu' ;;
          debian) p='Debian' ;;
          arch)   p='Arch Linux' ;;
          alpine) p='Alpine' ;;
          *)      p='Linux' ;;
        esac
      else p='Linux'; fi
      ;;
    *) p='Unknown OS' ;;
  esac
  if [ "${SHIT_DEV:-0}" = "1" ]; then
    printf 'sqlshit-%s-dev (%s) for %s' "$v" "$c" "$p"
  else
    printf 'sqlshit-%s (%s) for %s' "$v" "$c" "$p"
  fi
}

# metric stubs
_metric_active_conns() { printf '—'; }
_metric_qps()          { printf '—'; }
_metric_cache_hit()    { printf '—'; }
_metric_warnings()     { printf '—'; }
_metric_failed()       { printf '—'; }

_tui_draw_frame() {
  ansi_cls
  ansi_goto 1 1; ansi_rev; ansi_bold
  printf ' %-*s ' "$((UI_COLS-2))" "$(_tui_version_line)"
  ansi_reset

  ansi_goto 3 1
  printf ' Active Conns: %s    QPS: %s    Cache Hit: %s    Warnings: %s    Failed: %s\n' \
    "$(_metric_active_conns)" "$(_metric_qps)" "$(_metric_cache_hit)" "$(_metric_warnings)" "$(_metric_failed)"

  ansi_goto "$UI_LINES" 1; ansi_rev
  printf ' [F1] help  [F2] engines  [F3] backups  [Q] quit '
  pad=$((UI_COLS - 46)); [ "$pad" -gt 0 ] && printf '%*s' "$pad" ' '
  ansi_reset
}

_tui_help() {
  row=5
  ansi_goto "$row" 2;       printf 'controls:'
  ansi_goto $((row+1)) 4;   printf 'q            quit'
  ansi_goto $((row+2)) 4;   printf 'r            refresh now'
  ansi_goto $((row+3)) 4;   printf '1 / 2        switch engine (mysql / mssql)'
  ansi_goto $((row+4)) 4;   printf 'b            backups (run once)'
}

_tui_backups_once() {
  row=11
  ansi_goto "$row" 2; printf 'backups: (stub) would call a shared api, usable by cron too'
}

tui_loop() {
  if command -v stty >/dev/null 2>&1; then
    STTY_OLD="$(stty -g)"
    trap 'stty "$STTY_OLD" >/dev/null 2>&1 || true; ansi_reset; printf "\n"; exit 0' INT TERM EXIT
    stty -echo -icanon time 0 min 0 2>/dev/null || true
  fi

  while :; do
    ansi_init
    _tui_draw_frame
    _tui_help

    key=''
    IFS= read -r -n 1 key 2>/dev/null || true

    case "$key" in
      q|Q) break ;;
      r|R) : ;;
      1) : ;;    # future: set engine=mysql
      2) : ;;    # future: set engine=mssql
      b|B) _tui_backups_once ;;
      *) : ;;
    esac

    sleep 0.2
  done

  if [ -n "${STTY_OLD:-}" ]; then
    stty "$STTY_OLD" >/dev/null 2>&1 || true
  fi
  ansi_reset
  printf '\n'
}