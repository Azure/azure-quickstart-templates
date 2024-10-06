#!/bin/bash
set -e

# Download and install Helm
wget -O helm.tgz https://get.helm.sh/helm-v3.15.4-linux-amd64.tar.gz
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

helm repo update

helm install $HELM_APP_NAME \
    $HELM_APP \
    --namespace monitoring \
    --create-namespace

echo "$KUBECTL_CONTENT" | kubectl --namespace monitoring apply -f -

echo \{\"plsName\":\"promManagedPls\"\} > $AZ_SCRIPTS_OUTPUT_PATH