#!/usr/bin/env bash

if [[ $# -ne 1 || -z "$1" ]]; then
    echo "Usage: ./deploy_cloudfoundry.sh <path-to-your-manifest>"
    exit 1
fi

set -e

manifest=$1
default_password="c1oudc0w"

while true; do
  read -p "Enter a password to use in $manifest [$default_password]:" password
  password=${password:-$default_password}
  read -p "Please double check your password [$password]. Type yes to continue:" ret
  if [ "$ret" == "yes" ]; then
    break
  fi
done

password=$(echo $password | sed 's/\//\\\//g')
password=${password:-$default_password}
sed -i "s/REPLACE_WITH_PASSWORD/$password/g" $manifest

bosh upload stemcell REPLACE_WITH_STEMCELL_URL --sha1 REPLACE_WITH_STEMCELL_SHA1 --skip-if-exists
bosh upload release REPLACE_WITH_CF_RELEASE_URL --sha1 REPLACE_WITH_CF_RELEASE_SHA1 --skip-if-exists
bosh upload release REPLACE_WITH_DIEGO_RELEASE_URL --sha1 REPLACE_WITH_DIEGO_RELEASE_SHA1 --skip-if-exists
bosh upload release REPLACE_WITH_GARDEN_RELEASE_URL --sha1 REPLACE_WITH_GARDEN_RELEASE_SHA1 --skip-if-exists
bosh upload release REPLACE_WITH_CFLINUXFS2_RELEASE_URL --sha1 REPLACE_WITH_CFLINUXFS2_RELEASE_SHA1 --skip-if-exists

bosh deployment $manifest
bosh -n deploy
