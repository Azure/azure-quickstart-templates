---
description: This template creates a SharePoint Subscription / 2019 / 2016 / 2013 farm with an extensive configuration that would take ages to perform manually, including a federated authentication with ADFS, an OAuth trust, the User Profiles service and a web application with 2 zones that contains multiple path based and host-named site collections. On the SharePoint virtual machines, Chocolatey is used to install the latest version of Notepad++, Visual Studio Code, Azure Data Studio, Fiddler, ULS Viewer and 7-Zip.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: sharepoint-adfs
languages:
- json
---
# SharePoint Subscription / 2019 / 2016 / 2013 all configured

## Deploy the template

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sharepoint/sharepoint-adfs/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sharepoint/sharepoint-adfs/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sharepoint/sharepoint-adfs/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sharepoint/sharepoint-adfs/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sharepoint/sharepoint-adfs/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sharepoint/sharepoint-adfs/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsharepoint%2Fsharepoint-adfs%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsharepoint%2Fsharepoint-adfs%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsharepoint%2Fsharepoint-adfs%2Fazuredeploy.json)

## Features

This templates creates a SharePoint Subscription / 2019 / 2016 / 2013 farm with an extensive configuration that would take ages to perform manually, including a federated authentication with ADFS, an OAuth trust, the User Profiles service and a web application with 2 zones and multiple path based and host-named site collections.  
On the SharePoint virtual machines, [Chocolatey](https://chocolatey.org/) is used to install the latest version of Notepad++, Visual Studio Code, Azure Data Studio, Fiddler, ULS Viewer and 7-Zip.
There are some differences in the configuration, depending on the SharePoint version:

### Common to all SharePoint versions

- An Active Directory forest with AD CS and AD FS configured. LDAPS (LDAP over SSL) is also configured.
- SharePoint service applications configured: User Profiles, add-ins, session state.
- SharePoint User Profiles service is configured with a directory synchronization connection, and the MySite host is a host-named site collection.
- SharePoint has 1 web application with path based and host-named site collections, and contains 2 zones:
  - Default zone: HTTP using Windows authentication.
  - Intranet zone: HTTPS using federated (ADFS) authentication.
- An OAuth trust is created, as well as a custom IIS site to host your high-trust add-ins.
- Custom claims provider [LDAPCP](https://www.ldapcp.com/) is installed and configured.

### Specific to SharePoint Subscription

- SharePoint virtual machines are created using the latest disk image of [Windows Server 2022 Azure Edition](https://learn.microsoft.com/windows-server/get-started/editions-comparison-windows-server-2022) available, and SharePoint binaries (install + cumulative updates) are downloaded and installed from scratch.
- The HTTPS site certificate is managed by SharePoint, which has the private key and sets the binding itself in the IIS site.
- Federated authentication with ADFS is configured using OpenID Connect.

### Specific to SharePoint 2019 / 2016 / 2013

- SharePoint virtual machines are created using a disk image built and maintained by SharePoint Engineering.
- The HTTPS site certificate is positioned by the DSC script.
- Federated authentication with ADFS is configured using SAML 1.1.

## Key parameters

### Input parameters

- parameter `sharePointVersion` lets you choose which version of SharePoint to install:
  - `Subscription-Latest` (default): Same as `Subscription-RTM`, then install the latest cumulative update available at the time of publishing: April 2023 ([KB5002375](https://support.microsoft.com/help/5002375)) for current template version.
  - `Subscription-23H1`: Same as `Subscription-RTM`, then install the [Feature Update 23H1](https://learn.microsoft.com/en-us/sharepoint/what-s-new/new-and-improved-features-in-sharepoint-server-subscription-edition-23h1-release) (March 2023 CU / [KB5002355](https://support.microsoft.com/help/5002355)).
  - `Subscription-22H2`: Same as `Subscription-RTM`, then install the [Feature Update 22H2](https://learn.microsoft.com/en-us/sharepoint/what-s-new/new-and-improved-features-in-sharepoint-server-subscription-edition-22h2-release) (September 2022 CU / [KB5002270](https://support.microsoft.com/help/5002270) and [KB5002271](https://support.microsoft.com/help/5002271)).
  - `Subscription-RTM`: Uses a fresh Windows Server 2022 image, on which SharePoint Subscription RTM is downloaded and installed.
  - `2019`: Uses an image built and maintained by SharePoint Engineering, with SharePoint 2019 bits already installed.
  - `2016`: Uses an image built and maintained by SharePoint Engineering, with SharePoint 2016 bits already installed.
  - `2013`: Uses an image built and maintained by SharePoint Engineering, with SharePoint 2013 bits already installed.
- parameters `addPublicIPAddress` and `RDPTrafficAllowed`: See [this section](#remote-access-and-security) for detailed information.
- parameter `numberOfAdditionalFrontEnd` lets you add up to 4 additional SharePoint servers to the farm with the [MinRole Front-end](https://learn.microsoft.com/en-us/sharepoint/install/planning-for-a-minrole-server-deployment-in-sharepoint-server) (except on SharePoint 2013, which does not support MinRole).
- parameter `enableHybridBenefitServerLicenses` allows you to enable Azure Hybrid Benefit to use your on-premises Windows Server licenses and reduce cost, if you are eligible. See [this page](https://docs.microsoft.com/azure/virtual-machines/windows/hybrid-use-benefit-licensing) for more information..

### Output parameters

The template returns multiple variables to record the logins, passwords and the public IP address of virtual machines.

## Remote access and security

The template creates 1 virtual network with 3 subnets (+1 if [Azure Bastion](https://azure.microsoft.com/services/azure-bastion/) is enabled), and each subnet is protected by a [Network Security Group](https://docs.microsoft.com/azure/virtual-network/network-security-groups-overview) which denies all incoming traffic by default.  
The following parameters configure how to connect to the virtual machines, and the level of network security:

- parameters `adminPassword` and `serviceAccountsPassword` require a [strong password](https://learn.microsoft.com/azure/virtual-machines/windows/faq#what-are-the-password-requirements-when-creating-a-vm-).
- parameter `addPublicIPAddress`:
  - if `"SharePointVMsOnly"` (default): Only SharePoint virtual machines get a public IP address with a DNS name and can be reached from Internet.
  - If `"Yes"`: All virtual machines get a public IP address with a DNS name, and can be reached from Internet.
  - if `"No"`: No public IP resource is created.
  - The DNS name format of virtual machines is `"[resourceGroupName]-[vm_name].[region].cloudapp.azure.com"` and is recorded as output in the state file.
- parameter `RDPTrafficAllowed` specifies if RDP traffic is allowed:
  - If `"No"` (default): Firewall denies all incoming RDP traffic.
  - If `"*"` or `"Internet"`: Firewall accepts all incoming RDP traffic from Internet.
  - If CIDR notation (e.g. `"192.168.99.0/24"` or `"2001:1234::/64"`) or IP address (e.g. `"192.168.99.0"` or `"2001:1234::"`): Firewall accepts incoming RDP traffic from the IP addresses specified.
- parameter `addAzureBastion`:
  - if `true`: Configure service [Azure Bastion](https://azure.microsoft.com/services/azure-bastion/) to allow a secure remote access to virtual machines.
  - if `false` (default): Service [Azure Bastion](https://azure.microsoft.com/services/azure-bastion/) is not created.

## Cost of the resources deployed

By default, virtual machines use [B-series burstable](https://docs.microsoft.com/azure/virtual-machines/sizes-b-series-burstable), ideal for such template and much cheaper than other comparable series.  
Here is the default size and storage type per virtual machine role:

- DC: Size [Standard_B2s](https://docs.microsoft.com/azure/virtual-machines/sizes-b-series-burstable) (2 vCPU / 4 GiB RAM) and OS disk is a 32 GiB [standard SSD E4](https://learn.microsoft.com/azure/virtual-machines/disks-types#standard-ssds).
- SQL Server: Size [Standard_B2ms](https://docs.microsoft.com/azure/virtual-machines/sizes-b-series-burstable) (2 vCPU / 8 GiB RAM) and OS disk is a 128 GiB [standard SSD E10](https://learn.microsoft.com/azure/virtual-machines/disks-types#standard-ssds).
- SharePoint: Size [Standard_B4ms](https://docs.microsoft.com/azure/virtual-machines/sizes-b-series-burstable) (4 vCPU / 16 GiB RAM) and OS disk is either a 32 GiB [standard SSD E4](https://learn.microsoft.com/azure/virtual-machines/disks-types#standard-ssds) (for SharePoint Subscription and 2019), or a 128 GiB [standard SSD E10](https://learn.microsoft.com/azure/virtual-machines/disks-types#standard-ssds) (for SharePoint 2016 and 2013).

You can visit <https://azure.com/e/c494029b0b034b8ca356c926dfd2688a> to estimate the monthly cost of the template in the region/currency of your choice, assuming it is created using the default settings and runs 24*7.

## Known issues

- The password of the directory synchronization connection (set in parameter `serviceAccountsPassword`) needs to be re-entered in the "Edit synchronization connection" page, otherwise SharePoint is somehow unable to decrypt it and the import fails.

## More information

Additional notes:

- Using the default options, the complete deployment takes about 1h (but it is worth it).
- Deploying any post-RTM SharePoint Subscription build adds only an extra 5-10 minutes to the total deployment time (compared to RTM), partly because the updates are installed before the farm is created.
- Once it is completed, the template will return valuable information in the 'Outputs' of the deployment.
- For various (very good) reasons, in SQL and SharePoint VMs, the name of the local (not domain) administrator is set with a string that is unique to your subscription (e.g. `"local-[q1w2e3r4t5]"`). It is recorded in the 'Outputs' of the deployment once it is completed.

`Tags: Microsoft.Network/networkSecurityGroups, Microsoft.Network/virtualNetworks, Microsoft.Network/publicIPAddresses, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines, extensions, DSC, Microsoft.Compute/virtualMachines/extensions, Microsoft.DevTestLab/schedules, Microsoft.Network/virtualNetworks/subnets, Microsoft.Network/bastionHosts`
