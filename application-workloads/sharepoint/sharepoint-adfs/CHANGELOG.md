# Change log for Azure template SharePoint-ADFS

## Enhancements & bug-fixes - Published in November 19, 2025

### Changed

- Template
  - Value `Subscription-Latest` for parameter `sharePointVersion` now installs the November 2025 CU for SharePoint Subscription
  - Added value `Subscription-25H2` to parameter `sharePointVersion`, to install SharePoint Subscription version 25H2 (September 2025 CU)
  - Switched to SQL Server 2025 on Windows Server 2025
  - Bumped versions of Bicep resources and [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/)
  - Updated bicep module for virtual machines
  - Updated pipConfiguration objects to use updated property names, and prevent error "-pip-01 does not support availability zones at location 'westus'"
  - Updated outputs

- All DSC configurations
  - Updated DSC module **DnsServerDsc** from 3.0.0 to 3.0.1

- DSC Configuration for all SharePoint VMs
  - Removed Azure Data Studio (deprecated)
  - Updated DSC module **SharePointDsc** from 5.6.0 to 5.7.0

- DSC Configuration for SharePoint SE
  - Re-enabled setting property IsPeoplePickerSearchable on selected profile properties, for use by UPA claims provider
  - Remove the explicit TLS settings, not required with Windows Server 2025
  - Added parameter DatabaseConnectionEncryption for resource SPFarm, required with  **SharePointDsc** 5.7.0 + 2025-08 PU+

### Fixed

- DSC Configuration for SharePoint SE
  - Move script that runs GrantOwnerAccessToDatabaseAccount after all databases were created, and before any WFE server may connect to the farm, to fix SQL permission errors thrown at step 10/10 in SPS config wizard, when installing a CU post-provisionning

- DSC Configuration for DC
  - Explicitly install the Windows feature "Group Policy Management Console (GPMC)", to ensure cmdlets *-GPO are installed
  - Allow a reboot before running ADDomain, as it became necessary after installing the Windows feature "Group Policy Management Console (GPMC)"

## Enhancements & bug-fixes - Published in June 2, 2025

### Changed

- Template
  - Bump versions of Bicep resources and [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/)
  - Value `Subscription-Latest` for parameter `sharePointVersion` now installs the May 2025 CU for SharePoint Subscription

## Enhancements & bug-fixes - Published in April 24, 2025

### Changed

- Template
  - Rewrite the entire template to create all the resources using [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/)
  - Parameter `enableAzureBastion` now deploys Azure Bastion Developer, which is available at no extra cost
  - Value `Subscription-Latest` for parameter `sharePointVersion` now installs the April 2025 CU for SharePoint Subscription
- DSC Configuration for all VMs
  - Updated DSC module ActiveDirectoryDsc to 6.6.2 and remove all customizations on this module
- DSC Configuration for SharePoint SE
  - Move script that runs GrantOwnerAccessToDatabaseAccount, to run it just after the farm is created

## Enhancements & bug-fixes - Published in March 14, 2025

### Changed

- Template
  - Value `Subscription-Latest` for parameter `sharePointVersion` now installs the March 2025 CU for SharePoint Subscription
  - Added value `Subscription-25H1` to parameter `sharePointVersion`, to install SharePoint Subscription version 25H1
  - Fixed the Bicep warnings by using the safe access (.?) operator
- DSC Configuration for all VMs
  - Replace Write-Host with Write-Verbose, to print the log nessage in both the log file and the console
  - Updated DSC module ComputerManagementDsc to 10.0.0
- DSC Configuration for SharePoint
  - Updated DSC module SharePointDsc to 5.6.1
- DSC Configuration for SQL
  - Configured the encryption of the SQL traffic, which is used autonmatically by SharePoint Subscription 25H1 and onward

### Fixed

