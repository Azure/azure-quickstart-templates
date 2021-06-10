# Configure certificates for RDS deployment

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/rds/rds-update-certificate/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/rds/rds-update-certificate/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/rds/rds-update-certificate/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/rds/rds-update-certificate/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/rds/rds-update-certificate/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/rds/rds-update-certificate/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Frds%2Frds-update-certificate%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Frds%2Frds-update-certificate%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Frds%2Frds-update-certificate%2Fazuredeploy.json)
    

This Template allows you configure certificates in an RDS deployment.  
Remote Desktop Services require certificaties for
 server authentication, single sign-on (SSO), and to secure RDP connections.  
 For a good overview of certificates use in RDS see 
 [Configuring RDS 2012 Certificates and SSO](https://ryanmangansitblog.com/2013/03/10/configuring-rds-2012-certificates-and-sso/) and 
 [How to Create a (Mostly) Seamless Logon Experience For Your Remote Desktop Services Environment](http://www.rdsgurus.com/windows-2012-r2-how-to-create-a-mostly-seamless-logon-experience-for-your-remote-desktop-services-environment/) by RDS MVP Toby Phipps.

The Template makes use of a single SSL certificate. The certificate's Subject Name must match external DNS name of RD Gateway server in the deployment.  
The certificate with the private key (in .PFX format) must be stored in Azure Key Vault.  
For information on managing certificates with Azure Key Vault see:  [Get started with Azure Key Vault certificates](https://blogs.technet.microsoft.com/kv/2016/09/26/get-started-with-azure-key-vault-certificates/) and  
[Manage certificates via Azure Key Vault](https://blogs.technet.microsoft.com/kv/2016/09/26/manage-certificates-via-azure-key-vault/).

## Pre-Requisites

0. Template is intended to run against an existing RDS deployment. The deployment can be created using one of RDS QuickStart templates 
   ([Basic RDS Deployment Template](https://github.com/Azure/azure-quickstart-templates/tree/master/rds-deployment), or [RDS Deployment using existing VNET and AD](https://github.com/Azure/azure-quickstart-templates/tree/master/rds-deployment-existing-ad), etc.).

1. A certificate with the private key needs to be created (or acquired from CA) and imported to Azure Key Vault in tenant's subscription
	(see [Get started with Azure Key Vault](https://azure.microsoft.com/en-us/documentation/articles/key-vault-get-started)).
    Certificate's Subject Name should match external DNS name of the RDS Gateway server.

	For example, to import an existing certificate stored as a .pfx file on your local hard drive run the following PowerShell:
	```PowerShell
	$vaultName = "myVault"
	$certNameInVault = "certificate"    # cert name in vault, has to be '^[0-9a-zA-Z-]+$' pattern (digits, letters or dashes only, no spaces)
	$pfxFilePath = "c:\certificate.pfx"
	$password = "B@kedPotat0"           # password that was used to secure the pfx file at the time of export 

	Import-AzureKeyVaultCertificate -vaultname $vaultName -name $certNameInVault -filepath $pfxFilePath -password ($password | convertto-securestring -asplaintext -force)
	```
    Mark down 1) key vault name, and 2) certificate name in vault from this step - these will need to be supplied as input parameters to the Template.

2. A Service Principal account needs to be created with permissions to access certificates in the Key Vault
(see [Use Azure PowerShell to create a service principal to access resources](https://azure.microsoft.com/en-us/documentation/articles/resource-group-authenticate-service-principal/)).

	Sample powershell (alternatively you see Scripts\New-ServicePrincipal.ps1):
	```PowerShell
	$appPassword = "R@bberDuck"
	$uri = "https://www.contoso.com/script"   #  a valid formatted URL, not validated for single-tenant deployments
	$vaultName = "myVault"                    #  same key vault name as in step #1 above

	$app = New-AzureRmADApplication -DisplayName "script" -HomePage $uri -IdentifierUris $uri -password $appPassword
	$sp = New-AzureRmADServicePrincipal -ApplicationId $app.ApplicationId

	Set-AzureRmKeyVaultAccessPolicy -vaultname $vaultName -serviceprincipalname $sp.ApplicationId -permissionstosecrets get
	```

	Note: Certificates stored in Key Vault as secrets with content type 'application/x-pkcs12', this is why 
    `Set-AzureRmKeyVaultAccessPolivy` cmdlet grants `-PremissionsToSecrets` (rather than `-PermissionsToCertificates`).
    
    You will need 1) application id (`$app.ApplicationId`), and 2) the password from above step supplied as input parameters to the Template.  
	You will also need your tenant Id. To get tenant Id run the following powershell:
	```PowerShell
	$tenantId = (Get-AzureRmSubscription).TenantId | select -Unique
	```

## Running the Template

Template applies same certificate to all 4 roles in the deployment: `{ RDGateway | RDWebAccess | RDRedirector | RDPublishing }`.

Template performs the following steps:
+ downloads certificate from the key vault using Service Principal credentials;
+ invokes [Set-RDCertificate](https://technet.microsoft.com/en-us/library/jj215464.aspx) cmdlet to apply the certificate for each of the roles;
+ calls [Set-RDClientAccessName](https://technet.microsoft.com/en-us/library/jj215484.aspx) to update Client Access Name on RD Connection Broker to match the certificate.


