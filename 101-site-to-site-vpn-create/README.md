# Site to Site VPN Connection

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-site-to-site-vpn-create/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-site-to-site-vpn-create/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-site-to-site-vpn-create/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-site-to-site-vpn-create/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-site-to-site-vpn-create/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-site-to-site-vpn-create/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-site-to-site-vpn-create%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-site-to-site-vpn-create%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template will create a Virtual Network, a subnet for the network, a Virtual Network Gateway and a Connection to your network outside of Azure (defined as your `local` network). This could be anything such as your on-premises network and can even be used with other cloud networks such as [AWS Virtual Private Cloud](https://github.com/sedouard/aws-vpc-to-azure-vnet).

Please note that you must have a Public IP for your other network's VPN gateway and cannot be behind an NAT.

Although only the parameters in [azuredeploy.parameters.json](./azuredeploy.parameters.json) are necessary, you can override the defaults of any of the template parameters.

