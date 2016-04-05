#!/usr/bin/env bash

if [[ $# -ne 1 || -z "$1" ]]; then
    echo "Usage: ./deploy_cloudfoundry.sh <path-to-your-manifest>"
    exit 1
fi

set -e

stemcell_url=`grep azure-hyperv-ubuntu-trusty-go_agent bosh.yml | awk '{print $2}'`
bosh upload stemcell $stemcell_url
bosh upload release REPLACE_WITH_CF_RELEASE_URL

manifest=$1
bosh deployment $manifest
bosh -n deploy
