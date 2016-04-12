#!/usr/bin/env bash

if [[ $# -ne 1 || -z "$1" ]]; then
    echo "Usage: ./deploy_cloudfoundry.sh <path-to-your-manifest>"
    exit 1
fi

set -e

bosh upload stemcell REPLACE_WITH_STEMCELL_URL --skip-if-exists
bosh upload release REPLACE_WITH_CF_RELEASE_URL --skip-if-exists

manifest=$1
bosh deployment $manifest
bosh -n deploy
