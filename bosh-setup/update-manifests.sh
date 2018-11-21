#!/bin/bash

# This script is for development purpose. Run the script when upgrading the manifests of bosh-deployment and cf-deployment.

pushd manifests
  # bosh-deployment
  wget https://raw.githubusercontent.com/cloudfoundry/bosh-deployment/master/bosh.yml -O bosh.yml
  wget https://raw.githubusercontent.com/cloudfoundry/bosh-deployment/master/jumpbox-user.yml -O jumpbox-user.yml
  wget https://raw.githubusercontent.com/cloudfoundry/bosh-deployment/master/uaa.yml -O uaa.yml
  wget https://raw.githubusercontent.com/cloudfoundry/bosh-deployment/master/credhub.yml -O credhub.yml
  wget https://raw.githubusercontent.com/cloudfoundry/bosh-deployment/master/runtime-configs/dns.yml -O dns.yml
  wget https://raw.githubusercontent.com/cloudfoundry/bosh-deployment/master/azure/cpi.yml -O cpi.yml
  wget https://raw.githubusercontent.com/cloudfoundry/bosh-deployment/master/azure/custom-environment.yml -O custom-environment.yml
  wget https://raw.githubusercontent.com/cloudfoundry/bosh-deployment/master/azure/use-managed-disks.yml -O use-managed-disks.yml

  # cf-deployment
  wget https://raw.githubusercontent.com/cloudfoundry/cf-deployment/master/cf-deployment.yml -O cf-deployment.yml
  wget https://raw.githubusercontent.com/cloudfoundry/cf-deployment/master/operations/azure.yml -O azure.yml
  wget https://raw.githubusercontent.com/cloudfoundry/cf-deployment/master/operations/use-external-blobstore.yml -O use-external-blobstore.yml
  wget https://raw.githubusercontent.com/cloudfoundry/cf-deployment/master/operations/use-azure-storage-blobstore.yml -O use-azure-storage-blobstore.yml
  wget https://raw.githubusercontent.com/cloudfoundry/cf-deployment/master/operations/scale-to-one-az.yml -O scale-to-one-az.yml
  wget https://raw.githubusercontent.com/cloudfoundry/cf-deployment/master/operations/use-compiled-releases.yml -O use-compiled-releases.yml
  cp use-compiled-releases.yml use-mirror-compiled-releases.yml
  sed -i 's/storage.googleapis.com/cloudfoundry.blob.core.chinacloudapi.cn\/bosh-setup/g' use-mirror-compiled-releases.yml
popd
