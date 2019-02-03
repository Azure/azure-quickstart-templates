#!/usr/bin/env bash

if [[ $# -ne 1 || -z "$1" ]]; then
    echo "Usage: ./update-china-storage-account.sh <template-version>. For example: ./update-china-storage-account.sh v1-0-0"
    exit 1
fi

set -e

# The template version should be same as variables('templateVersion') in azuredeploy.json
template_version="$1"
container_name="bosh-setup"

# Upload CPI release
release_name="bosh-azure-cpi-release-35.5.0.tgz"
wget https://bosh.io/d/github.com/cloudfoundry/bosh-azure-cpi-release?v=35.5.0 -O /tmp/${release_name}
az storage blob upload -f /tmp/${release_name} -c ${container_name} -n cpi-releases/${release_name}
rm /tmp/${release_name}

# Upload Stemcell
stemcell_name="bosh-stemcell-170.3-azure-hyperv-ubuntu-xenial-go_agent.tgz"
wget https://s3.amazonaws.com/bosh-core-stemcells/azure/${stemcell_name} -O /tmp/${stemcell_name}
az storage blob upload -f /tmp/${stemcell_name} -c ${container_name} -n bosh-azure-stemcells/${stemcell_name}
rm /tmp/${stemcell_name}

# Upload DNS release
release_name="bosh-dns-release-1.10.0.tgz"
wget https://bosh.io/d/github.com/cloudfoundry/bosh-dns-release?v=1.10.0 -O /tmp/${release_name}
az storage blob upload -f /tmp/${release_name} -c ${container_name} -n dns-releases/${release_name}
rm /tmp/${release_name}

# Upload releases
pushd manifests
  file_names="bosh.yml uaa.yml credhub.yml"
  for file_name in ${file_names}
  do
    release_urls=$(grep "s3.amazonaws.com" ${file_name} | awk '{print $2}')
    for release_url in ${release_urls}
    do
      release_url=$(sed -e 's/^"//' -e 's/"$//' <<< $release_url)
      IFS='/ ' read -r -a array <<< "$release_url"
      release_name=${array[-1]}
      wget ${release_url} -O /tmp/${release_name}
      az storage blob upload -f /tmp/${release_name} -c ${container_name} -n bosh-compiled-release-tarballs/${release_name}
      rm /tmp/${release_name}
    done
  done

  file_names="use-compiled-releases.yml"
  for file_name in ${file_names}
  do
    release_urls=$(grep "storage.googleapis.com" ${file_name} | awk '{print $2}')
    for release_url in ${release_urls}
    do
      release_url=$(sed -e 's/^"//' -e 's/"$//' <<< $release_url)
      IFS='/ ' read -r -a array <<< "$release_url"
      release_name=${array[-1]}
      wget ${release_url} -O /tmp/${release_name}
      az storage blob upload -f /tmp/${release_name} -c ${container_name} -n cf-deployment-compiled-releases/${release_name}
      rm /tmp/${release_name}
    done
  done
popd

directories="scripts manifests"
for directory in $directories; do
  for file in $directory/*; do
    if [[ -f $file ]]; then
      az storage blob upload -f $file -c ${container_name} -n ${template_version}/$file
    fi
  done
done

bosh_cli_version="5.2.2"
bosh_cli_name="bosh-cli-${bosh_cli_version}-linux-amd64"
wget https://s3.amazonaws.com/bosh-cli-artifacts/${bosh_cli_name} -O /tmp/${bosh_cli_name}
az storage blob upload -f /tmp/${bosh_cli_name} -c ${container_name} -n bosh-cli/${bosh_cli_name}

cf_cli_version="6.39.0"
cf_cli_name="cf-cli-installer_${cf_cli_version}_x86-64.deb"
wget https://s3-us-west-1.amazonaws.com/cf-cli-releases/releases/v${cf_cli_version}/${cf_cli_name} -O /tmp/${cf_cli_name}
az storage blob upload -f /tmp/${cf_cli_name} -c ${container_name} -n cf-cli/${cf_cli_name}
