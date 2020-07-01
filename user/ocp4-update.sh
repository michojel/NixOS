#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

desiredRelease="${1:-4.4}"
root="$(dirname "${BASH_SOURCE[0]}")"

_bodyCache=""

command -v sponge || nix-env -iA nixpkgs.moreutils
command -v jq     || nix-env -iA nixpkgs.jq

function join() { local IFS="${1:-}"; shift 1; echo "$*"; }
function buildURL() {
    local minorRelease="${1:-$desiredRelease}"
    shift
    join "/" "https://mirror.openshift.com/pub/openshift-v4/clients/ocp" \
        "stable-${minorRelease}" \
        "$@"
}

function getBody() {
    if [[ -n "${_bodyCache:-}" ]]; then
        printf '%s' "${_bodyCache}"
        return 0
    fi
    _bodyCache="$(curl -L "$(buildURL "${desiredRelease}")" | sed -n '/<body>/,$p')"
    printf '%s' "${_bodyCache}"
}

function getLatestAvailableRelease() {
    local body
    body="$(getBody)"
    sed -n "s/.*openshift-client-linux-\(${desiredRelease//./\\.}\.[0-9]\+\)\.\(tar\.\|zip\|7z\).*/\1/p" \
		<<<"${body}" | head -n 1
}

function fetchBinType() {
    local binType="$1"
    local release="$2"
    local fn="openshift-$binType-linux-$release.tar.gz"
    local hash path lines=()
    readarray -t lines <<<"$(nix-prefetch-url "$(buildURL "$desiredRelease" "$fn")" 2>&1)"
    hash="${lines[-1]}"
    path="$(sed -n "s/.*'\([^']\+\).*/\1/p" <<<"${lines[-2]}")"
    join " " "${hash}" "$fn" "$path"
}

_hashesCache=""
function verifyHash() {
    local hash="$1"
    local fn="$2"
    local path="${3:-}"
    if [[ -z "${_hashesCache:-}" ]]; then
        _hashesCache="$(curl -L "$(buildURL "$desiredRelease" "sha256sum.txt")")"
    fi
    local expectedHash
    expectedHash="$(sed -n "s/^\([^[:space:]]\+\)\s\+${fn//./\\.}\$/\1/p" <<<"$_hashesCache" ||:)"
    if [[ -z "${expectedHash:-}" ]]; then
        printf 'No hash found for file %s\n' "$fn"
        return 1
    fi
    if [[ -n "${path:-}" ]]; then
        hash="$(sha256sum "${path}" | awk '{print $1}')"
    fi
    if [[ "$expectedHash" != "$hash" ]]; then
        printf 'Hashes do not match for file %s! Expected: "%s", got: "%s"\n' \
            "$fn" "$expectedHash" "$hash"
        return 1
    fi
}

set -x
latestRecorded="$(jq -r 'keys[]' <"${root}/ocp4-releases.json" | \
    grep "^$desiredRelease" | sort -V | tail -n 1 ||: )"
latestAvailable="$(getLatestAvailableRelease)"

if [[ "$(printf '%s\n' "$latestRecorded" "$latestAvailable" | sort -V | tail -n 1)" == \
        "$latestRecorded" ]];
then
    printf 'The latest available (%s) is already recorded.\n' "$latestAvailable"
    exit 0
fi

IFS=' ' read -r clientHash clientFileName clientPath <<<"$(fetchBinType client "$latestAvailable")"
verifyHash "$clientHash"  "$clientFileName" "$clientPath"
IFS=' ' read -r installHash installFileName installPath <<<"$(fetchBinType install "$latestAvailable")"
verifyHash "$installHash"  "$installFileName" "$installPath"
# TODO: verify signatures

jq --sort-keys '.["'"$latestAvailable"'"] |= {
    "client": "'"$clientHash"'",
    "install": "'"$installHash"'"
} | .latest["'"$desiredRelease"'"] |= "'"$latestAvailable"'"' <"$root/ocp4-releases.json" | \
    sponge "$root/ocp4-releases.json"

sed -i.bak 's/\(version[[:space:]]\+?[[:space:]]\+"\)[0-9]\+[^"]\+"/\1'"$latestAvailable"'"/' \
    "$root/ocp4.nix"
#nix-env -iA nixpkgs.ocp4.openshift-{client,install}

git add "$root/ocp4-releases.json" "$root/ocp4.nix"
git commit -vsm "user: updated OCP4 binaries to $latestAvailable"
