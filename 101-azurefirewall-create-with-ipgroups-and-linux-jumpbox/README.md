# Create Azure Firewall with IP Groups

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-azurefirewall-create-with-ipgroups-and-linux-jumpbox/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-azurefirewall-create-with-ipgroups-and-linux-jumpbox/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-azurefirewall-create-with-ipgroups-and-linux-jumpbox/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-azurefirewall-create-with-ipgroups-and-linux-jumpbox/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-azurefirewall-create-with-ipgroups-and-linux-jumpbox/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-azurefirewall-create-with-ipgroups-and-linux-jumpbox/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-azurefirewall-create-with-ipgroups-and-linux-jumpbox%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-azurefirewall-create-with-ipgroups-and-linux-jumpbox%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true"/>
</a>

This template deploys an Azure Firewall using IP Groups in network and application rules.

IP Groups is a top-level resource that allows you to group and manage IP addresses in Azure Firewall rules. You can give your IP Group a name and create one by entering IP addresses or uploading a file. It eases your management experience and reduce time spent managing IP addresses by using them in a single firewall or across multiple firewalls.

An IP Group can support individual or multiple IP addresses, ranges, or subnets.

Learn more at https://docs.microsoft.com/azure/firewall/ip-groups.
