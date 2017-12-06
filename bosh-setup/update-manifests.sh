#!/bin/bash

# This script is for development purpose. Run the script when upgrading the manifests of bosh-deployment and cf-deployment.

# bosh-deployment
wget https://raw.githubusercontent.com/cloudfoundry/bosh-deployment/master/bosh.yml -O manifests/bosh.yml
wget https://raw.githubusercontent.com/cloudfoundry/bosh-deployment/master/jumpbox-user.yml -O manifests/jumpbox-user.yml
wget https://raw.githubusercontent.com/cloudfoundry/bosh-deployment/master/azure/cpi.yml -O manifests/cpi.yml
wget https://raw.githubusercontent.com/cloudfoundry/bosh-deployment/master/azure/custom-environment.yml -O manifests/custom-environment.yml
wget https://raw.githubusercontent.com/cloudfoundry/bosh-deployment/master/azure/use-managed-disks.yml -O manifests/use-managed-disks.yml

# cf-deployment
wget https://raw.githubusercontent.com/cloudfoundry/cf-deployment/master/cf-deployment.yml -O manifests/cf-deployment.yml
wget https://raw.githubusercontent.com/cloudfoundry/cf-deployment/master/operations/azure.yml -O manifests/azure.yml
wget https://raw.githubusercontent.com/cloudfoundry/cf-deployment/master/operations/use-azure-storage-blobstore.yml -O manifests/use-azure-storage-blobstore.yml
wget https://raw.githubusercontent.com/cloudfoundry/cf-deployment/master/operations/scale-to-one-az.yml -O manifests/scale-to-one-az.yml
