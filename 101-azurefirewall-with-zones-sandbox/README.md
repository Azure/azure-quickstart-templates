# Create Azure Firewall with Availability Zones sandbox setup

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-azurefirewall-with-zones-sandbox/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-azurefirewall-with-zones-sandbox/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-azurefirewall-with-zones-sandbox/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-azurefirewall-with-zones-sandbox/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-azurefirewall-with-zones-sandbox/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-azurefirewall-with-zones-sandbox/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-azurefirewall-with-zones-sandbox%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-azurefirewall-with-zones-sandbox%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template creates following resources:
- A virtual network with 3 subnets (server subnet, jumpbox subnet and AzureFirewall subnet)
- A jumpbox VM running Microsoft Windows with public IP and RDP access
- A server VM running Microsoft Windows with only a private IP
- UDR route to point to Azure Firewall for the ServerSubnet
- An Azure Firewall with 1 or more Public IPs, 1 sample application rule and 1 sample network rule
Azure Firewall is placed in availability zones 1, 2 and 3.
Azure Firewall is a managed cloud-based network security service that protects your Azure Virtual Network resources.
It is a fully stateful firewall as a service with built-in high availability and unrestricted cloud scalability.
You can centrally create, enforce, and log application and network connectivity policies across subscriptions and virtual network.
Azure Firewall uses one or more static public IP addresses for your virtual network resources allowing outside firewalls to identify traffic originating from your virtual network.
The service is fully integrated with Azure Monitor for logging and analytics. Learn more at https://docs.microsoft.com/en-us/azure/firewall.

