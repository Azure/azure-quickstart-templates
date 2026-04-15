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
# A template to deploy SharePoint Subscription / 2019 / 2016

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sharepoint/sharepoint-adfs/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sharepoint/sharepoint-adfs/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sharepoint/sharepoint-adfs/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sharepoint/sharepoint-adfs/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sharepoint/sharepoint-adfs/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sharepoint/sharepoint-adfs/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sharepoint/sharepoint-adfs/BicepVersion.svg)

This template creates a secure, highly customizable SharePoint Subscription / 2019 / 2016 farm, using [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/), and the [project SharePointInfraDsc](https://github.com/Yvand/SharePointInfraDsc) to apply the DSC (desired state configuration) to the virtual machines.

## Main objectives

- A highly secure, customizable environment, under your full control (you set the AD domain name, admin account name, all accounts password).
- A SharePoint farm installed with the PU of your choice (including the latest one), and up-to-date Windows and softwares before you first log-in.
- Eliminate the burden of doing tedious configuration: Many SharePoint features and services are configured, doing this manually would take ages.
- Truly ready-to-use virtual machines right at the first log-in, with everything a SharePoint administrator needs.
- A state-of-the-art configuration that showcases the best practices for a a well-configured SharePoint farm.
- A fast deployment time: A fully configured SharePoint farm installed with the latest PU takes only about 1h15 mins to be fully ready (if you think it is not so fast, compare this with the time it takes to install a SharePoint PU in your farm).
- Easy to create, use, and destroy. You want to test a SharePoint setting/config but you are afraid to mess your existing farm? You want to test a specific SharePoint build? Or test OIDC? Use this template.

## Virtual machines

- The DC and SharePoint Subscription machines use the latest image of [Windows Server 2025 Datacenter: Azure Edition](https://marketplace.microsoft.com/en-us/product/microsoftwindowsserver.windowsserver?tab=PlansAndPrice).
- SQL machine uses the latest image of [SQL Server 2025 Standard Developer on Windows Server 2025](https://marketplace.microsoft.com/en-us/product/microsoftsqlserver.sql2025-ws2025?tab=PlansAndPrice).

About SharePoint legacy: SharePoint 2016 / 2019 use outdated images ([2016](https://marketplace.microsoft.com/en-us/product/sharepointserver.2016?tab=Overview) and [2019](https://marketplace.microsoft.com/en-us/product/sharepointserver.2019?tab=Overview)) published by SharePoint Engineering.

## Usage

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsharepoint%2Fsharepoint-adfs%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsharepoint%2Fsharepoint-adfs%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsharepoint%2Fsharepoint-adfs%2Fazuredeploy.json)


## SharePoint configuration

- Parameter `sharePointVersion` sets which version of SharePoint will be installed:
  - `Subscription-Latest` (default): SharePoint Subscription with the latest public update available at the time of publishing this version: April  2026 ([KB5002853](https://support.microsoft.com/help/5002853)).
  - `Subscription-25H2`: SharePoint Subscription with the [Feature Update 25H2](https://learn.microsoft.com/sharepoint/what-s-new/new-improved-features-sharepoint-server-subscription-edition-2025-h2-release) (September 2025 PU / [KB5002784](https://support.microsoft.com/help/5002784)).
  - `Subscription-25H1`: SharePoint Subscription with the [Feature Update 25H1](https://learn.microsoft.com/sharepoint/what-s-new/new-and-improved-features-in-sharepoint-server-subscription-edition-25h1-release) (March 2025 PU / [KB5002698](https://support.microsoft.com/help/5002698)).
  - `Subscription-24H2`: SharePoint Subscription with the [Feature Update 24H2](https://learn.microsoft.com/sharepoint/what-s-new/new-and-improved-features-in-sharepoint-server-subscription-edition-24h2-release) (September 2024 PU / [kb5002640](https://support.microsoft.com/help/5002640)).
  - `Subscription-24H1`: SharePoint Subscription with the [Feature Update 24H1](https://learn.microsoft.com/sharepoint/what-s-new/new-and-improved-features-in-sharepoint-server-subscription-edition-24h1-release) (March 2024 PU / [KB5002564](https://support.microsoft.com/help/5002564)).
  - `Subscription-23H2`: SharePoint Subscription with the [Feature Update 23H2](https://learn.microsoft.com/SharePoint/what-s-new/new-and-improved-features-in-sharepoint-server-subscription-edition-23h2-release) (September 2023 PU / [KB5002474](https://support.microsoft.com/help/5002474)).
  - `Subscription-23H1`: SharePoint Subscription with the [Feature Update 23H1](https://learn.microsoft.com/sharepoint/what-s-new/new-and-improved-features-in-sharepoint-server-subscription-edition-23h1-release) (March 2023 PU / [KB5002355](https://support.microsoft.com/help/5002355)).
  - `Subscription-22H2`: SharePoint Subscription with the [Feature Update 22H2](https://learn.microsoft.com/sharepoint/what-s-new/new-and-improved-features-in-sharepoint-server-subscription-edition-22h2-release) (September 2022 PU / [KB5002270](https://support.microsoft.com/help/5002270) and [KB5002271](https://support.microsoft.com/help/5002271)).
  - `Subscription-RTM`: SharePoint Subscription RTM [published here](https://www.microsoft.com/en-us/download/details.aspx?id=103599).
  - `2019` (deprecated): Uses the [image](https://marketplace.microsoft.com/en-us/product/sharepointserver.2019?tab=Overview) built and maintained by SharePoint Engineering.
  - `2016` (deprecated): Uses the [image](https://marketplace.microsoft.com/en-us/product/sharepointserver.2016?tab=Overview) built and maintained by SharePoint Engineering.
- Parameter `sharePointConfigurationLevel` sets how much configuration is done:
  - `Minimum`: Creates a web application with its default zone only.
  - `Light`: Everything in `Minimum`, plus:
    - Provisions the State Service Application.
    - Configures the trusted authentication (OIDC with ADFS).
  - `Medium`: Everything in `Light`, plus:
    - Provisions the User Profile Service Application.
    - Extends the web application in zone `Intranet`.
  - `Full`: Everything in `Medium`, plus:
    - Configures all the resources to run and deploy add-ins.
    - Creates addditional host-named site collections.
- Parameter `defaultZoneMustBeHttps`: `true` if the default zone must use HTTPS, `false` if it may use HTTP (if compatible with the configuration selected).
- Parameter `frontEndServersCount` lets you add up to 4 additional SharePoint servers to the farm with the [MinRole Front-end](https://learn.microsoft.com/sharepoint/install/planning-for-a-minrole-server-deployment-in-sharepoint-server).

## Outbound access to internet

During the provisionning, virtual machines require an outbound access to internet to be able to download and apply their configuration.  
The outbound access method depends on parameter `outboundAccessMethod`:
- `PublicIPAddress`: Virtual machines use a [Public IP](https://learn.microsoft.com/azure/virtual-network/ip-services/virtual-network-public-ip-address), associated with their network card.
- `AzureFirewallProxy`: Virtual machines use [Azure Firewall](https://azure.microsoft.com/products/azure-firewall/) as an [HTTP proxy](https://learn.microsoft.com/azure/firewall/explicit-proxy).

## Remote access

The remote access to the virtual machines depends on the following parameters:

- Parameter `rdpTrafficRule` specifies if a rule in the network security groups should allow the inbound RDP traffic:
    - `No` (default): No rule is created, RDP traffic is blocked.
    - `*` or `Internet`: RDP traffic is allowed from everywhere.
    - CIDR notation (e.g. `192.168.99.0/24` or `2001:1234::/64`) or an IP address (e.g. `192.168.99.0` or `2001:1234::`): RDP traffic is allowed from the IP address / pattern specified.
- Parameter `enableAzureBastion`:
  - if `true`: Configure service [Azure Bastion](https://azure.microsoft.com/services/azure-bastion/) with Basic SKU, to allow a secure remote access to virtual machines.
  - if `false` (default): Service [Azure Bastion](https://azure.microsoft.com/services/azure-bastion/) is not created.

IMPORTANT: If you set parameter `outboundAccessMethod` to `AzureFirewallProxy`, you have to either enable Azure Bastion, or manually add a public IP address later, to be able to connect to a virtual machine.

## Other input parameters

- The resource group name is used:
  - As the name of the Azure resource group which hosts all the resources that will be created.
  - As part of the public DNS name of the virtual machines, if they get a public IP (parameter `outboundAccessMethod`), and a DNS name associated with it (parameter `addNameToPublicIpAddresses`).
- Parameter `enableHybridBenefitServerLicenses` allows you to enable Azure Hybrid Benefit to use your on-premises Windows Server licenses and reduce cost, if you are eligible. See [this page](https://docs.microsoft.com/azure/virtual-machines/windows/hybrid-use-benefit-licensing) for more information..

## Outputs

Upon completion, the deployment returns multiple values such as the logins, passwords, the public IP address of virtual machines, and other useful information.

## Cost of the resources deployed

By default, virtual machines use [Basv2 series](https://learn.microsoft.com/azure/virtual-machines/sizes/general-purpose/basv2-series), ideal for such template and much cheaper than other comparable series.  
Below is the default size and storage used per virtual machine role:

- DC: Size [Standard_B2als_v2](https://learn.microsoft.com/azure/virtual-machines/sizes/general-purpose/basv2-series) (2 vCPU / 4 GiB RAM) and OS disk is a 32 GiB [standard SSD E4](https://learn.microsoft.com/azure/virtual-machines/disks-types#standard-ssds).
- SQL Server: Size [Standard_B2as_v2](https://learn.microsoft.com/azure/virtual-machines/sizes/general-purpose/basv2-series) (2 vCPU / 8 GiB RAM) and OS disk is a 128 GiB [standard SSD E10](https://learn.microsoft.com/azure/virtual-machines/disks-types#standard-ssds).
- SharePoint: Size [Standard_B4as_v2](https://learn.microsoft.com/azure/virtual-machines/sizes/general-purpose/basv2-series) (4 vCPU / 16 GiB RAM) and OS disk is a 128 GiB [standard SSD E10](https://learn.microsoft.com/azure/virtual-machines/disks-types#standard-ssds) (for SharePoint Subscription and SharePoint 2016), or a 32 GiB [standard SSD E4](https://learn.microsoft.com/azure/virtual-machines/disks-types#standard-ssds) (for SharePoint 2019).

You can use <https://azure.com/e/26eea69e35b04cb884b83ce06feadb5c> to estimate the monthly cost of deploying the resources in this module, in the region/currency of your choice, assuming it is created using the default settings and runs 24*7.

## Known issues

- The password for the User Profile directory synchronization connection (parameter `otherAccountsPassword`) needs to be re-entered in the "Edit synchronization connection" page, otherwise the profile import fails (password decryption error in the logs).
- When setting `outboundAccessMethod` to `AzureFirewallProxy`, most of the softwares installed through Chocolatey fail to download and are not installed.
- The deployment of Azure Bastion fails pretty frequently. This has little impact, since it is very easy to redeploy through the portal.
- SharePoint 2016 and 2019 are outdated and deprecated. Their corresponding DSC configurations receive little maintenance to ensure they continue to deploy, but receive no improvement. As such, parameters `sharePointConfigurationLevel` and `defaultZoneMustBeHttps` have no effect on them.

## Additional information

- Using the default options, the complete deployment takes about 1h (but it is worth it).
- Installing a SharePoint PU adds less than 10 minutes to the total deployment time, mostly because the PU is installed before the farm is created.
- For various (very good) reasons, in SQL and SharePoint VMs, the name of the local (not domain) administrator is set with a string that is unique to your subscription (e.g. `l-[q1w2e3r4t5]`). It is recorded in the 'Outputs' of the deployment once it is completed.

`Tags: Microsoft.Network/networkSecurityGroups, Microsoft.Network/virtualNetworks, Microsoft.Network/publicIPAddresses, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines, extensions, DSC, Microsoft.Compute/virtualMachines/extensions, Microsoft.DevTestLab/schedules, Microsoft.Network/virtualNetworks/subnets, Microsoft.Network/bastionHosts`