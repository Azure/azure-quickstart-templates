# Change log for AzureRM template for SharePoint 2016 and 2013 configured with ADFS

## November 2018 update

* MySites are now configured as host-named site collections
* Added a new host-named site collection
* App catalog is now correctly set
* Added missing SPN to enable Kerberos authentication to SQL Server
* Added a wildcard as AdditionalWSFedEndpoint in relying party in ADFS (to support HNSC)
* Added parameter AdditionalWSFedEndpoint on resource cADFSRelyingPartyTrust of DSC module cADFS
* Updated name of Azure resources
* Update API version of all resources
* Updated resource SPTrustedIdentityTokenIssuer in SharePointDSC 2.5 to support parameter UseWReplyParameter
* Updated SharePointDSC from 2.2 to 2.6
* Updated xDnsServer from 1.10 to 1.11
* Updated xActiveDirectory from 2.18 to 2.21
* Updated xPSDesiredStateConfiguration from 8.2 to 8.4
* Updated ActiveDirectoryCSDsc from 2.0 to 3.0
* Updated ComputerManagementDsc from 5.0 to 5.2
* Updated SqlServerDsc from 11.2 to 12.0
* Updated CertificateDsc from 4.0 to 4.2
* Updated xWebAdministration from 1.20 to 2.2
* Updated from xNetworking 5.7 to NetworkingDsc 6.1

## June 2018 update

* Removed SharePoint farm account from local administrators group as this is no longer necessary since SharePointDsc 2.2
* Removed the manual modification in resource xRemoteFile to use TLS 1.2. Fixed that issue properly by setting registry keys in DSC configuration instead
* SQL Server DatabaseEngine now runs with the SQL service account instead of the machine account
* Refresh GPOs to ensure CA root cert is present in "cert:\LocalMachine\Root\" before issuing a certificate request
* Moved all service accounts names from parameters to variables to simplify the template deployment form
* Updated SharePointDsc to 2.2
* Updated SqlServerDsc to 11.2
* Updated ComputerManagementDsc to 5.0
* Updated xCredSSP to 1.3
* Updated xNetworking to 5.7
* Updated xWebAdministration from 1.16 to 1.20
* Updated xPSDesiredStateConfiguration from 8.0 to 8.2
* Updated xDnsServer from 1.8 to 1.10
* Updated from xCertificate 2.8 to CertificateDsc 4.0
* Updated from xAdcsDeployment 1.1 to ActiveDirectoryCSDsc 2.0
* Updated xPendingReboot from 0.3 to 0.4
* Replaced xDisk and cDisk by StorageDsc 4.0

## April 4, 2018 update

* Force protocol TLS 1.2 in Invoke-WebRequest to fix TLS/SSL connection error with GitHub in Windows Server 2012 R2

## Jaunyary 2018 update

* Added network security groups to template, 1 per subnet
* VMs now use managed disks and can use a different storage account type (Standard_LRS / Standard_GRS / Premium_LRS)
* Change default VM size of SQL and SP VMs to improve performance
* By default SP and SQL VMs now run on a premium disk to improve performance
* Added option to automatically shutdown VMs at specified time
* Added option to provision a 2nd SharePoint VM to use as a Front End
* Added complete configuration of SharePoint apps, for both Default and Intranet zones
* HTTPS Certificate of ADFS site now has "Subject Alternative Names" field set
* Changed template of root site to be a team site, and moved dev site to /sites/dev
* Many changes to improve the reliability of DSC deployment of SP VM
* HTTPS Certificate of SharePoint site is now a wildcard and "Subject Alternative Names" field is set to support DNS zone of apps
* Added creation and configuration of SharePoint super user / super readers
* Simplified password management: now all service accounts use the same password. Admin account still has a separate password
* Moved VM names from parameters to variables to simplify creation form
* Updated SharePointDSC to 2.0.0.0
* Updated xDnsServer to 1.8.0.0

## September 2017 update

* Granted spsvc full control to UPA to allow newsfeeds to work properly
* Improved consistency of the template
* Added parameter dnsPrefix to specify the prefix of public DNS names of VMs

## August 2017 update

* Removed parameter templatePrefix as now name of storage and vnet resources are set from resource group name/id in the template
* Removed parameters to set public DNS name as they are now set from resource group name in the template
* Updated SharePointDsc to 1.8.0.0
* Updated xCertificate to 2.8.0.0 and replaced script timer with resource xWaitForCertificateServices

## June 2017.3 update

* Improved reliability of SharePoint solution deployment

## June 2017.2 update

* Added a custom script in DSC config of SP to ensure SQL is ready before it creates the farm

## June 2017 update

* Added ability to choose between SharePoint 2013 or 2016
* Updated SharePointDsc to 1.7
* Various improvements in SharePoint DSC configuration

## May 2017.2 update

* SQL machine name is retrieved dynamically in DSC configuration for SP
* Changed passwods settings so they never expire
* LDAPCP is downloaded from GitHub instead of Codeplex
* Default zone of web app now uses DNS alias too instead of machine name
* Updated xPSDesiredStateConfiguration from 6.0.0.0 to 6.4.0.0

## May 2017 update

* Simplified parameters passed to template
* Fixed a bug in SP DSC

## March 2017.3 update

* Azure key vault and its secrets are now created by the deployment script itself, removing the dependency to the PowerShell deployment script
* Removed nested templates

## March 2017.2 update

* Optimizations in PowerShell deployment script
* Parameters that must be unique in Azure were moved to parameters file and are no more set with a default value
* SP: Many improvements in DSC
* SP: DSC extends the web application with a HTTPS URL for federated authentication, creates DNS alias for intranet sites, sets the HTTPS certificate in IIS and sets ADFS administrator on each site collection
* Updated xCertificate module

## March 2017 update

* DC: DSC fully creates ADFS farm and add a relying party. It also exports signing certificate and signing certificate issuer in file system
* SP: DSC copies signing certificate and signing certificate issuer from DC to a local path, and uses it to create a SPLoginProvider object and establish trust relationship between SharePoint and DC
* SP: DSC populates more sites collections in web application
* SP: Use a custom version of SharePointDsc (from version 1.5.0.0) to update SPTrustedIdentityTokenIssuer resource to get signing certificate from file system. I started a [pull request](https://github.com/PowerShell/SharePointDsc/pull/520) to push those changes in standard module.
* Updated xNetworking to version 3.2.0.0
* Minor updates to clean code, improve consistency and make some settings working fine when they are not using default value (e.g. name of DC VM).

## February 2017 update

* Azure template now uses Azure Key Vault to store and use passwords, which forced the use of netsted templates to allow it to be dynamic
* Updated xActiveDirectory to version 2.16.0.0, which fixed the AD domain creation issue on Azure
