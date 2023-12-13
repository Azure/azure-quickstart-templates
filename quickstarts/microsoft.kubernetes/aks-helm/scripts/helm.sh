#!/bin/bash
set -e

# Download and install Helm
wget -O helm.tgz https://get.helm.sh/helm-v3.4.1-linux-amd64.tar.gz
tar -zxvf helm.tgz
mv linux-amd64/helm /usr/local/bin/helm
# Install kubectl
az aks install-cli

# Get cluster credentials
az aks get-credentials -g $RESOURCEGROUP -n $CLUSTER_NAME

# Install Simple Helm Chart https://github.com/bitnami/azure-marketplace-charts

helm repo add \
    $HELM_REPO \
    $HELM_REPO_URL

helm search repo \
    $HELM_REPO

helm install \
    $HELM_APP_NAME \
    $HELM_APP \
    --set global.imagePullSecrets={emptysecret}

echo \{\"Status\":\"Complete\"\} > $AZ_SCRIPTS_OUTPUT_PATH
