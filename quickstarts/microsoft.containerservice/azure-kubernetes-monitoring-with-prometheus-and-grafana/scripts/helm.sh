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

kubectlcontent='apiVersion: v1
kind: Service
metadata:
  name: prom-pls-svc
  annotations:
    service.beta.kubernetes.io/azure-load-balancer-internal: "true" # Use an internal LB with PLS
    service.beta.kubernetes.io/azure-pls-create: "true"
    service.beta.kubernetes.io/azure-pls-name: prometheusManagedPls
    service.beta.kubernetes.io/azure-pls-resource-group: '"$RESOURCEGROUP"'
    service.beta.kubernetes.io/azure-pls-proxy-protocol: "false"
    service.beta.kubernetes.io/azure-pls-visibility: "*"
spec:
  type: LoadBalancer
  selector:
    # app: myApp
    app.kubernetes.io/name: prometheus
    prometheus: prometheus-kube-prometheus-prometheus # note that this is related to the release name
  ports:
    - name: http-web
      protocol: TCP
      port: 9090
      targetPort: 9090
'

echo "$kubectlcontent" | kubectl --namespace monitoring apply -f -

echo \{\"plsName\":\"prometheusManagedPls\"\} > $AZ_SCRIPTS_OUTPUT_PATH