- DSC Configuration for SharePoint 2016
  - Add a temporary fix to workaround a regression on resource ADObjectPermissionEntry, introduced with module ActiveDirectoryDsc v6.6.0 (https://github.com/dsccommunity/ActiveDirectoryDsc/issues/724)

## Enhancements & bug-fixes - Published in February 25, 2025

### Changed

- Template
  - Value `Subscription-Latest` for parameter `sharePointVersion` now installs the February 2025 CU for SharePoint Subscription

### Fixed

- Template
  - Fixed connecting to VMs through Azure Bastion
- DSC Configuration for DC
  - Removed NetConnectionProfile (to set the network interface as private) as it randomly causes errors
- DSC Configuration for SPSE
  - Install the LDAPCP solution as domain admin instead of setup account to improve the reliability
  - Do not generate an error if creating LDAPCP configuration fails

## Enhancements & bug-fixes - Published in January 17, 2025

### Changed

- Template
  - Enabled [Trusted launch](https://learn.microsoft.com/azure/virtual-machines/trusted-launch-existing-vm), with secure boot and Virtual Trusted Platform Module, on all virtual machines except SharePoint 2016
  - Added parameter `addNameToPublicIpAddresses`, to set which virtual machines have a public name associated to their public IP address.
  - [BREAKING CHANGE] With the default value of new parameter `addNameToPublicIpAddresses` set to `SharePointVMsOnly`, now, only SharePoint VMs have a public name by default. Other VMs only have a public IP.
  - Upgraded the virtual machines DC and SharePoint Subscription to Windows Server 2025.
  - Changed the network configuration to use a single subnet for all the virtual machines. This avoids potential network issues due to Defender network access policies, which may block some traffic between subnets due to a JIT access configuration.
  - Value `Subscription-Latest` for parameter `sharePointVersion` now installs the January 2025 CU for SharePoint Subscription

- All DSC configurations
  - Bumped DSC modules

- DSC Configuration for SPSE
  - Renamed root site to "root site"

- DSC Configuration for DC
  - Set the network interface as a private connection

## Enhancements & bug-fixes - Published in December 18, 2024

### Changed

- Template
  - Update the default size of the virtual machines to use the [Basv2 series](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/general-purpose/basv2-series?tabs=sizebasic). It is newer, cheaper and more performant than the [Bv1 series](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/general-purpose/bv1-series?tabs=sizebasic) used until now.
  - Value `Subscription-Latest` for parameter `sharePointVersion` now installs the December 2024 CU for SharePoint Subscription

## Enhancements & bug-fixes - Published in November 19, 2024

### Changed

- Template
  - Value `Subscription-Latest` for parameter `sharePointVersion` now installs the November 2024 CU for SharePoint Subscription

### Fixed

- Template
  - Stopped using the Windows Server's [small disk](https://azure.microsoft.com/en-us/blog/new-smaller-windows-server-iaas-image/) image for SharePoint Subscription VMs, as SharePoint updates no longer have enough free disk space to be installed.

## Enhancements & bug-fixes - Published in September 17, 2024

### Added

- Template
  - Add parameter `outboundAccessMethod`, to choose how the virtual machines connect to internet. Now, they can connect through either a public IP, or using Azure Firewall as an HTTP proxy
  - Add value `Subscription-24H1` to parameter `sharePointVersion`, to install SharePoint Subscription with 24H1 update
  - Add value `Subscription-24H2` to parameter `sharePointVersion`, to install SharePoint Subscription with 24H2 update

### Changed

- Template
  - Convert the template to Bicep
  - [BREAKING CHANGE] Rename most of the parameters
  - Update the display name of most of the resources to be more consistent and reflect their relationship with each other
  - Value `Subscription-Latest` for parameter `sharePointVersion` now installs the September 2024 CU for SharePoint Subscription
- All DSC configurations
  - Add a firewall rule to all virtual machines to allow remote event viewer connections
  - Updated DSC module `ActiveDirectoryDsc` to 6.4.0
  - Updated DSC module `ComputerManagementDsc` to 9.1.0
  - Updated DSC module `SharePointDSC` to 5.5.0
- DSC Configuration for DC
  - Updated DSC module `AdfsDsc` to 1.4.0

## Enhancements & bug-fixes - Published in February 26, 2024

### Changed

- Template
  - Value `Subscription-Latest` for parameter `sharePointVersion` now installs the February 2024 CU for SharePoint Subscription
  - Remove SharePoint 2013
- All SharePoint configurations
  - Add network share `SPLOGS` on folder `C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\LOGS`
- Configuration for SPSE
  - Update the registry keys required to allow OneDrive on OIDC authentication
  - Update claims provider to LDAPCPSE
  - It is no longer needed to restart the VM to be able to create the SPTrustedIdentityTokenIssuer, which saves a few minutes
- Configuration for SPLE
  - Update claims provider to LDAPCPSE
  - It is no longer needed to restart the VM to be able to create the SPTrustedIdentityTokenIssuer, which saves a few minutes

## Enhancements & bug-fixes - Published in December 18, 2023

### Changed

- Template
  - Value `Subscription-Latest` for parameter `sharePointVersion` now installs the December 2023 CU for SharePoint Subscription
  - Add a resource `runCommands` to run a script that increases MaxEnvelopeSizeKb on SPSE, so that service WS-Management in SPSE can process the bigger DSC script
- Configuration for SPSE
  - Add claim type groupsid to make the switch to SPTrustedBackedByUPAClaimProvider easier. There are remaining steps needed to finalize its configuration
- Configuration for SPSE and FESE
  - Set registry keys to configure OneDrive NGSC for OIDC authentication
  - Format the document

## Enhancements & bug-fixes - Published in November 16, 2023

### Changed

- Template
  - Value `Subscription-Latest` for parameter `sharePointVersion` now installs the November 2023 CU for SharePoint Subscription
- Configuration for SPSE
  - Configure the SPTrustedBackedByUPAClaimProvider (as much as possible). There are remaining steps needed to finalize its configuration
  - Update creation of user profiles to set their PreferredName
  - Format the document
- Configuration for most VMs
    - Bump DSC modules ActiveDirectoryDsc and SqlServerDsc

## Enhancements & bug-fixes - Published in October 12, 2023

### Changed

- Template
  - Value `Subscription-Latest` for parameter `sharePointVersion` now installs the October 2023 CU for SharePoint Subscription
- Configuration for SPSE
  - When doing a slipstream install of SharePoint using 2022-10 CU or newer: Fixed the SharePoint configuration wizard hanging at 10% of step 10/10, when executed after 

### Fixed
- All SharePoint configurations
  - Fixed regression with installation of Chocolatey

## Enhancements & bug-fixes - Published in September 13, 2023

### Changed

- Template
  - Added value `Subscription-23H2` to parameter `sharePointVersion`, to install SharePoint Subscription with 23H2 update
  - Value `Subscription-Latest` for parameter `sharePointVersion` now installs the September 2023 CU for SharePoint Subscription (23H2 update)

## Enhancements & bug-fixes - Published in August 21, 2023

### Fixed

- Configuration for SPSE
  - When doing a slipstream install of SharePoint using 2022-10 CU or newer: Fixed the SharePoint configuration wizard hanging at 10% of step 10/10, when executed after installing a CU

### Changed

- Template
  - Changed the prefix of the built-in administrator from `local-` to `l-` so it does not exceed 15 characters, because the reset password feature in Azure requires that it has 15 characters maximum.
  - Value `Subscription-Latest` for parameter `sharePointVersion` now installs the August 2023 CU for SharePoint Subscription

## Enhancements & bug-fixes - Published in June 30, 2023

### Fixed

- Configuration for SP Legacy and FE Legacy (SharePoint 2019 / 2016 / 2013 VMs)
  - Fixed the deployment error caused by DSC resource cChocoInstaller

## Enhancements & bug-fixes - Published in June 19, 2023

### Changed

- Template
  - Value `Subscription-Latest` for parameter `sharePointVersion` now installs the June 2023 CU for SharePoint Subscription
  - Updated SQL image to use SQL Server 2022 on Windows Server 2022.
- Configuration for all virtual machines
  - Update DSC module `ComputerManagementDsc`
- Configuration for all VMs except DC
  - Update DSC module `SqlServerDsc`
- Configuration for SPSE and FESE
  - Update DSC module `StorageDsc`

## Enhancements & bug-fixes - Published in June 02, 2023

### Changed

- Template
  - Value `Subscription-Latest` for parameter `sharePointVersion` now installs the May 2023 CU for SharePoint Subscription
- Configuration for DC
  - Update DSC module `AdfsDsc`

## Enhancements & bug-fixes - Published in April 12, 2023

### Fixed

- Template
  - The size of the OS disk is no longer hardcoded on SharePoint virtual machines, so now VMs for SharePoint Subscription and 2019 are really created with a 32 GB disk

### Changed

- Template
  - Value `Subscription-Latest` for parameter `sharePointVersion` now installs the April 2023 CU for SharePoint Subscription

## Enhancements & bug-fixes - Published in April 06, 2023

### Added

- Template
  - Added value `Subscription-23H1` to parameter `sharePointVersion`, to install SharePoint Subscription with 23H1 update

### Changed

- Configuration for SQL
  - Update SQL module `SqlServer` and DSC module `SqlServerDsc`
- Configuration for DC
  - Update DSC module `AdfsDsc`
- Configuration for all SharePoint versions
  - Update DSC module `SharePointDsc`
- Configuration for SharePoint Subscription
  - Add domain administrator as a SharePoint shell admin (done by cmdlet `Add-SPShellAdmin`)
  - For OIDC: Change the nonce secret key to a more unique value and rename the certificate used to sign the nonce

## Enhancements & bug-fixes - Published in February 07, 2023

### Added

- Template
  - Added value `Subscription-latest` to parameter `sharePointVersion`, to install the January 2023 CU on SharePoint Subscription
- Configuration for DC
  - Create additional users in AD, in a dedicated OU `AdditionalUsers`
- Configuration for SQL
  - Install SQL module `SqlServer` (version 21.1.18256) as it is the preferred option of `SqlServerDsc`
- Configuration for all SharePoint versions
  - Create various desktop shortcuts
  - Configure Windows explorer to always show file extensions and expand the ribbon
  - Enqueue the creation of the personal sites of the admin and all users in OU `AdditionalUsers`, for both Windows and trusted authentication modes
  - Add the OU `AdditionalUsers` to the User Profile synchronization connection
  - Grant the domain administrator `Full Control` to the User Profile service application
- Configuration for SharePoint Subscription and 2019
  - Set OneDrive NGSC registry keys to be able to sync sites located under MySites path

### Changed

- Template
  - Revert SQL image to SQL Server 2019, due to reliability issues with SQL Server 2022 (SQL PowerShell modules not ready yet)
  - If user chooses SharePoint 2013, template deploys SQL Server 2014 SP3 (latest version it supports)
- Configuration for DC
  - Review the logic to allow the VM to restart after the AD FS farm was configured (as required), and before the other VMs attempt to join the domain
- Configuration for all VMs except DC
  - Review the logic to join the AD domain only after it is guaranteed that the DC is ready. This fixes the most common cause of random deployment errors

## Enhancements & bug-fixes - Published in January 17, 2023

- Fix the json parsing error when deploying the template from the portal

## Enhancements & bug-fixes - Published in January 10, 2023

- Remove variable dnsLabelPrefix and use the resource group's name (formatted) instead in the DNS name of public IP resources.
- Use a small disk (32 GB) on SharePoint Subscription and SharePoint 2019 VMs.
- Updated SQL image to use SQL Server 2022 on Windows Server 2022.
- Now the resource group's name is used in the virtual network and the public IP resources, but it is formatted to handle the restrictions on the characters allowed.
- Apply browser policies for Edge and Chrome to get rid of noisy wizards / homepages / new tab content.
- No longer explicitly install Edge browser on Windows Server 2022 VMs as it is present by default.
- Reorganize the local template variables to be more consistent.
- In SharePoint VMs: Install Visual Studio Code as system install instead of as a portable zip package.
- In SharePoint VMs: Install Azure Data Studio.
- In SharePoint VMs: Install the latest version of Fiddler.
- Update apiVersion of ARM resources to latest version available.
- Update DSC modules to latest version available.

## Enhancements & bug-fixes - Published in November 28, 2022

- Renamed parameter `addPublicIPAddressToEachVM` to `addPublicIPAddress` and changed its type to `string` to provide more granularity. Its default value is now `"SharePointVMsOnly"`, to assign a public IP address only to SharePoint VMs
- Move the definition of SharePoint Subscription packages list from DSC to the template itself.
- Improve the logic that installs SharePoint updates when deploying SharePoint Subscription.
- Warm up SharePoint sites at the end of the configuration.
- Revert the previous change on the SKU of Public IP addresses, to use again SKU basic when possible (except for Bastion which requires Standard).
- Revert the previous change on the allocation method of Public IP addresses to use Dynamic instead of Static (except for Bastion which requires Static).
- Fixed the random error `NetworkSecurityGroupNotCompliantForAzureBastionSubnet` when deploying Azure Bastion by updating the rules in the network security group attached to Bastion's subnet.
- Update apiVersion of ARM resources to latest version available.
- Update DSC modules used to latest version available.
- Replace DSC module xDnsServer 2.0.0 with DnsServerDsc 3.0.0.

## Enhancements & bug-fixes - Published in September 29, 2022

- Add an option to create a SharePoint Subscription farm running with feature update 22H2.
- Use a gen2 image for SQL Server VM.
- Enable LDAPS (LDAP over SSL) on the Active Directory domain.
- Create a new AD user to run the directory synchronization, and grant it permission "Replicate Directory Changes".
- Create a synchronization connection in the User Profile Service.
- Change SKU of Public IP addresses to Standard, since Basic SKU will be retired
- Update apiVersion of ARM resources.
- Replace DSC module xWebAdministration 3.3.0 with WebAdministrationDsc 4.0.0.

## Enhancements & bug-fixes - Published in August 8, 2022

- In SP SE, import site certificate in SharePoint, so it can manage the certificate itself.
- Update LDAP security settings to mitigate CVE-2017-8563.
- Remove tags on resources, as they did not bring any particular value.
- Update network address to use the same as DevTest Labs templates.
- Update apiVersion of resources to latest version.
- Explicitly set the version of each DSC module used.
- Update DSC modules used to latest version available.
- Replace all resources xScript with Script and remove dependency on module xPSDesiredStateConfiguration.
- Revert the workaround related to decryption issue in DSC as regression was fixed in Windows.

## Enhancements & bug-fixes - Published in June 24, 2022

- Fix the credentials decryption issue in DSC extension when using latest version of Windows Server images.

## Enhancements & bug-fixes - Published in January 10, 2022

- Add SharePoint Server Subscription and make it the default choice.
- Change Windows image of VM DC to Windows Server 2022 Azure Edition.
- Change disk size of VM DC to 32 GB.
- Change image of VM SQL to SQL Server 2019 on Windows Server 2022.
- Change disk type of all virtual machines to StandardSSD_LRS.
- Update DSC module SharePointDSC from 4.8 to 5.0.
- Update DSC module ComputerManagementDsc from 8.4 to 8.5.

## Enhancements & bug-fixes - Published in October 4, 2021

- Improve reliability of DSC module cChoco, which caused most of the deployment errors.
- Fix deployment error in SharePoint 2013 by also restarting service SPAdminV4 before deploying the solution.

## Enhancements & bug-fixes - Published in September 13, 2021

- Fix the deployment error when parameter 'addPublicIPAddressToEachVM' is false and 'numberOfAdditionalFrontEnd' is greater than 0
- Change default size of virtual machines to use B-series burstable, ideal for such template and much cheaper than other comparable series.
- Change default storage type of SharePoint virtual machines to 'StandardSSD_LRS'.
- Change type of parameters to boolean when possible.
- Introduce new parameter 'RDPTrafficAllowed', to finely configure if/how RDP traffic should be allowed.
- Reorder parameters to have a more logical display when deploying the template from the portal.
- Update the list of disk types available for virtual machines.
- Improve management of automatic Windows updates
- Update apiVersion of all resources to latest version.
- Update DSC module SharePointDSC from 4.7 to 4.8, which no longer needs custom changes.
- Update DSC module SqlServerDsc from 15.1.1 to 15.2

## Enhancements & bug-fixes - Published in June 22, 2021

- Reduce deployment time by skipping creation of developer site /sites/dev, not so useful
- Reduce deployment time by enabling the distributed cache service during the SharePoint farm creation (in SP VM only)
- Reduce deployment time by running script UpdateGPOToTrustRootCACert only if necessary
- Install Visual Studio Code in SP and FE VMs
- Create modern team sites instead of classic team sites in SharePoint 2019
- Return various information as output of the template deployment
- Update TLS 1.2 settings in SP and FE VMs
- Enable file sharing (on Domain network profile) also on SQL VM (it is already enabled on SP and FE VMs)
- Update DSC module SharePointDSC from 4.5.1 to 4.7, removed the now useless dependency on ReverseDSC and manually added the changes in PR #1325
- Update DSC module xDnsServer from 1.16.0 to 2.0

## Enhancements & bug-fixes - Published in March 29, 2021

- Set local admin name on VM SQL/SP/FE with a unique string, to avoid using the local admin instead of the domain admin
- Set UserPrincipalName of all AD accounts
- Change the identity claim type to use the UPN in federated authentication
- Change the format of the realm / identifier in federated authentication
- Fix the reboot issue on SP and FE VMs when they join the AD domain
- Enable file sharing (on Domain network profile) on SP and FE VMs
- Setup an OIDC application in ADFS
- Add new SQL permissions to spsetup account to work with updated SPFarm resource
- Add a retry download logic to DSC resource cChocoInstaller to improve reliability
- Add AD CS and AD LDS RSAT to SP and FE configs
- Various improvements in DSC configurations
- Update apiVersion of ARM resources
- Replace outdated DSC module cADFS with AdfsDsc 1.1
- Update DSC module SharePointDSC from 4.3 to 4.5.1
- Update DSC module SqlServerDsc from 15.0 to 15.1.1
- Update DSC module NetworkingDsc from 8.1 to 8.2
- Update DSC module CertificateDsc from 4.7 to 5.1

## Enhancements & bug-fixes - Published in February 9, 2021

- Update DSC module cChoco from 2.4 to 2.5 to fix issue <https://github.com/chocolatey/cChoco/issues/151>

## Enhancements & bug-fixes - Published in December 10, 2020

- Update all Chocolatey packages to their latest version
- Remove ADFS service account from Administrators group
- Fix the duplicate SPN issue on MSSQLSvc service, which was on both the SQL computer and the SQL service account
- Set the SPN of SharePoint sites on the SharePoint application pool account
- Set property ProviderSignOutUri on resource SPTrustedIdentityTokenIssuer
- Update DSC module SqlServerDsc from 14.2.1 to 15.0

## Enhancements & bug-fixes - Published in October 13, 2020

- Set FrontEnd VMs with SharePoint MinRole Front-End on SharePoint versions that support MinRoles configuration
- Increase max numberOfAdditionalFrontEnd from 3 to 4
- Install Edge Chromium in SharePoint VM and Front-End VMs through Chocolatey
- Install Notepad++ in SharePoint VM and Front-End VMs through Chocolatey
- Install 7-zip in SharePoint VM and Front-End VMs through Chocolatey
- Install Fiddler in SharePoint VM and Front-End VMs through Chocolatey
- Install ULS Viewer in SharePoint VM and Front-End VMs through Chocolatey
- Install Chrome in Front-End VMs through Chocolatey
- Install Everything in Front-End VM through Chocolatey
- Define the list of all possible values for the time zone parameter vmsTimeZone
- Update WaitToAvoidServersJoiningFarmSimultaneously to ensure it runs only 1 time, and updated the delay from 60 to 90 secs to improve reliability
- Use a unique location for custom registry keys
- Update parameters passed to ConfigureFE
- Update DSC module SharePointDSC from 4.2 to 4.3
- Update DSC module NetworkingDsc from 8.0 to 8.1
- Update DSC module ActiveDirectoryCSDsc from 4.1 to 5.0
- Update DSC module xWebAdministration from 3.1.1 to 3.2
- Remove the workaround on the template validation error as the bug is fixed in the portal

## Enhancements & bug-fixes - Published in October 5, 2020

- Implement workaround to the template validation error when it is deployed from the portal and parameter numberOfAdditionalFrontEnd is set to 0

## Enhancements & bug-fixes - Published in October 2, 2020

- Replace parameter addFrontEndToFarm with numberOfAdditionalFrontEnd
- Add parameter numberOfAdditionalFrontEnd to set between 0 to 3 FE VMs to add to SharePoint farm
- Customize resource ComputerManagementDsc.Computer to trigger reboot of SharePoint VMs without error

## Enhancements & bug-fixes - Published in September 18, 2020

- Run SPDistributedCacheService as farm account instead of a different service account
- Disable IE Enhanced Security Configuration (ESC) on SharePoint VMs
- Disable the first run wizard of IE on SharePoint VMs
- Set new tabs to open "about:blank" in IE on SharePoint VMs
- Move resources to avoid error on ExtendMainWebApp
- Remove customization of SPDiagnosticLoggingSettings
- Update apiVersion of Microsoft.DevTestLab/schedules to 2018-10-15-preview

## September 2020 update

- Many modifications made to DSC scripts to improve their reliability, readability and consistency
- Create default SharePoint security groups on team site
- Ensure compliance with policy CASG-DenyNSGRule100Allow

## August 2020 update

- Fix timeout issue / DSC not resuming after VM reboot: Update dependencies of DSC extensions of SP and SQL, so they no longer depend on DSC of DC
- Update DSC on all VMs
- Replace DSC module xActiveDirectory with ActiveDirectoryDsc 6.0.1
- Update VM sizes to more recent, powerful and cheaper ones (prices per month in West US as of 2020-08-11):
  - DC: from [Standard_F4](https://docs.microsoft.com/azure/virtual-machines/sizes-previous-gen?toc=/azure/virtual-machines/linux/toc.json&bc=/azure/virtual-machines/linux/breadcrumb/toc.json) ($316.09) to [Standard_DS2_v2](https://docs.microsoft.com/azure/virtual-machines/dv2-dsv2-series) ($183.96)
  - SQL: from [Standard_D2_v2](https://docs.microsoft.com/azure/virtual-machines/dv2-dsv2-series) ($183.96) to [Standard_E2ds_v4](https://docs.microsoft.com/azure/virtual-machines/edv4-edsv4-series) ($185.42)
  - SP: from [Standard_D11_v2](https://docs.microsoft.com/azure/virtual-machines/dv2-dsv2-series-memory) ($192.72) to [Standard_E2ds_v4](https://docs.microsoft.com/azure/virtual-machines/edv4-edsv4-series) ($185.42)

## July 2020 update

- Update SQL to SQL Server 2019 on Windows Server 2019
- Add a network security group to Azure Bastion subnet
- Rename some resources and variables with more meaningful names
- Update apiVersion of each resource to latest version
- Update VM sizes to more recent, powerful and cheaper ones (prices per month in West US as of 2020-08-11):
  - DC: from [Standard_F4](https://docs.microsoft.com/azure/virtual-machines/sizes-previous-gen?toc=/azure/virtual-machines/linux/toc.json&bc=/azure/virtual-machines/linux/breadcrumb/toc.json) ($316.09) to [Standard_DS2_v2](https://docs.microsoft.com/azure/virtual-machines/dv2-dsv2-series) ($183.96)
  - SQL: from [Standard_D2_v2](https://docs.microsoft.com/azure/virtual-machines/dv2-dsv2-series) ($183.96) to [Standard_E2ds_v4](https://docs.microsoft.com/azure/virtual-machines/edv4-edsv4-series) ($185.42)
  - SP: from [Standard_D11_v2](https://docs.microsoft.com/azure/virtual-machines/dv2-dsv2-series-memory) ($192.72) to [Standard_E2ds_v4](https://docs.microsoft.com/azure/virtual-machines/edv4-edsv4-series) ($185.42)
- Update DSC module NetworkingDsc from 7.4 to 8.0
- Update DSC module xPSDesiredStateConfiguration from 8.10 to 9.1
- Update DSC module ActiveDirectoryCSDsc from 4.1 to 5.0
- Update DSC module xDnsServer from 1.15 to 1.16
- Update DSC module ComputerManagementDsc from 7.0 to 8.3
- Update DSC module SqlServerDsc from 13.2 to 14.1
- Update DSC module xWebAdministration from 2.8 to 3.1.1
- Update DSC module SharePointDSC from 3.6 to 4.2

## February 2020 update

- Fix deployment error caused by the new values of the SKU of SharePoint images, which changed from '2013' / '2016' / '2019' to 'sp2013' / 'sp2016' / 'sp2019'
- Update the schema of deploymentTemplate.json to latest version

## October 2019 update

- Add optional service Azure Bastion
- Add parameter addPublicIPAddressToEachVM to set if virtual machines should have a public IP address and be reachable from Internet. If set to No, no inbound traffic is allowed from Internet. If set to Yes, only RDP port is allowed.
- Replace SQL Server 2016 with SQL Server 2017
- Use SQL Server Developer edition instead of Standard edition. More info: <https://docs.microsoft.com/azure/virtual-machines/windows/sql/virtual-machines-windows-sql-server-pricing-guidance>
- Update DC to run with Windows Server 2019
- Change default sizes of virtual machines SQL and SP
- Update DSC module SharePointDSC from 3.5 (custom) to 3.6
- Update DSC module xPSDesiredStateConfiguration from 8.8 (custom) to 8.10
- Update DSC module NetworkingDsc from 7.3 to 7.4
- Update DSC module ActiveDirectoryCSDsc from 3.3 to 4.1
- Update DSC module xDnsServer from 1.13 to 1.15
- Update DSC module ComputerManagementDsc from 6.4 to 7.0
- Remove DSC module xPendingReboot, which is replaced by PendingReboot in ComputerManagementDsc 7.0
- Update DSC module SqlServerDsc from 13.0 to 13.2
- Update DSC module StorageDsc from 4.7 to 4.8
- Update DSC module xWebAdministration from 2.6 to 2.8

## July 2019 update

- Significantly improve reliability of the deployment by mitigating its main source of failures: Add a retry mechanism to resource xRemoteFile when the download fails.
- Completely configure SharePoint to host and run high-trust provider-hosted add-ins
- Configure LDAPCP to enable augmentation and remove unused claim types
- Add the certificate of the domain root authority to the SPTrustedRootAuthority
- Update apiVersion of all ARM resources to latest version
- Update some property descriptions in the ARM template
- Update DSC module SharePointDSC to 3.5
- Update DSC module xPSDesiredStateConfiguration to 8.8, with a customization on resource xRemoteFile to deal with random connection errors while downloading LDAPCP
- Update xActiveDirectory from 2.23 to 3.0
- Update NetworkingDsc from 6.3 to 7.3
- Update ActiveDirectoryCSDsc from 3.1 to 3.3
- Update CertificateDsc from 4.3 to 4.7
- Update xDnsServer from 1.11 to 1.13
- Update ComputerManagementDsc from 6.1 to 6.4
- Update SqlServerDsc from 12.2 to 13.0
- Update StorageDsc from 4.4 to 4.7

## February 2019 update

- Added SharePoint 2019
- Added option to enable Hybrid benefit for Windows Server licenses
- Added option to enable automatic Windows updates
- SharePoint VMs are now created with no data disk by default, but it can still be added by setting its size
- Updated SharePointDSC from 2.6 to 3.1, and added unreleased changes of [PR #997](https://github.com/PowerShell/SharePointDsc/pull/997) to fix SPDistributedCacheService error in SharePoint 2019
- Updated xActiveDirectory from 2.21 to 2.23
- Updated NetworkingDsc from 6.1 to 6.3
- Updated ActiveDirectoryCSDsc from 3.0 to 3.1
- Updated CertificateDsc from 4.2 to 4.3
- Updated ComputerManagementDsc from 5.2 to 6.1
- Updated SqlServerDsc from 12.0 to 12.2
- Updated StorageDsc from 4.0 to 4.4
- Updated xWebAdministration from 2.2 to 2.4

## November 2018 update

- MySites are now configured as host-named site collections
- Added a new host-named site collection
- App catalog is now correctly set
- Added missing SPN to enable Kerberos authentication to SQL Server
- Added a wildcard as AdditionalWSFedEndpoint in relying party in ADFS (to support HNSC)
- Added parameter AdditionalWSFedEndpoint on resource cADFSRelyingPartyTrust of DSC module cADFS
- Updated name of Azure resources
- Update API version of all resources
- Updated resource SPTrustedIdentityTokenIssuer in SharePointDSC 2.5 to support parameter UseWReplyParameter
- Updated SharePointDSC from 2.2 to 2.6
- Updated xDnsServer from 1.10 to 1.11
- Updated xActiveDirectory from 2.18 to 2.21
- Updated xPSDesiredStateConfiguration from 8.2 to 8.4
- Updated ActiveDirectoryCSDsc from 2.0 to 3.0
- Updated ComputerManagementDsc from 5.0 to 5.2
- Updated SqlServerDsc from 11.2 to 12.0
- Updated CertificateDsc from 4.0 to 4.2
- Updated xWebAdministration from 1.20 to 2.2
- Updated from xNetworking 5.7 to NetworkingDsc 6.1

## June 2018 update

- Removed SharePoint farm account from local administrators group as this is no longer necessary since SharePointDsc 2.2
- Removed the manual modification in resource xRemoteFile to use TLS 1.2. Fixed that issue properly by setting registry keys in DSC configuration instead
- SQL Server DatabaseEngine now runs with the SQL service account instead of the machine account
- Refresh GPOs to ensure CA root cert is present in "cert:\LocalMachine\Root\" before issuing a certificate request
- Moved all service accounts names from parameters to variables to simplify the template deployment form
- Updated SharePointDsc to 2.2
- Updated SqlServerDsc to 11.2
- Updated ComputerManagementDsc to 5.0
- Updated xCredSSP to 1.3
- Updated xNetworking to 5.7
- Updated xWebAdministration from 1.16 to 1.20
- Updated xPSDesiredStateConfiguration from 8.0 to 8.2
- Updated xDnsServer from 1.8 to 1.10
- Updated from xCertificate 2.8 to CertificateDsc 4.0
- Updated from xAdcsDeployment 1.1 to ActiveDirectoryCSDsc 2.0
- Updated xPendingReboot from 0.3 to 0.4
- Replaced xDisk and cDisk by StorageDsc 4.0

## April 4, 2018 update

- Force protocol TLS 1.2 in Invoke-WebRequest to fix TLS/SSL connection error with GitHub in Windows Server 2012 R2

## Jaunyary 2018 update

- Added network security groups to template, 1 per subnet
- VMs now use managed disks and can use a different storage account type (Standard_LRS / Standard_GRS / Premium_LRS)
- Change default VM size of SQL and SP VMs to improve performance
- By default SP and SQL VMs now run on a premium disk to improve performance
- Added option to automatically shutdown VMs at specified time
- Added option to provision a 2nd SharePoint VM to use as a Front End
- Added complete configuration of SharePoint apps, for both Default and Intranet zones
- HTTPS Certificate of ADFS site now has "Subject Alternative Names" field set
- Changed template of root site to be a team site, and moved dev site to /sites/dev
- Many changes to improve the reliability of DSC deployment of SP VM
- HTTPS Certificate of SharePoint site is now a wildcard and "Subject Alternative Names" field is set to support DNS zone of apps
- Added creation and configuration of SharePoint super user / super readers
- Simplified password management: now all service accounts use the same password. Admin account still has a separate password
- Moved VM names from parameters to variables to simplify creation form
- Updated SharePointDSC to 2.0.0.0
- Updated xDnsServer to 1.8.0.0

## September 2017 update

- Granted spsvc full control to UPA to allow newsfeeds to work properly
- Improved consistency of the template
- Added parameter dnsPrefix to specify the prefix of public DNS names of VMs

## August 2017 update

- Removed parameter templatePrefix as now name of storage and vnet resources are set from resource group name/id in the template
- Removed parameters to set public DNS name as they are now set from resource group name in the template
- Updated SharePointDsc to 1.8.0.0
- Updated xCertificate to 2.8.0.0 and replaced script timer with resource xWaitForCertificateServices

## June 2017.3 update

- Improved reliability of SharePoint solution deployment

## June 2017.2 update

- Added a custom script in DSC config of SP to ensure SQL is ready before it creates the farm

## June 2017 update

- Added ability to choose between SharePoint 2013 or 2016
- Updated SharePointDsc to 1.7
- Various improvements in SharePoint DSC configuration

## May 2017.2 update

- SQL machine name is retrieved dynamically in DSC configuration for SP
- Changed passwods settings so they never expire
- LDAPCP is downloaded from GitHub instead of Codeplex
- Default zone of web app now uses DNS alias too instead of machine name
- Updated xPSDesiredStateConfiguration from 6.0.0.0 to 6.4.0.0

## May 2017 update

- Simplified parameters passed to template
- Fixed a bug in SP DSC

## March 2017.3 update

- Azure Key Vault and its secrets are now created by the deployment script itself, removing the dependency to the PowerShell deployment script
- Removed nested templates

## March 2017.2 update

- Optimizations in PowerShell deployment script
- Parameters that must be unique in Azure were moved to parameters file and are no more set with a default value
- SP: Many improvements in DSC
- SP: DSC extends the web application with a HTTPS URL for federated authentication, creates DNS alias for intranet sites, sets the HTTPS certificate in IIS and sets ADFS administrator on each site collection
- Updated xCertificate module

## March 2017 update

- DC: DSC fully creates ADFS farm and add a relying party. It also exports signing certificate and signing certificate issuer in file system
- SP: DSC copies signing certificate and signing certificate issuer from DC to a local path, and uses it to create a SPLoginProvider object and establish trust relationship between SharePoint and DC
- SP: DSC populates more sites collections in web application
- SP: Use a custom version of SharePointDsc (from version 1.5.0.0) to update SPTrustedIdentityTokenIssuer resource to get signing certificate from file system. I started a [pull request](https://github.com/PowerShell/SharePointDsc/pull/520) to push those changes in standard module.
- Updated xNetworking to version 3.2.0.0
- Minor updates to clean code, improve consistency and make some settings working fine when they are not using default value (e.g. name of DC VM).

## February 2017 update

- Azure template now uses Azure Key Vault to store and use passwords, which forced the use of netsted templates to allow it to be dynamic
- Updated xActiveDirectory to version 2.16.0.0, which fixed the AD domain creation issue on Azure
