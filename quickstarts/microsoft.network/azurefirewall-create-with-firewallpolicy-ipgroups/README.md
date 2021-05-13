# Create Azure Firewall with Firewall Policy referencing IP Groups

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/azurefirewall-create-with-firewallpolicy-ipgroups/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/azurefirewall-create-with-firewallpolicy-ipgroups/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/azurefirewall-create-with-firewallpolicy-ipgroups/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/azurefirewall-create-with-firewallpolicy-ipgroups/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/azurefirewall-create-with-firewallpolicy-ipgroups/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/azurefirewall-create-with-firewallpolicy-ipgroups/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fazurefirewall-create-with-firewallpolicy-ipgroups%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fazurefirewall-create-with-firewallpolicy-ipgroups%2Fazuredeploy.json)

This template deploys an Azure Firewall with Firewall Policy using IP Groups in network  rules.

IP Groups is a top-level resource that allows you to group and manage IP addresses in FirewallPolicy rules. You can give your IP Group a name and create one by entering IP addresses or uploading a file. It eases your management experience and reduce time spent managing IP addresses by using them in a single firewall policy or across multiple firewall policies.

An IP Group can support individual or multiple IP addresses, ranges, or subnets.

Learn more at https://docs.microsoft.com/azure/firewall/ip-groups.


