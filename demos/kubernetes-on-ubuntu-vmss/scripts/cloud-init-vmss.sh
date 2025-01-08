#!/bin/bash
# -------

# install docker & kubeadm - ubuntu
# ---------------------------------

KUBEADM_TOKEN='8f07c4.2fa8f9e48b6d4036'
KUBE_VERSION='1.17.3-00' # specify version of kubeadm, kubelet and kubectl

# setup params given to sh script
CLIENT_ID=$1
CLIENT_SECRET=$2
RESOURCE_GROUP=$3
SUB=$4
TENANT=$5
RG_LOCATION=$6
SUBNET_NAME=$7
VNET_NAME=$8

export DEBIAN_FRONTEND=noninteractive
export HOME=/root

installDeps() {
    # update and upgrade packages
    apt-get update && apt-get upgrade -y

    # install docker
    apt-get install -y docker.io

    # install kubeadm
    apt-get install -y apt-transport-https
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list

    apt-get update
    apt-get install -y kubelet=${KUBE_VERSION} kubeadm=${KUBE_VERSION} kubectl=${KUBE_VERSION}
}

createConfigFiles() {
    # Write a sample provider JSON (This won't work but values are needed in the fields)
cat >/etc/kubernetes/azure.json <<EOL
{
    "cloud":"AzurePublicCloud",
    "tenantId": "${TENANT}",
    "subscriptionId": "${SUB}",
    "aadClientId": "${CLIENT_ID}",
    "aadClientSecret": "${CLIENT_SECRET}",
    "resourceGroup": "${RESOURCE_GROUP}",
    "location": "${RG_LOCATION}",
    "vmType": "vmss",
    "subnetName": "${SUBNET_NAME}",
    "securityGroupName": "",
    "vnetName": "${VNET_NAME}",
    "vnetResourceGroup": "${RESOURCE_GROUP}",
    "routeTableName": "",
    "primaryAvailabilitySetName": "",
    "primaryScaleSetName": "",
    "cloudProviderBackoffMode": "v1",
    "cloudProviderBackoff": false,
    "cloudProviderBackoffRetries": 6,
    "cloudProviderBackoffExponent": 1.5,
    "cloudProviderBackoffDuration": 5,
    "cloudProviderBackoffJitter": 1,
    "cloudProviderRatelimit": true,
    "cloudProviderRateLimitQPS": 10,
    "cloudProviderRateLimitBucket": 100,
    "cloudProviderRatelimitQPSWrite": 10,
    "cloudProviderRatelimitBucketWrite": 100,
    "useManagedIdentityExtension": false,
    "userAssignedIdentityID": "",
    "useInstanceMetadata": true,
    "loadBalancerSku": "Basic",
    "disableOutboundSNAT": false,
    "excludeMasterFromStandardLB": false,
    "providerVaultName": "",
    "maximumLoadBalancerRuleCount": 250,
    "providerKeyName": "k8s",
    "providerKeyVersion": ""
}
EOL

# kubeadm - agent nodes
# ---------------------
# create kubeadm config on disk

cat >/etc/kubeadm-join.yaml <<EOL
kind: JoinConfiguration
apiVersion: kubeadm.k8s.io/v1beta2
caCertPath: /etc/kubernetes/pki/ca.crt
discovery:
  bootstrapToken:
    apiServerEndpoint: 10.0.1.4:6443
    token: ${KUBEADM_TOKEN}
    unsafeSkipCAVerification: true
  timeout: 5m0s
  tlsBootstrapToken: ${KUBEADM_TOKEN}
nodeRegistration:
  kubeletExtraArgs:
    cloud-config: /etc/kubernetes/azure.json
    cloud-provider: azure
  criSocket: /var/run/dockershim.sock
  taints: null
EOL

}

joinKubeadm() {
    # initialize agent node
    kubeadm join --config /etc/kubeadm-join.yaml
}

installDeps
createConfigFiles
joinKubeadm