#!/usr/bin/env bash

set -euo pipefail

ip addr add 31.31.73.95/24 dev ens3
ip route add default via 31.31.73.1
echo "nameserver 46.28.108.2" >>/etc/resolv.conf
