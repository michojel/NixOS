#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

#LANG=c

nameservers=()
entries=()

function join() { local IFS="$1"; shift; echo "$*"; }

function mk_entries_for_sources() {
    local nameserver="$1"
    # a list of domains to search separated with /
    local domains="${2:-}"
    # a list of sources separated by ,
    local sources="${3:-}"
    local prefix=""

    [[ -z "${nameserver:-}" ]] && return 0
    [[ -n "${domains:-}" ]] && prefix="/${domains}/"

    if [[ -z "${sources:-}" ]]; then
        printf '%s%s\n' "${prefix:-}" "${nameserver}"
        return 0
    fi

    readarray -t -d , srcarr <<<"${sources}"
    for source in "${srcarr[@]}"; do
        printf '%s%s@%s\n' "${prefix:-}" "${nameserver}" "${source}"
    done
}

function rm_space() { printf '%s\n' "${1:-}" | tr -d '[:space:]'; }

function mk_prefix() {
    local ip="$1"
    local mask="$2"
    local bin="$(ipcalc "$ip" "$mask" | \
        sed -n 's/^Network:\s\+\S\+\s\+\(\S\+\) \([0-1]\+\)/\1\2/p' | \
        sed 's/\.[0.]\+$//')"
    local octets
    local decimals=()
    readarray -t -d '.' octets <<<"$bin"
    for ((i=0; i < "${#octets[@]}"; i++)); do
        local octet="$(rm_space "${octets[$i]}")"
        if [[ "${#octet}" -lt 8 ]]; then
            octet+="$(printf '0%.0s' $(seq $((8 - "${#octet}"))))"
        fi
        decimals+=( "$(printf 'ibase=2; %s\n' "${octet}" | bc | tr -d '\n')" )
    done
    join . "${decimals[@]}"
}

function mk_addr_arpa() {
    local ip="$1"
    local mask="$2"
    printf '%s.' "$(mk_prefix "$ip" "$mask")" | tac -s.
    printf 'in-addr.arpa\n'
}

function mk_rev_entries_for_routes() {
    local nameserver="$1"
    # a list of routes separated by ,
    local routes="${2:-}"
    # a list of sources separated by ,
    local sources="${3:-}"
    local route

    [[ -z "${nameserver:-}" ]]  && return 0
    [[ -z "${routes:-}" ]]      && return 0

    readarray -t -d , routarr <<<"${routes}"
    local domains=()
    for route in "${routarr[@]}"; do
        route="$(rm_space "${route:-}")"
        route="$(echo "$route" | sed -e 's/^\s\+//' -e 's/\s\+$//')"
        [[ -z "${route:-}" || "${route}" =~ /(0|32)$ ]] && continue
        domains+=( "$(mk_addr_arpa "${route%/*}" "${route#*/}")" )
    done

    local prefix="/$(join / "${domains[@]}")/"
    if [[ -z "${sources:-}" ]]; then
        printf '%s%s\n' "${prefix}" "${nameserver}"
        return 0
    fi

    readarray -t -d , srcarr <<<"${sources:-}"
    for source in "${srcarr[@]}"; do
        printf '%s%s@%s\n' "${prefix}" "${nameserver}" "$(rm_space "${source}")"
    done
}

function mk_entries_for_nameserver() {
    local type="$1"
    local device="$2"
    local isdefault="$3"
    local nameserver="$4"
    # a list of domains to search separated with /
    local domains="$5"
    local routes="${6:-}"
    local addr

    local prefix=""
    [[ -z "${nameserver:-}" ]] && return
    local sources=( "$device" )
    if [[ "${type}" == "vpn" ]]; then
        sources=()
        # VPN's device is parent device, not tun
        readarray -t ipv4addresses <<<"$(printf '%s\n' "${details:-}" | \
            sed -n 's,.*ADDRESS\[[0-9]\+\]:\s\+\([^/]\+\).*,\1,p')"
        if [[ "${#ipv4addresses[@]}" -gt 0 ]]; then
            for addr in "${ipv4addresses[@]}"; do
                [[ -z "${addr:-}" ]] && continue
                sources+=( "${addr}" )
            done
        fi
    fi

    if [[ "${isdefault}" == 1 ]]; then
        mk_entries_for_sources "${nameserver}" "" "$(join , "${sources[@]}")"
        #if [[ -z "${domains:-}" ]]; then
        return 0
        #fi
        # additionally, make entries for the given domains
    fi

    local sourcesargs="$(join / "${sources[@]}")"
    mk_entries_for_sources "${nameserver}" "${domains}" "${sourcesargs}"
    mk_rev_entries_for_routes "${nameserver}" "${routes:-}" "${sourcesargs}"
}

while read -u 3 -r c; do
    IFS=: read name uuid type device <<<"${c:-}"
    details="$(nmcli c show uuid "${uuid}")"
    isdefault="$(printf '%s\n' "${details:-}" | grep -qi 'GENERAL.DEFAULT:\s\+yes$' && \
        printf 1 || printf 0)"
    readarray -t dnss <<<"$(printf '%s\n' "${details:-}" | \
        sed -n -e 's/^IP4.DNS\[[0-9]\+\]:\s\+\(.\+\)/\1/p' \
               -e 's/^ipv\?4\.dns:\s\+\(.\+\)/\1/p' | grep -v -- -- | sort -u)"
    [[ "${#dnss[@]}" == 0 ]] && continue
    readarray -t domains <<<"$(printf '%s\n' "${details:-}" | \
        sed -n 's/^[iI][pP]v\?4\.\(DOMAIN\[[0-9]\+\]\|dns-search\):\s\+\(.\+\)/\2/p' | \
        tr ',' '\n' | grep -v -- -- | sort -u)"
    readarray -t routes <<<"$(printf '%s\n' "${details:-}" | \
        sed -n 's/^IP4.ROUTE\[[0-9]\+\]:\s\+dst\s*=\s*\([^,]\+\).*/\1/p' | sort -u)"

    for nameserver in "${dnss[@]}"; do
        entries+=( $(mk_entries_for_nameserver "$type" "$device" "$isdefault" "$nameserver" \
            "${domains:-}" "$(join , "${routes[@]}")") )
    done
done 3< <(nmcli -t c show --active)

sudo dbus-send --system --dest=uk.org.thekelleys.dnsmasq --print-reply=literal \
    /uk/org/thekelleys/dnsmasq \
    uk.org.thekelleys.SetDomainServers \
    'array:string:'"$(join "," "${entries[@]}")"
