#!/usr/bin/env bash

set -euo pipefail

site="laskavoucestou.cz"

# shellcheck disable=SC1078
USAGE="$(basename "${BASH_SOURCE[0]}") [OPTIONS] WP_COMMAND [-- WP_OPTIONS]

Administer wordpress sites.

Options:
  -s | --site SITE
        Run wp-cli command on the given site. Defaults to \"${site}\".
  -H | --wp-help
        Run help for the wp-cli command. Is equivalent to:
           wp --help
           $(basename "${BASH_SOURCE[0]}") -- --help
"

long_options=( --site: --help --wp-help )

function join() { local IFS="$1"; shift; echo "$*"; }

TMPARGS="$(getopt -o "Hhs:" -l "$(join , "${long_options[@]}")" \
    -n "$(basename "${BASH_SOURCE[0]}")" -- "$@")"
eval set -- "${TMPARGS}"

while true; do
    case "$1" in
        -h | --help)
            printf '%s' "$USAGE"
            exit 0
            ;;
        -H | --wp-help)
            wp --help
            exit 0
            ;;
        -s | --site)
            site="$2"
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            printf 'Unknown option "%s"!\n' >&2 "$1"
            exit 1
            ;;
    esac
done

nginx_conf="$(systemctl show nginx.service | \
    sed -n 's,^ExecStart=.* -c \([[:alnum:]/._-]\+\).*,\1,p')"

if [[ -z "${nginx_conf:-}" ]]; then
    printf 'Failed to determine nginx config file path!\n' >&2
    exit 1
fi

wp_root="$(sed -n 's,^\s*root\s\+\(/nix/store[[:alnum:]/_.-]\+\).*,\1,p' \
    "$nginx_conf" | grep -F "$site" | head -n 1)"

if [[ -z "${wp_root:-}" ]]; then
    printf "Failed to determine wordpress' root directory from %s\n" \
        "$nginx_conf" >&2
    exit 1
fi

sudo -u wordpress wp --path="$wp_root" "$@"

# ex: et ts=4 sw=4 :
