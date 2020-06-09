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
  - Inbound Destination NAT (DNAT) rule to allow access to the Linux VM from the internet on port 22
- Azure Monitor workspace for AKS container insights data

### Prerequisites
- Ensure the user or service principal deploying the solution has at least Contributor rights to the Azure subscription. During the AKS cluster creation a new resource group named 'MC_<resource group name>_<cluster name>_<deployment region>' is created which contains the private DNS zone and A record for the cluster. The final stage of the solution links this DNS zone to the hub virtual network, allowing the VM to resolve the cluster IP address. In order to link the DNS zone to the virtual network, Contributor permissions are required to the DNS zone resource.
- Create an AAD group to use for RBAC admin access to the AKS cluster
`$ az ad group create --display-name <new group name> --mail-nickname <new group name> --output json`
- Add your AAD identity as a member of this group
`$ az ad group member add --group <group objectId from previous step> --member-id <your user object id>`
- Either add the group objectId GUID to the 'aadAdminGroupObjectIds' parameter value in the azuredeploy.parameters.json file or supply the value during deployment via the Azure Portal, PowerShell or AZ CLI commands

### Scenario Deployment Validation

Validate that the AKS API service's private IP is only accessible from the Linux VM. 
- SSH to the Azure Firewall public IP returned as output from the ARM deployment
  - `$ ssh localadmin@<Azure Firewall public IP>`
- Get the Kubernetes config file
  - `$ az login`
  - `$ az account set --subscription <your azure subscription id>`
  - `$ az aks get-credentials -g <aks resource group name> -n <aks cluster name> --admin`
- Test access by listing the current nodes & pods in the cluster (kubectl & azure cli tools are automatically installed by cloud-init)
  - `$ kubectl get nodes`
  - `$ kubectl get pod -A`
- Use a machine located outside of the Azure virtual network, run the previous commands to verify that you're unable to communicate with the Kubernetes API server
