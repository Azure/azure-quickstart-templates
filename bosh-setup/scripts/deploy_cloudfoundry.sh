#!/usr/bin/env bash

source utils.sh

if [[ $# -ne 1 || -z "$1" ]]; then
    echo "Usage: ./deploy_cloudfoundry.sh <path-to-your-manifest>"
    exit 1
fi

manifest=$1
default_password="c1oudc0w"

while true; do
  read -p "Enter a password(note: password should not contain special characters: @,' and so on) to use in $manifest [$default_password]:" password
  password=${password:-$default_password}
  read -p "Please double check your password [$password]. Type yes to continue:" ret
  if [ "$ret" == "yes" ]; then
    break
  fi
done

password=$(echo $password | sed 's/\//\\\//g')
password=${password:-$default_password}
sed -i "s/REPLACE_WITH_PASSWORD/$password/g" $manifest

# Upload stemcell and releases
# 1. For single-vm-cf.yml, cf-release version will not be updated, it will use v238 for a long time.
#    Other releases for diego, garden, and so on will keep a workable version accordingly.
# 2. For multiple-vm-cf.yml, we will try our best to keep the releases up-to-date.
#
if [[ $manifest == *"single"* ]]
then
  retryop "bosh upload stemcell REPLACE_WITH_STATIC_STEMCELL_URL --sha1 REPLACE_WITH_STATIC_STEMCELL_SHA1 --skip-if-exists"
  retryop "bosh upload release REPLACE_WITH_STATIC_CF_RELEASE_URL --sha1 REPLACE_WITH_STATIC_CF_RELEASE_SHA1 --skip-if-exists"
  retryop "bosh upload release REPLACE_WITH_STATIC_DIEGO_RELEASE_URL --sha1 REPLACE_WITH_STATIC_DIEGO_RELEASE_SHA1 --skip-if-exists"
  retryop "bosh upload release REPLACE_WITH_STATIC_GARDEN_RELEASE_URL --sha1 REPLACE_WITH_STATIC_GARDEN_RELEASE_SHA1 --skip-if-exists"
  retryop "bosh upload release REPLACE_WITH_STATIC_CFLINUXFS2_RELEASE_URL --sha1 REPLACE_WITH_STATIC_CFLINUXFS2_RELEASE_SHA1 --skip-if-exists"
else
  retryop "bosh upload stemcell REPLACE_WITH_DYNAMIC_STEMCELL_URL --sha1 REPLACE_WITH_DYNAMIC_STEMCELL_SHA1 --skip-if-exists"
  retryop "bosh upload release REPLACE_WITH_DYNAMIC_CF_RELEASE_URL --sha1 REPLACE_WITH_DYNAMIC_CF_RELEASE_SHA1 --skip-if-exists"
  retryop "bosh upload release REPLACE_WITH_DYNAMIC_DIEGO_RELEASE_URL --sha1 REPLACE_WITH_DYNAMIC_DIEGO_RELEASE_SHA1 --skip-if-exists"
  retryop "bosh upload release REPLACE_WITH_DYNAMIC_GARDEN_RELEASE_URL --sha1 REPLACE_WITH_DYNAMIC_GARDEN_RELEASE_SHA1 --skip-if-exists"
  retryop "bosh upload release REPLACE_WITH_DYNAMIC_CFLINUXFS2_RELEASE_URL --sha1 REPLACE_WITH_DYNAMIC_CFLINUXFS2_RELEASE_SHA1 --skip-if-exists"
fi


bosh deployment $manifest
bosh -n deploy
