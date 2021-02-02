# Create Firewall Premium (IDPS,TLS Inspection,Web Categories)

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-azurefirewall-premium/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-azurefirewall-premium/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-azurefirewall-premium/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-azurefirewall-premium/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-azurefirewall-premium/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-azurefirewall-premium/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-azurefirewall-premium%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-azurefirewall-premium%2Fazuredeploy.json)

This template deploys an Azure Firewall Premium enabled with IDPS, TLS Inspection and Web Categories filtering.

- The template deploys all dependencies including Key Vault, Managed Identity, Policy and will generate a self signed Root CA and Intermediate CA. In a production environment these resources may already be created and not needed in the same template.
- For testing purposes a Bastion Host (BastionHost) is also deployed and can be used to connect to the Windows testing machine (ServerVM). The VM is installed with the generated Root CA certificate.
- Policy is applied with TLS inspection and IDPS enabled
  - Go to https://www.microsoft.com and inspect the certificate in the browser
  - Go to https://azure.microsoft.com/en-us/community/events which is denied using a URL deny rule.

Azure Firewall is a managed cloud-based network security service that protects your Azure Virtual Network resources. It is a fully stateful firewall as a service with built-in high availability and unrestricted cloud scalability. You can centrally create, enforce, and log application and network connectivity policies across subscriptions and virtual network. Azure Firewall uses a static public IP address for your virtual network resources allowing outside firewalls to identify traffic originating from your virtual network.

Learn more at https://docs.microsoft.com/en-us/azure/firewall.
