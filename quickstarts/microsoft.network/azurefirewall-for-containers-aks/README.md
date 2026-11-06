---
description: This template deploys an AKS cluster, an Azure Firewall Premium with a firewall policy, and the identity and routing for Azure Firewall for Containers. Optionally, it installs the Azure Firewall Controller and a sample label-based security policy.
page_type: sample
products:
- azure
- azure-resource-manager
- azure-firewall
- azure-kubernetes-service
urlFragment: azurefirewall-for-containers-aks
languages:
- json
- bicep
---
# Azure Firewall for Containers (preview) with AKS

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/azurefirewall-for-containers-aks/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/azurefirewall-for-containers-aks/PublicDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/azurefirewall-for-containers-aks/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/azurefirewall-for-containers-aks/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/azurefirewall-for-containers-aks/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fazurefirewall-for-containers-aks%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fazurefirewall-for-containers-aks%2Fazuredeploy.json)

Azure Firewall for Containers lets you write Azure Firewall egress rules for AKS workloads by using Kubernetes labels instead of IP addresses.

This template deploys:

- A virtual network with an AKS subnet, `AzureFirewallSubnet`, and `AzureFirewallManagementSubnet`.
- An AKS cluster with Azure CNI, OIDC issuer, and workload identity.
- An Azure Firewall Premium with a firewall policy that allows the AKS required egress and HTTPS to `*.afc.azure.com`.
- A route table that sends the AKS subnet's outbound traffic (`0.0.0.0/0`) through the firewall.
- A managed identity for the Azure Firewall Controller, with Network Contributor on the resource group and a federated credential for the controller's service account.

After the deployment, install the controller and attach a policy (next section). Deployment takes about 15 minutes; attaching the first policy takes about 5 more.

## Prerequisites

- Deploy to a preview region: `centraluseuap`, `eastus2euap`, `westcentralus`, `eastasia`, `uksouth`, or `centralus`.
- The `Microsoft.ContainerService` and `Microsoft.Network` resource providers registered on the subscription.
- Permission to create role assignments (for example, Owner or User Access Administrator) on the resource group.
- Azure CLI, kubectl, and Helm for the steps after the deployment.

## Install the controller and attach a policy

```bash
RESOURCE_GROUP='<resource-group>'
FIREWALL_ID=$(az network firewall show -g "$RESOURCE_GROUP" -n afc-firewall --query id -o tsv)
AKS_SUBNET_ID=$(az network vnet subnet show -g "$RESOURCE_GROUP" --vnet-name afc-vnet -n aks-subnet --query id -o tsv)
CLIENT_ID=$(az identity show -g "$RESOURCE_GROUP" -n afc-controller-identity --query clientId -o tsv)

az aks get-credentials --resource-group "$RESOURCE_GROUP" --name afc-aks

helm install azfw-controller oci://mcr.microsoft.com/firewall/charts/azurefirewall-controller \
  --namespace firewall-namespace --create-namespace --version 20261103.2 \
  --set "azfwController.podIdentity.clientID=$CLIENT_ID" --wait

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

kubectl wait --for=jsonpath='{.status.conditions[?(@.type=="Deployment")].reason}'=Ready \
  securitypolicyattachment/example-attachment --namespace default --timeout=40m
```

## Test traffic

```bash
kubectl run developer-pod --labels=role=developer --image=mcr.microsoft.com/azure-cli:latest --command -- sleep infinity
kubectl run other-pod --labels=role=other --image=mcr.microsoft.com/azure-cli:latest --command -- sleep infinity
kubectl wait --for=condition=Ready pod/developer-pod pod/other-pod --timeout=5m

# Allowed: labeled pod to an allowed destination
kubectl exec developer-pod -- curl -sS -o /dev/null -w '%{http_code}\n' --max-time 30 https://www.microsoft.com

# Denied: destination not in the policy, and a pod without the label
kubectl exec developer-pod -- curl -sS -o /dev/null -w '%{http_code}\n' --max-time 30 https://www.bing.com
kubectl exec other-pod -- curl -sS -o /dev/null -w '%{http_code}\n' --max-time 30 https://www.microsoft.com
```

Denied HTTPS requests fail with a TLS connection error (curl exit code 35).

## Optional: one-click install

Set `deployControllerAndSample` to `true` to have a deployment script install the controller, apply the sample policy and attachment, and create the test pods:

- **Azure portal:** on the **Custom deployment** page, set **Deploy Controller And Sample** to `true`.
- **Azure CLI:** add `--parameters deployControllerAndSample=true` to `az deployment group create`.

> [!IMPORTANT]
> The deployment script creates a temporary storage account that requires shared key access. If the built-in Azure Policy **Storage accounts should prevent shared key access** (definition ID `8c6a50c6-9ffd-4ae7-986f-5fa6111f9a54`) is assigned with the **Deny** effect at the subscription, resource group, or management group, the deployment fails on the deployment script with `DeploymentScriptOperationFailed` and the message `Resource '<name>scripts' was disallowed by policy`. All other resources still deploy.

To check whether the policy applies to your subscription:

```bash
az policy assignment list --disable-scope-strict-match \
  --query "[?policyDefinitionId=='/providers/Microsoft.Authorization/policyDefinitions/8c6a50c6-9ffd-4ae7-986f-5fa6111f9a54'].{name:name, scope:scope, enforcement:enforcementMode}" -o table
```

If the policy applies, do one of the following:

- **Recommended:** keep `deployControllerAndSample` set to `false` and run the commands in [Install the controller and attach a policy](#install-the-controller-and-attach-a-policy).
- Create a policy exemption for the deployment's resource group, then redeploy. This requires the Owner or Resource Policy Contributor role at the policy assignment's scope, and your organization's approval:

  ```bash
  az policy exemption create --name allow-afc-deployment-script \
    --resource-group <resource-group> \
    --policy-assignment <policy-assignment-id> \
    --exemption-category Waiver
  ```

If the deployment script fails for this reason, the deployment shows as failed, but the cluster, firewall, identity, and routing are deployed. Continue with [Install the controller and attach a policy](#install-the-controller-and-attach-a-policy).

## Clean up

```bash
az group delete --name <resource-group> --yes --no-wait
```

`Tags: Microsoft.Network/azureFirewalls, Microsoft.Network/firewallPolicies, Microsoft.Network/firewallPolicies/ruleCollectionGroups, Microsoft.Network/virtualNetworks, Microsoft.Network/routeTables, Microsoft.Network/publicIPAddresses, Microsoft.ContainerService/managedClusters, Microsoft.ManagedIdentity/userAssignedIdentities, Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials, Microsoft.Authorization/roleAssignments, Microsoft.Resources/deploymentScripts`
