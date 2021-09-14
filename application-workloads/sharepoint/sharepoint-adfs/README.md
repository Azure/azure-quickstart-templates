# Azure template for SharePoint 2019 / 2016 / 2013

## Presentation

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sharepoint/sharepoint-adfs/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sharepoint/sharepoint-adfs/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sharepoint/sharepoint-adfs/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sharepoint/sharepoint-adfs/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sharepoint/sharepoint-adfs/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sharepoint/sharepoint-adfs/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsharepoint%2Fsharepoint-adfs%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsharepoint%2Fsharepoint-adfs%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsharepoint%2Fsharepoint-adfs%2Fazuredeploy.json)

This template deploys SharePoint 2019, 2016 or 2013 with the following configuration:

* 1 web application created with 2 zones: Windows NTLM on Default zone and ADFS on Intranet zone.
* ADFS is installed on the DC, and SAML trust is configured in SharePoint.
* A certificate authority (ADCS) is provisioned on the DC and issues all certificates needed for ADFS and SharePoint.
* A couple of site collections are created, including [host-named site collections](https://docs.microsoft.com/en-us/SharePoint/administration/host-named-site-collection-architecture-and-deployment) that are configured for both zones.
* User Profiles Application service is provisioned and personal sites are configured as [host-named site collections](https://docs.microsoft.com/en-us/SharePoint/administration/host-named-site-collection-architecture-and-deployment).
* Add-ins service application is provisioned and an app catalog is created.
* 2 app domains are set (1 for for each zone of the web application) and corresponding DNS zones are created.
* Latest version of claims provider [LDAPCP](https://ldapcp.com/) is installed and configured.
* A 2nd SharePoint server can optionally be added to the farm.

## Remote access and security

The template creates 1 virtual network with 3 subnets. All subnets are protected by a [Network Security Group](https://docs.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview) with no custom rule by default.

The following parameters impact the remote access of the virtual machines, and the network security:

* Parameter 'addPublicIPAddressToEachVM':
  * if true (default value): Each virtual machine gets a public IP, a DNS name, and may be reachable from Internet.
  * if false: No public IP resource is created.
* Parameter 'RDPTrafficAllowed':
  * If 'No' (default value): Firewall denies all incoming RDP traffic from Internet.
  * If '*' or 'Internet': Firewall accepts all incoming RDP traffic from Internet.
  * If 'ServiceTagName': Firewall accepts all incoming RDP traffic from the specified 'ServiceTagName'.
  * If 'xx.xx.xx.xx': Firewall accepts incoming RDP traffic only from the IP 'xx.xx.xx.xx'.
* Parameter 'addAzureBastion':
  * if true: Configure service [Azure Bastion](https://azure.microsoft.com/en-us/services/azure-bastion/) to allow a secure remote access.
  * if false (default value): Service Azure Bastion is not created.

## Cost

By default, virtual machines use [B-series burstable](https://docs.microsoft.com/en-us/azure/virtual-machines/sizes-b-series-burstable), ideal for such template and much cheaper than other comparable series.  
Here is the default size and storage type per virtual machine role:

* DC: Size [Standard_B2s](https://docs.microsoft.com/en-us/azure/virtual-machines/sizes-b-series-burstable) (2 vCPU / 4 GiB RAM) and OS disk is a 128 GiB standard HDD.
* SQL Server: Size [Standard_B2ms](https://docs.microsoft.com/en-us/azure/virtual-machines/sizes-b-series-burstable) (2 vCPU / 8 GiB RAM) and OS disk is a 128 GiB standard HDD.
* SharePoint: Size [Standard_B4ms](https://docs.microsoft.com/en-us/azure/virtual-machines/sizes-b-series-burstable) (4 vCPU / 16 GiB RAM) and OS disk is a 128 GiB [standard SSD](https://azure.microsoft.com/en-us/blog/preview-standard-ssd-disks-for-azure-virtual-machine-workloads/).

You can visit <https://azure.com/e/cec4eb6f853d43c6bcfaf56be0363ee4> to view the global cost of the template when it is deployed using the default settings, in the region/currency of your choice.

## More information

Additional notes:

* I strongly recommend to update SharePoint to a recent build after the deployment completed.  
* With the default settings, the deployment takes about 1h to complete.  
* Once it is completed, the template will return valuable information in the 'Outputs' of the deployment.  
* For various (very good) reasons, the template sets the local (not domain) administrator name with a string that is unique to your subscription (e.g. 'local-q1w2e3r4t5'). You can find the name of the local admin in the 'Outputs' of the deployment once it is completed.  
