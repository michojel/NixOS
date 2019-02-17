#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

interface="$1"
status="$2"

readonly HOSTNAME="$(@net-tools@/bin/hostname)"
readonly hosts_dir=/etc/hosts.d
readonly places=( "Rettigheim" )


function join() { local IFS="$1"; shift; echo "$*"; }
# a list of <address> separated with '@' where
#   <address> = $interface#$ip4_address#$ip4_gateway
declare -Ar hosts=(
  ["Rettigheim"]="$(join $'\n' \
    "192.168.0.25 mx2" \
    "192.168.0.14 devolo-powerline-miminar" \
    "192.168.0.15 minap50"
  )"
)

declare -A addresses=()

function write_hosts() {
  local place="$1"
  local addr="$2"
  (
    local hs="${hosts[$place]}"
    grep -v -F "$HOSTNAME" <<<"$hs"
    if ! grep -F -q "$addr" <<<"$hs"; then
      echo "${addr%%/*} $HOSTNAME"
    fi
  ) >"$hosts_dir/$place"
}

function main() {
  local place addr i

  case "$HOSTNAME" in
      minap50 | minap50.*)
          addresses["Rettigheim"]="$(join @ \
            "net0#192.168.0.15/24#192.168.0.1" \
            "wlp4s0#192.168.0.20/24#192.168.0.1"
          )"
          ;;
      mx2 | mx2.*)
          addresses["Rettigheim"]="net0#192.168.0.25/24#192.168.0.1"
          ;;
      *)
          echo 'unknown host "'"$HOSTNAME"'"!' >&2
          exit 1
          ;;
  esac

  if ! echo "$status" grep -q '^\(up\|down\)'; then
    exit 0
  fi

  if [[ "$status" == "down" ]]; then
    # TODO remove place only if all the other interfaces are also down
    for place in "${places[@]}"; do
      if echo "${addresses[$place]}" | grep -q "\<$interface#"; then
        rm -v "$hosts_dir/$place" || :
      fi
    done
    exit 0
  fi

  # handle up
  for place in "${places[@]}"; do
    while IFS=# read -r -u 3 iface ipv4addr gateway; do
      for ((i=0; i < "${IP4_NUM_ADDRESSES:-0}"; i++)); do
        local addr
        eval 'addr="$IP4_ADDRESS_'"$i"'"'
        addr="$(echo "$addr" | sed 's/ .*$//')"
        if [[ "$interface" == "$iface" \
           && "$addr" == "${ipv4addr}" \
           && "${IP4_GATEWAY:-}" == "$gateway" \
        ]]; then
          write_hosts "$place" "$addr"
        fi
      done
    done 3< <(echo "${addresses[$place]}" | tr '@' '\n')
  done
}

main |& systemd-cat -t "network-manager-dispatcher-$(basename "${BASH_SOURCE[0]}")"
