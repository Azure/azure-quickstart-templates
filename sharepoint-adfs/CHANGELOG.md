# Change log for AzureRM template for SharePoint 2016 and 2013 configured with ADFS

## September 2017 release

* Granted spsvc full control to UPA to allow newsfeeds to work properly
* Improved consistency of the template
* Added parameter dnsPrefix to specify the prefix of public DNS names of VMs

## August 2017 release

* Removed parameter templatePrefix as now name of storage and vnet resources are set from resource group name/id in the template
* Removed parameters to set public DNS name as they are now set from resource group name in the template
* Updated SharePointDsc to 1.8.0.0
* Updated xCertificate to 2.8.0.0 and replaced script timer with resource xWaitForCertificateServices

## June 2017.3 release

* Improved reliability of SharePoint solution deployment

## June 2017.2 release

* Added a custom script in DSC config of SP to ensure SQL is ready before it creates the farm

## June 2017 release

* Added ability to choose between SharePoint 2013 or 2016
* Updated SharePointDsc to 1.7
* Various improvements in SharePoint DSC configuration

## May 2017.2 release

* SQL machine name is retrieved dynamically in DSC configuration for SP
* Changed passwods settings so they never expire
* LDAPCP is downloaded from GitHub instead of Codeplex
* Default zone of web app now uses DNS alias too instead of machine name
* Updated xPSDesiredStateConfiguration from 6.0.0.0 to 6.4.0.0

## May 2017 release

* Simplified parameters passed to template
* Fixed a bug in SP DSC

## March 2017.3 release

* Azure key vault and its secrets are now created by the deployment script itself, removing the dependency to the PowerShell deployment script
* Removed nested templates

## March 2017.2 release

* Optimizations in PowerShell deployment script
* Parameters that must be unique in Azure were moved to parameters file and are no more set with a default value
* SP: Many improvements in DSC
* SP: DSC extends the web application with a HTTPS URL for federated authentication, creates DNS alias for intranet sites, sets the HTTPS certificate in IIS and sets ADFS administrator on each site collection
* Updated xCertificate module

## March 2017 release

* DC: DSC fully creates ADFS farm and add a relying party. It also exports signing certificate and signing certificate issuer in file system
* SP: DSC copies signing certificate and signing certificate issuer from DC to a local path, and uses it to create a SPLoginProvider object and establish trust relationship between SharePoint and DC
* SP: DSC populates more sites collections in web application
* SP: Use a custom version of SharePointDsc (from version 1.5.0.0) to update SPTrustedIdentityTokenIssuer resource to get signing certificate from file system. I started a [pull request](https://github.com/PowerShell/SharePointDsc/pull/520) to push those changes in standard module.
* Updated xNetworking to version 3.2.0.0
* Minor updates to clean code, improve consistency and make some settings working fine when they are not using default value (e.g. name of DC VM).

## February 2017 release

* Azure template now uses Azure Key Vault to store and use passwords, which forced the use of netsted templates to allow it to be dynamic
* Updated xActiveDirectory to version 2.16.0.0, which fixed the AD domain creation issue on Azure
