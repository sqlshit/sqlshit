#!/usr/bin/env sh
set -eu
# build single-file cli by concatenating modules; no platform/commit baked

version="$(cat VERSION 2>/dev/null || printf '0.0.0')"

out="dist/sqlshit"
mkdir -p dist

# header + constants
{
  printf '%s\n' '#!/usr/bin/env sh'
  printf '%s\n' 'set -eu'
  printf '%s\n' "SQLSHIT_VERSION='${version}'"
  printf '%s\n' "SQLSHIT_DEV=0"
  printf '\n'
} > "$out"

# helper to append a module with shebangs stripped
append() {
  sed -e '1{/^#!\/usr\/bin\/env[[:space:]]\+sh/d;}' \
      -e '/^set -e[ux]*$/d' \
      "$1" >> "$out"
  printf '\n' >> "$out"
}

# order matters: libs before main
append src/ui/ansi.sh
append src/ui/welcome.sh
append src/main.sh

chmod +x "$out"
printf '%s\n' "built -> $out"