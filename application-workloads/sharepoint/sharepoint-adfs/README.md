---
description: Create a DC, a SQL Server 2025, and from 1 to 5 server(s) hosting a SharePoint Subscription / 2019 / 2016 farm with an extensive configuration, including trusted authentication, user profiles with personal sites, an OAuth trust (using a certificate), a dedicated IIS site for hosting high-trust add-ins, etc... The latest version of key softwares (including Fiddler, vscode, np++, 7zip, ULS Viewer) is installed. SharePoint machines have additional fine-tuning to make them immediately usable (remote administration tools, custom policies for Edge and Chrome, shortcuts, etc...).
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: sharepoint-adfs
languages:
- bicep
- json
---
# SharePoint Subscription / 2019 / 2016 fully configured

## Deploy the template

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sharepoint/sharepoint-adfs/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sharepoint/sharepoint-adfs/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sharepoint/sharepoint-adfs/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sharepoint/sharepoint-adfs/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sharepoint/sharepoint-adfs/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sharepoint/sharepoint-adfs/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sharepoint/sharepoint-adfs/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsharepoint%2Fsharepoint-adfs%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsharepoint%2Fsharepoint-adfs%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsharepoint%2Fsharepoint-adfs%2Fazuredeploy.json)

## Features

This template creates a DC, a SQL Server 2025, and from 1 to 5 server(s) hosting a SharePoint Subscription / 2019 / 2016 farm with an extensive configuration, including trusted authentication, user profiles with personal sites, an OAuth trust (using a certificate), a dedicated IIS site for hosting high-trust add-ins, etc...  
The latest version of key softwares (including Fiddler, vscode, np++, 7zip, ULS Viewer) is installed.  
SharePoint machines have additional fine-tuning to make them immediately usable (remote administration tools, custom policies for Edge and Chrome, shortcuts, etc...).

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

