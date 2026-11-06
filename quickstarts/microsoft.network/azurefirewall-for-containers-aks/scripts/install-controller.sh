#!/bin/bash
# Runs inside Microsoft.Resources/deploymentScripts (Azure CLI container, signed in with the script identity).
# Installs the Azure Firewall for Containers controller and applies a sample policy, attachment, and test pods.
set -euo pipefail

echo "Getting cluster credentials for ${CLUSTER_NAME}"
az aks get-credentials --resource-group "$RESOURCE_GROUP" --name "$CLUSTER_NAME" --admin --file ./kubeconfig --overwrite-existing --only-show-errors
chmod 600 ./kubeconfig
export KUBECONFIG="$PWD/kubeconfig"

download() { # url dest; the Azure CLI container image may not include curl
  if command -v curl >/dev/null 2>&1; then curl -fsSL "$1" -o "$2"
  elif command -v wget >/dev/null 2>&1; then wget -qO "$2" "$1"
  else python3 -c "import sys, urllib.request; urllib.request.urlretrieve(sys.argv[1], sys.argv[2])" "$1" "$2"
  fi
}

echo "Installing kubectl and helm"
az aks install-cli --install-location /usr/local/bin/kubectl --kubelogin-install-location /usr/local/bin/kubelogin --only-show-errors >/dev/null
download https://get.helm.sh/helm-v3.16.2-linux-amd64.tar.gz /tmp/helm.tar.gz
tar -xzf /tmp/helm.tar.gz -C /tmp
install /tmp/linux-amd64/helm /usr/local/bin/helm

echo "Installing controller ${CONTROLLER_VERSION}"
helm upgrade --install azfw-controller \
  oci://mcr.microsoft.com/firewall/charts/azurefirewall-controller \
  --namespace "$CONTROLLER_NAMESPACE" \
  --create-namespace \
  --version "$CONTROLLER_VERSION" \
  --set "azfwController.podIdentity.clientID=${CONTROLLER_CLIENT_ID}" \
  --wait --timeout 10m
kubectl wait --for=condition=Available deploy --all --namespace "$CONTROLLER_NAMESPACE" --timeout=10m
kubectl wait --for=condition=Established crd/securitypolicyattachments.firewall.networking.azure.io --timeout=5m

echo "Applying sample security policy and attachment"
kubectl apply -f - <<EOF
apiVersion: firewall.networking.azure.io/v1alpha1
kind: SecurityPolicy
metadata:
  name: example-securitypolicy-rules
  namespace: default
spec:
  applicationRuleCollections:
    - name: test-application-rules
      refs:
        - podSelector:
            matchLabels:
              role: developer
      action: Allow
      egress:
        - name: allow-test-destinations
          toPortProtocol:
            - protocolType: HTTPS
              port: 443
          to:
            - fqdn:
                - "*.microsoft.com"
                - "*.google.com"
---
apiVersion: firewall.networking.azure.io/v1alpha1
kind: SecurityPolicyAttachment
metadata:
  name: example-attachment
  namespace: default
spec:
  securityPolicyRefs:
    - name: example-securitypolicy-rules
      namespace: default
  firewallRef:
    id: ${FIREWALL_ID}
  aksWorkloadSubnets:
    - ${AKS_SUBNET_ID}
EOF

echo "Waiting for the attachment to deploy"
kubectl wait --for=jsonpath='{.status.conditions[?(@.type=="Deployment")].reason}'=Ready \
  securitypolicyattachment/example-attachment --namespace default --timeout=40m
kubectl get securitypolicyattachment example-attachment --namespace default \
  -o jsonpath='{range .status.conditions[*]}{.type}={.status} {.reason}{"\n"}{end}'

echo "Creating test pods"
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: developer-pod
  namespace: default
  labels:
    role: developer
spec:
  containers:
    - name: developer
      image: mcr.microsoft.com/azure-cli:latest
      command: ["sleep", "infinity"]
---
apiVersion: v1
kind: Pod
metadata:
  name: other-pod
  namespace: default
  labels:
    role: other
spec:
  containers:
    - name: other
      image: mcr.microsoft.com/azure-cli:latest
      command: ["sleep", "infinity"]
EOF
kubectl wait --for=condition=Ready pod/developer-pod pod/other-pod --namespace default --timeout=10m

ATTACH_STATUS=$(kubectl get securitypolicyattachment example-attachment --namespace default \
  -o jsonpath='{.status.conditions[?(@.type=="Deployment")].reason}')
cat > "$AZ_SCRIPTS_OUTPUT_PATH" <<EOF
{"controllerVersion": "${CONTROLLER_VERSION}", "attachmentDeployment": "${ATTACH_STATUS}"}
EOF
echo "Done"
