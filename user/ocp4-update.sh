#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

desiredRelease="${1:-4.6}"
root="$(dirname "${BASH_SOURCE[0]}")"

_bodyCache=""

command -v sponge || nix-env -iA nixpkgs.moreutils
command -v jq     || nix-env -iA nixpkgs.jq

function join() { local IFS="${1:-}"; shift 1; echo "$*"; }
function buildURL() {
    local release="${1:-stable}"
    local minorRelease="${2:-$desiredRelease}"
    shift 2
    case "$release" in
        dev-preview)
            join "/" "https://mirror.openshift.com/pub/openshift-v4/clients/ocp-dev-preview" \
                "latest-${minorRelease}" "$@"
            ;;
        *)
            join "/" "https://mirror.openshift.com/pub/openshift-v4/clients/ocp" \
                "$release-${minorRelease}" "$@"
            ;;
    esac
}

function getBody() {
    local release="${1:-stable}"
    if [[ -n "${_bodyCache:-}" ]]; then
        printf '%s' "${_bodyCache}"
        return 0
    fi
    _bodyCache="$(curl -L "$(buildURL "$release" "${desiredRelease}")" | sed -n '/<body>/,$p')"
    printf '%s' "${_bodyCache}"
}

function getLatestAvailableRelease() {
    local body
    local release="${1:-stable}"
    body="$(getBody "$release")"
    local latestFound="$(sed -n "s/.*openshift-client-linux-\(${desiredRelease//./\\.}\.[0-9]\+\)\.\(tar\.\|zip\|7z\).*/\1/p" \
        <<<"${body}" | head -n 1)"
    if [[ -n "${latestFound:-}" ]]; then
        printf '%s' "$latestFound"
        return 0
    fi
    if [[ "$release" != "latest" ]]; then
        printf 'Failed to find the latest version for %s release!\n' "$release"
        return 1
    fi
    body="$(getBody "dev-preview")"
    sed -n 's/.*openshift-client-linux-\('"${desiredRelease//./\\.}"'\.[^[:space:]">]\+\)\.\(tar\.\|zip\|7z\).*/\1/p' \
        <<<"${body}" | head -n 1
}

function fetchBinType() {
    local binType="$1"
    local release="$2"
    local releaseVersion="$3"
    local fn="openshift-$binType-linux-$releaseVersion.tar.gz"
    local hash path lines=()
    readarray -t lines <<<"$(nix-prefetch-url \
        "$(buildURL "$release" "$desiredRelease" "$fn")" 2>&1)"
    hash="${lines[-1]}"
    path="$(sed -n "s/.*'\([^']\+\).*/\1/p" <<<"${lines[-2]}")"
    join " " "${hash}" "$fn" "$path"
}

_hashesCache=""
function verifyHash() {
    local hash="$1"
    local release="$2"
    local fn="$3"
    local path="${4:-}"
    if [[ -z "${_hashesCache:-}" ]]; then
        _hashesCache="$(curl -L "$(buildURL "$release" "$desiredRelease" "sha256sum.txt")")"
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

modified=0
for release in latest stable; do
    set -x
    latestAvailable="$(getLatestAvailableRelease "$release")"

    if [[ -z "${latestAvailable:-}" ]]; then continue; fi
    if grep -q nightly <<<"$latestAvailable"; then
        release=dev-preview
    fi
    if [[ "$(jq -r '(.["'"$release"'"] // {})["'"$desiredRelease"'"]' \
        <"${root}/ocp4-releases.json")" == "$latestAvailable" ]];
    then
        printf 'The newest available %s release (%s) is already recorded.\n' "$release" \
        "$latestAvailable"
        if [[ "$release" == dev-preview ]]; then
            break
        fi
        continue
    fi

    if [[ "$(jq -r '.["'"$latestAvailable"'"]' <"${root}/ocp4-releases.json")" == "null" ]]; then
        IFS=' ' read -r clientHash clientFileName clientPath \
            <<<"$(fetchBinType client "$release" "$latestAvailable")"
        verifyHash "$clientHash" "$release"  "$clientFileName" "$clientPath"
        IFS=' ' read -r installHash installFileName installPath \
            <<<"$(fetchBinType install "$release" "$latestAvailable")"
        verifyHash "$installHash" "$release" "$installFileName" "$installPath"
        # TODO: verify signatures

        jq --sort-keys '.["'"$latestAvailable"'"] |= {
            "client": "'"$clientHash"'",
            "install": "'"$installHash"'"
        }' <"$root/ocp4-releases.json" | sponge "$root/ocp4-releases.json"
    fi

    jq '.["'"$release"'"]["'"$desiredRelease"'"] |= "'"$latestAvailable"'"' \
        <"$root/ocp4-releases.json" | sponge "$root/ocp4-releases.json"

    sed -i.bak 's/\(version[[:space:]]\+?[[:space:]]\+"\)[0-9]\+[^"]\+"/\1'"$latestAvailable"'"/' \
        "$root/ocp4.nix"
    modified=1
    if [[ "$release" == dev-preview ]]; then
        break
    fi
done
#nix-env -iA nixpkgs.ocp4.openshift-{client,install}

if [[ "$modified" == 0 ]]; then
    exit 0
fi

git add "$root/ocp4-releases.json" "$root/ocp4.nix"
git commit -vsm "user: updated OCP4 binaries to $latestAvailable"