- SharePoint virtual machines are created using the latest disk image of [Windows Server 2025 Azure Edition](https://learn.microsoft.com/windows-server/get-started/editions-comparison?pivots=windows-server-2025) available, and SharePoint binaries (install + cumulative updates) are downloaded and installed from scratch.
- The HTTPS site certificate is managed by SharePoint, which has the private key and sets the binding itself in the IIS site.
- Federated authentication with ADFS is configured using OpenID Connect.

### Specific to SharePoint 2019 / 2016

- SharePoint virtual machines are created using a disk image built and maintained by SharePoint Engineering.
- The HTTPS site certificate is positioned by the DSC script.
- Federated authentication with ADFS is configured using SAML 1.1.

## Outbound access to internet

During the provisionning, virtual machines require an outbound access to internet to be able to download and apply their configuration.  
The outbound access method depends on the parameter `outboundAccessMethod`:
- `PublicIPAddress`: Virtual machines use a [Public IP](https://learn.microsoft.com/azure/virtual-network/ip-services/virtual-network-public-ip-address), associated to their network card.
- `AzureFirewallProxy`: Virtual machines use [Azure Firewall](https://azure.microsoft.com/products/azure-firewall/) as an [HTTP proxy](https://learn.microsoft.com/azure/firewall/explicit-proxy).

## Remote access

The remote access to the virtual machines depends on the following parameters:

- Parameter `rdpTrafficRule` specifies if a rule in the network security groups should allow the inbound RDP traffic:
    - `No` (default): No rule is created, RDP traffic is blocked.
    - `*` or `Internet`: RDP traffic is allowed from everywhere.
    - CIDR notation (e.g. `192.168.99.0/24` or `2001:1234::/64`) or an IP address (e.g. `192.168.99.0` or `2001:1234::`): RDP traffic is allowed from the IP address / pattern specified.
- Parameter `enableAzureBastion`:
  - if `true`: Deploy [Azure Bastion Developer](https://learn.microsoft.com/azure/bastion/quickstart-developer), to allow a secure remote access to virtual machines, at no extra cost.
  - if `false` (default): [Azure Bastion Developer](https://learn.microsoft.com/azure/bastion/quickstart-developer) is not deployed.

IMPORTANT: If you set parameter `outboundAccessMethod` to `AzureFirewallProxy`, you have to either enable Azure Bastion, or manually add a public IP address later, to be able to connect to a virtual machine.

## Input parameters

- Parameter `sharePointVersion` lets you choose which version of SharePoint to install:
  - `Subscription-Latest` (default): Same as `Subscription-RTM`, then installs the latest cumulative update available at the time of publishing this version: November 2025 ([KB5002800](https://support.microsoft.com/help/5002800)).
  - `Subscription-25H2`: Same as `Subscription-RTM`, then installs the [Feature Update 25H2](https://learn.microsoft.com/sharepoint/what-s-new/new-improved-features-sharepoint-server-subscription-edition-2025-h2-release) (September 2025 CU / [KB5002784](https://support.microsoft.com/help/5002784)).
  - `Subscription-25H1`: Same as `Subscription-RTM`, then installs the [Feature Update 25H1](https://learn.microsoft.com/sharepoint/what-s-new/new-and-improved-features-in-sharepoint-server-subscription-edition-25h1-release) (March 2025 CU / [KB5002698](https://support.microsoft.com/help/5002698)).
  - `Subscription-24H2`: Same as `Subscription-RTM`, then installs the [Feature Update 24H2](https://learn.microsoft.com/sharepoint/what-s-new/new-and-improved-features-in-sharepoint-server-subscription-edition-24h2-release) (September 2024 CU / [kb5002640](https://support.microsoft.com/help/5002640)).
  - `Subscription-24H1`: Same as `Subscription-RTM`, then installs the [Feature Update 24H1](https://learn.microsoft.com/sharepoint/what-s-new/new-and-improved-features-in-sharepoint-server-subscription-edition-24h1-release) (March 2024 CU / [KB5002564](https://support.microsoft.com/help/5002564)).
  - `Subscription-23H2`: Same as `Subscription-RTM`, then installs the [Feature Update 23H2](https://learn.microsoft.com/SharePoint/what-s-new/new-and-improved-features-in-sharepoint-server-subscription-edition-23h2-release) (September 2023 CU / [KB5002474](https://support.microsoft.com/help/5002474)).
  - `Subscription-23H1`: Same as `Subscription-RTM`, then installs the [Feature Update 23H1](https://learn.microsoft.com/sharepoint/what-s-new/new-and-improved-features-in-sharepoint-server-subscription-edition-23h1-release) (March 2023 CU / [KB5002355](https://support.microsoft.com/help/5002355)).
  - `Subscription-22H2`: Same as `Subscription-RTM`, then installs the [Feature Update 22H2](https://learn.microsoft.com/sharepoint/what-s-new/new-and-improved-features-in-sharepoint-server-subscription-edition-22h2-release) (September 2022 CU / [KB5002270](https://support.microsoft.com/help/5002270) and [KB5002271](https://support.microsoft.com/help/5002271)).
  - `Subscription-RTM`: Uses a fresh Windows Server 2025 image, on which SharePoint Subscription RTM is downloaded and installed.
  - `2019`: Uses an image built and maintained by SharePoint Engineering, with SharePoint 2019 bits already installed.
  - `2016`: Uses an image built and maintained by SharePoint Engineering, with SharePoint 2016 bits already installed.
- Parameter `frontEndServersCount` lets you add up to 4 additional SharePoint servers to the farm with the [MinRole Front-end](https://learn.microsoft.com/sharepoint/install/planning-for-a-minrole-server-deployment-in-sharepoint-server).
- Parameter `enableHybridBenefitServerLicenses` allows you to enable Azure Hybrid Benefit to use your on-premises Windows Server licenses and reduce cost, if you are eligible. See [this page](https://docs.microsoft.com/azure/virtual-machines/windows/hybrid-use-benefit-licensing) for more information..

## Outputs

The template returns multiple values to record the logins and the public IP address of virtual machines.

## Cost of the resources deployed

By default, virtual machines use [Basv2 series](https://learn.microsoft.com/azure/virtual-machines/sizes/general-purpose/basv2-series), ideal for such template and much cheaper than other comparable series.  
Here is the default size and storage type per virtual machine role:

- DC: Size [Standard_B2als_v2](https://learn.microsoft.com/azure/virtual-machines/sizes/general-purpose/basv2-series) (2 vCPU / 4 GiB RAM) and OS disk is a 32 GiB [standard SSD E4](https://learn.microsoft.com/azure/virtual-machines/disks-types#standard-ssds).
- SQL Server: Size [Standard_B2as_v2](https://learn.microsoft.com/azure/virtual-machines/sizes/general-purpose/basv2-series) (2 vCPU / 8 GiB RAM) and OS disk is a 128 GiB [standard SSD E10](https://learn.microsoft.com/azure/virtual-machines/disks-types#standard-ssds).
- SharePoint: Size [Standard_B4as_v2](https://learn.microsoft.com/azure/virtual-machines/sizes/general-purpose/basv2-series) (4 vCPU / 16 GiB RAM) and OS disk is a 128 GiB [standard SSD E10](https://learn.microsoft.com/azure/virtual-machines/disks-types#standard-ssds) (for SharePoint Subscription SharePoint 2016), or a 32 GiB [standard SSD E4](https://learn.microsoft.com/azure/virtual-machines/disks-types#standard-ssds) (for SharePoint 2019).

You can visit <https://azure.com/e/26eea69e35b04cb884b83ce06feadb5c> to estimate the monthly cost of the template in the region/currency of your choice, assuming it is created using the default settings and runs 24*7.

## Known issues

- The password for the User Profile directory synchronization connection (value of parameter `otherAccountsPassword`) needs to be re-entered in the "Edit synchronization connection" page, otherwise the import fails (password decryption error).
- When parameter `outboundAccessMethod` is `AzureFirewallProxy`, most of the softwares installed through Chocolatey fail to download and are not installed.
- When deploying SharePoint 2016 or 2019, the trial enterprise license has already expired, so you must enter your own in the central administration, then run iisreset and restart the SPTimerV4 service on all the servers.
- When deploying SharePoint 2016 or 2019, the installation of softwares through Chocolatey fails for most of them.

## More information

Additional notes:

- Using the default options, the complete deployment takes about 1h (but it is worth it).
- Deploying any post-RTM SharePoint Subscription build adds only an extra 5-10 minutes to the total deployment time (compared to RTM), partly because the updates are installed before the farm is created.
- Once it is completed, the template will return valuable information in the 'Outputs' of the deployment.
- For various (very good) reasons, in SQL and SharePoint VMs, the name of the local (not domain) administrator is set with a string that is unique to your subscription (e.g. `"local-[q1w2e3r4t5]"`). It is recorded in the 'Outputs' of the deployment once it is completed.

`Tags: Microsoft.Network/networkSecurityGroups, Microsoft.Network/virtualNetworks, Microsoft.Network/publicIPAddresses, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines, extensions, DSC, Microsoft.Compute/virtualMachines/extensions, Microsoft.DevTestLab/schedules, Microsoft.Network/virtualNetworks/subnets, Microsoft.Network/bastionHosts`
