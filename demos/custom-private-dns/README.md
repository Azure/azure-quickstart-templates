# Create a custom private DNS zone within your virtual network

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/custom-private-dns/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/custom-private-dns/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/custom-private-dns/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/custom-private-dns/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/custom-private-dns/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/custom-private-dns/CredScanResult.svg)

This template demonstrates how to create a highly-available pair of DNS servers hosting a private DNS zone for your virtual network.  It also shows how to configure both Windows and Linux client VMs to register their DNS records with the DNS server.  Each client registers an A record for forward (host-to-ip) DNS and a PTR record for reverse (ip-to-host) DNS.

The template uses the following elements:

- A pair of Active Directory domain controllers to act as HA DNS servers.  Active Directory has been used as it automatically handles replication between the two DNS servers to give a highly available resolving plane.  Note: This setup is deployed by including [a pre-existing template from the Azure gallery](https://azure.microsoft.com/en-us/resources/templates/active-directory-new-domain-ha-2-dc/).

- A VM Extension (in nested/setupserver.json) to modify the DNS server's settings to allow dynamic DNS updates from the clients and to add the reverse DNS zone.

- VM Extensions (in nested/linux-client/setuplinuxclient.json and nested/windows-client/setupwinclient.json) to configure the client VMs to a) register their DNS records (A and PTR) and to use the desired DNS suffix instead of the Azure-provided suffix.  When adding more client VMs to the virtual network, you can include these VM estensios to enable the private DNS functionality on them.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fcustom-private-dns%2Fazuredeploy.json)  [![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fcustom-private-dns%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fcustom-private-dns%2Fazuredeploy.json)
