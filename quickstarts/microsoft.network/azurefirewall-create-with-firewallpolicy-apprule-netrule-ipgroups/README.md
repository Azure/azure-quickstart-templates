# Create Firewall with firewall Policy (including multiple application, network rules with referencing IP Groups)

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/azurefirewall-create-with-firewallpolicy-apprule-netrule-ipgroups/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/azurefirewall-create-with-firewallpolicy-apprule-netrule-ipgroups/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/azurefirewall-create-with-firewallpolicy-apprule-netrule-ipgroups/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/azurefirewall-create-with-firewallpolicy-apprule-netrule-ipgroups/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/azurefirewall-create-with-firewallpolicy-apprule-netrule-ipgroups/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/azurefirewall-create-with-firewallpolicy-apprule-netrule-ipgroups/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fazurefirewall-create-with-firewallpolicy-apprule-netrule-ipgroups%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fazurefirewall-create-with-firewallpolicy-apprule-netrule-ipgroups%2Fazuredeploy.json)


This template deploys an Azure Firewall with Firewall Policy (including multiple application and network rules) referencing of IP Groups in application and network rules.

IP Groups is a top-level resource that allows you to group and manage IP addresses in Firewall Policy rules. You can give your IP Group a name and create one by entering IP addresses or uploading a file. It eases your management experience and reduce time spent managing IP addresses by using them in a single firewall policy or across multiple firewall policies.

An IP Group can support individual or multiple IP addresses, ranges, or subnets.

Learn more at https://docs.microsoft.com/azure/firewall/ip-groups.
