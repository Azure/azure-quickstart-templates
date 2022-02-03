# ApplicationSecurityGroupSample

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/application-security-group/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/application-security-group/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/application-security-group/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/application-security-group/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/application-security-group/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/application-security-group/CredScanResult.svg)

[![Deploy to Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fapplication-security-group%2Fazuredeploy.json)
[![Deploy to Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fapplication-security-group%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fapplication-security-group%2Fazuredeploy.json)

This template shows how to work with Application Security Groups using templates. It assigns a VM to the Application Security Group and assigns this Application Security group to two security rules on Network Security Group, one that allows SSH and another one that allows HTTP using the Destination Application Security Group Id property of the security rule. 

It deploys the following items:
1. Application Security Group
2. Network Security with two Security Rules, both using destinationApplicationSecurityGroups attribute
3. Virtual Network with one Subnet assigned to this NSG.
4. Network Interface assigned to Application Security Group, through its ID (notice that more than one can be assigned)
5. Centos 6.9 Linux Web server with NGINX installed through Custom Script Extension for Linux

For more information about Application Security Groups, please refer to:

[Network Security Groups under Network Security document](https://docs.microsoft.com/en-us/azure/virtual-network/security-overview#application-security-groupshttps://docs.microsoft.com/azure/virtual-network/security-overview)

[Filter network traffic with a network security group using PowerShell](https://docs.microsoft.com/en-us/azure/virtual-network/tutorial-filter-network-traffic)

[Filter network traffic with a network security group using the Azure CLI](https://docs.microsoft.com/en-us/azure/virtual-network/tutorial-filter-network-traffic-cli)
