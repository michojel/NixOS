#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

interface="$1"
status="$2"

readonly hosts_dir=/etc/hosts.d
readonly places=( "Rettigheim" )
# a list of <address> separated with '@' where
#   <address> = $interface#$ip4_address#$ip4_gateway
declare -Ar addresses=(
  ["Rettigheim"]="net0#192.168.0.15/24#192.168.0.1"
)
declare -Ar hosts=(
  ["Rettigheim"]="
    192.168.0.25 mx2
    192.168.0.15 minap50
  "
)

function write_hosts() {
  local place="$1"
  cat >"$hosts_dir/$place" <<<"$(echo "${hosts[$place]}")"
}

(
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

  # up
  for place in "${places[@]}"; do
    while IFS=# read -r -u 3 iface ipv4addr gateway; do
      for ((i=0; i < "${IP4_NUM_ADDRESSES:-0}"; i++)); do
        eval 'addr="$IP4_ADDRESS_'"$i"'"'
        if [[ "$interface" == "$iface" \
           && "$(echo "$addr" | sed 's/ .*$//')" == "${ipv4addr}" \
           && "${IP4_GATEWAY:-}" == "$gateway" \
        ]]; then
          write_hosts "$place"
        fi
      done
    done 3< <(echo "${addresses[$place]}" | tr '@' '\n')
  done
) |& systemd-cat -t "network-manager-dispatcher-$(basename "${BASH_SOURCE[0]}")"
