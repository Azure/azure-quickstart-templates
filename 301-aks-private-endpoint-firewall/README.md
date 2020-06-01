# AKS private link with Azure firewall scenario

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/301-aks-private-endpoint-firewall/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/301-aks-private-endpoint-firewall/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/301-aks-private-endpoint-firewall/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/301-aks-private-endpoint-firewall/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/301-aks-private-endpoint-firewall/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/301-aks-private-endpoint-firewall/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F301-aks-private-endpoint-firewall%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F301-aks-private-endpoint-firewall%2Fazuredeploy.json)    


### Overview

This solution deploys an AKS cluster with a private IP for the API server endpoint using Private Link.

The following resources are deployed as part of this solution

- Hub Virtual Network (10.0.0.0/16)
  - GatewaySubnet (10.0.0.0/24)
  - AzureFirewallSubnet (10.0.1.0/24)
  - ManagementSubnet (10.0.2.0/24)
- Spoke Virtual Network(10.1.0.0/16)
  - AKSSubnet (10.1.0.0/24)
- Virtual Network peering between hub and spoke virtual networks
- Azure Private Link endpoint for AKS
- Linux VM with private IP
- Azure Firewall
  - Inbound DNAT rule to allow access to the Linux VM from the internet on port 22
- Azure Monitor workspace for AKS container insights data

### Prerequisites
- Create an AAD group to use for RBAC admin access to the AKS cluster
  - obtain the objectId of the group & use it as the ARM template deployment's 'aadAdminGroupObjectIds' parameter value
  - add your AAD identity as a member of this group

### Scenario Deployment Validation

To validate that the AKS API service's private IP is accessibile from the Linux VM.
- SSH to the Azure Firewall public IP returned as output from the ARM deployment
  - `$ ssh localadmin@<Azure Firewall public IP>`
- Install kubectl & az-cli tools
  - `$ curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl`
  - `$ curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash`
- Get the Kubernetes config file
  - `$ az login`
  - `$ az account set --subscription <your azure subscription id>`
  - `$ az aks get-credentials -g <aks resource group name> -n <aks cluster name> --admin`
- Test access by listing the current nodes & pods in the cluster
  - `$ kubectl get nodes`
  - `$ kubectl get pod -A`
