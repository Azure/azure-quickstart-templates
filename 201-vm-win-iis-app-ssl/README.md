# Deployment of a Windows VM, configure windows featurtes like IIS, .Net framework etc., download application deployment packages, URL Rewrite & SSL configuration using DSC

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-win-iis-app-ssl%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/201-vm-win-iis-app-ssl/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-win-iis-app-ssl%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/201-vm-win-iis-app-ssl/images/visualizebutton.png"/>
</a>

To deploy this template using the scripts from the root of this repo: 
```PowerShell

.\Deploy-AzureResourceGroup.ps1 -StorageAccountName '<artifacts storage account name>' -ResourceGroupName '<Resource guroup name>' -ResourceGroupLocation '<RG location>' -TemplateFile .\azuredeploy.json -TemplateParametersFile .\azuredeploy.parameters.json -ArtifactStagingDirectory '.' -DSCSourceFolder '.\dsc' -UploadArtifacts
```

This template deploys a  Windows VM, configure windows featurtes like IIS, .Net framework etc., download application deployment packages, URL Rewrite & SSL configuration using DSC. 

`Tags: Windows VM, IIS, Windows features, SSL, Certificate, Key Vault, Azure, Azure Key Vault, Application deployment`

## Solution overview and deployed resources

This template will create the following Azure resources
1) A VNet with a single subnet. The VNet and the subnet IP prefixes are defined in the variables section i.e. appVnetPrefix & appVnetSubnet1Prefix respectively. Set these two accrodingly. <br/>
2) A NSG to allow http, https and rdp acces to the VM. The NSG is assigned to the subnet.<br/>
3) A NIC, a Public IP and a VM with Windows Server 2012 R2<br/>
4) The VM is deployed with a pfx certficate installed in the specified certificate store. The source of the certificate is stored in an Azure Key Vault<br/>
5) The DSC script configures various windows fetaures like IIS/Web Role, IIS Management service and tools, .Net Framework 4.5, Custom loggin, request monitoring, http tracking, windows auth, application initialization etc.<br/> 
6) DSC downloads Web Deploy 3.6 & URL Rewrite 2.0 and installs the modules<br/>
7) DSC downloads an application deployment package from an Azure Storage account and installs it in the default website <br/>
8) DSC finds the certificate from the local store and create a 443 binding <br/>
9) DSC creates the necessary rules so any incoming http traffic gets automatically redirected to the corresponding https end points<br/>


The following resources are deployed as part of the solution

#### A VNet with a single subnet 
The VNet and the subnet IP prefixes are defined in the variables section i.e. appVnetPrefix & appVnetSubnet1Prefix respectively. Set these two accrodingly.

#### NSG to define the security rules
It defines the rules for http, https and rdp acces to the VM. The NSG is assigned to the subnet

#### A NIC, a Public IP and a VM with Windows Server 2012 R2

#### A Storage account for the VM as well as for the artifacts

## Prerequisites
1) You should have a custom domain ready and point the custome domain to the FQDN of the public IP <br/>
2) SSL certificate: You should have a valid SSL certificate purchased from a CA or be self signed <br/>
3) Create an Azure KeyVault and upload the certificate to the KeyVault. Currently, Azure KeyVault supports certificates in pfx format. If the certificates are not in pfx format then import those to a windows cert store on a local machine and then export those to a pfx format with embeded private key and root certficate. <br/>

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

Script to upload the combined pfx certificate to an Azure Key Vault:(replace the values within '<>' before running the script)
$securepfxpwd = ConvertTo-SecureString –String '<strongpassword>' –AsPlainText –Force
$cer = Import-AzureKeyVaultCertificate -VaultName '<Azurekeyvaultname>' -Name '<CertStoreName>' -FilePath '<C:\myCerts\www_custDomain_com.pfx>' -Password $securepfxpwd
Set-AzureRmKeyVaultAccessPolicy -VaultName '<Azurekeyvaultname>' -UserPrincipalName '<udsarm@microsoft.com>' -PermissionsToCertificates all
