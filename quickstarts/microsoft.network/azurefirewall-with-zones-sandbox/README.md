# Create Azure Firewall with Availability Zones sandbox setup

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/azurefirewall-with-zones-sandbox/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/azurefirewall-with-zones-sandbox/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/azurefirewall-with-zones-sandbox/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/azurefirewall-with-zones-sandbox/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/azurefirewall-with-zones-sandbox/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/azurefirewall-with-zones-sandbox/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fazurefirewall-with-zones-sandbox%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fazurefirewall-with-zones-sandbox%2Fazuredeploy.json)

Azure Firewall is a managed cloud-based network security service that protects your Azure Virtual Network resources. It's a fully stateful firewall as a service with built-in high availability and unrestricted cloud scalability. You can centrally create, enforce, and log application and network connectivity policies across subscriptions and virtual network.

Azure Firewall uses one or more static public IP addresses for your virtual network resources allowing outside firewalls to identify traffic originating from your virtual network.
The service is fully integrated with Azure Monitor for logging and analytics. [Learn more](https://docs.microsoft.com/azure/firewall).

To learn more about how to deploy the template, see the [quickstart](https://docs.microsoft.com/azure/firewall/deploy-template) article.

The template creates following resources:

- A virtual network with three subnets (_ServerSubnet_, _JumpboxSubnet_ and _AzureFirewallSubnet_).
- A jumpbox VM running Microsoft Windows with public IP and RDP access.
- A server VM running Microsoft Windows with only a private IP.
- UDR route to point to Azure Firewall for the _ServerSubnet_.
- An Azure Firewall with one or more Public IPs, one sample application rule, and one sample network rule.
- Azure Firewall is placed in Availability Zones 1, 2 and 3.
