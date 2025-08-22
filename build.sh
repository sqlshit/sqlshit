#!/usr/bin/env sh
set -eu

version="$(grep -m1 'version=' src/main.sh | cut -d'"' -f2)"
commit="$(git rev-parse --short HEAD 2>/dev/null || printf 'uncommitted-shit')"

# detect platform name
case "$(uname -s)" in
    Darwin)   platform="macOS" ;;
    Linux)
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            case "$ID" in
                ubuntu)   platform="Ubuntu" ;;
                debian)   platform="Debian" ;;
                arch)     platform="Arch" ;;
                alpine)   platform="Alpine" ;;
                *)        platform="Linux" ;;
            esac
        else
            platform="Linux"
        fi
        ;;
    *) platform="Linux" ;;
esac

out="dist/sqlshit"

mkdir -p dist

# prepend version + commit info into the script
{
    printf '#!/usr/bin/env sh\n'
    printf 'SQLSHIT_VERSION="%s"\n' "$version"
    printf 'SQLSHIT_COMMIT="%s"\n' "$commit"
    printf 'SQLSHIT_PLATFORM="%s"\n' "$platform"
    cat src/main.sh
} > "$out"

chmod +x "$out"
echo "built -> $out"