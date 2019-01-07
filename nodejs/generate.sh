#!/usr/bin/env nix-shell
#! nix-shell -i bash -p nodePackages.node2nix

set -eu -o pipefail

rm -f node-env.nix
node2nix --nodejs-10 -i node-packages-v10.json -o node-packages-v10.nix -c composition-v10.nix
