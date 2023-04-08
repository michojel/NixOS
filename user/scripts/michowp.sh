#!/usr/bin/env bash

set -euo pipefail

#site="${1:-laskavoucestou.cz}"
site="laskavoucestou.cz"

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
