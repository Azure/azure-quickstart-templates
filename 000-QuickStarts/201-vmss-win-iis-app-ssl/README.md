# Deployment of two Windows VMSS, configure windows features like IIS, .Net framework etc., download application deployment packages, URL Rewrite & SSL configuration using DSC

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vmss-win-iis-app-ssl%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/201-vmss-win-iis-app-ssl/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vmss-win-iis-app-ssl%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/201-vmss-win-iis-app-ssl/images/visualizebutton.png"/>
</a>

To deploy this template using the scripts from the root of this repo: 
```PowerShell

.\Deploy-AzureResourceGroup.ps1 -StorageAccountName '<artifacts storage account name>' -ResourceGroupName '<Resource guroup name>' -ResourceGroupLocation '<RG location>' -TemplateFile .\azuredeploy.json -TemplateParametersFile .\azuredeploy.parameters.json -ArtifactStagingDirectory '.' -DSCSourceFolder '.\dsc' -UploadArtifacts
```

This template deploys two Windows VMSSs, configure windows featurtes like IIS, .Net framework etc., download application deployment packages, URL Rewrite & SSL configuration using DSC. 

`Tags: Windows VMSS, VM Scale set, VM Scaleset, IIS, Windows features, SSL, Certificate, Cert, Key Vault, Azure, Azure Key Vault, Application deployment, WCF, Nested sites, Auto deploy, CICD`

## Solution overview and deployed resources

This template will create the following Azure resources
1) A VNet with two subnets. The VNet and the subnet IP prefixes are defined in the variables section i.e. appVnetPrefix, appVnetSubnet1Prefix & appVnetSubnet2Prefix respectively. Set these two accrodingly. <br/>
2) A NSG to allow http, https and rdp acces to the VMSS. The NSG is assigned to the subnets.<br/>
3) Two NICs, two Public IPs and two VMSSs with Windows Server 2012 R2<br/>
3.1) The first VMSS is used for hosting the WebSite and the 2nd VMSS is used for hosting the Services (WebAPI/WCF etc.)
3.2) The VMSSs are load banaced with Azure load balancers. The load balancers are configured to allow RDP access by port ranges 
3.3) The VMSSs are configured to auto scale based on CPU usage. The scaled out instances are automatically configured with Windows features, application deployment pacakges, SSL Certificates, the necessary IIS sites and SSL bindings <br/>
4) The 1st VMSS is deployed with a pfx certficate installed in the specified certificate store. The source of the certificate is stored in an Azure Key Vault<br/>
5) The DSC script configures various windows fetaures like IIS/Web Role, IIS Management service and tools, .Net Framework 4.5, Custom loggin, request monitoring, http tracking, windows auth, application initialization etc.<br/> 
6) DSC downloads Web Deploy 3.6 & URL Rewrite 2.0 and installs the modules<br/>
7) DSC downloads an application deployment package from an Azure Storage account and installs it in the default website <br/>
8) DSC finds the certificate from the local store and create a 443 binding <br/>
9) DSC creates the necessary rules so any incoming http traffic gets automatically redirected to the corresponding https end points<br/>


The following resources are deployed as part of the solution

#### A VNet with two subnet 
The VNet and the subnet IP prefixes are defined in the variables section i.e. appVnetPrefix, appVnetSubnet1Prefix & appVnetSubnet2Prefix respectively. Set these two accrodingly.

#### NSG to define the security rules
It defines the rules for http, https and rdp acces to the VMSS. The NSG is assigned to the subnets

#### Two NICs, two Public IPs and two VMSSs with Windows Server 2012 R2

#### Two Azure load balancers one each for the VMSSs

#### A Storage accounts for the VMSS as well as for the artifacts

## Prerequisites
1) You should have a custom domain ready and point the custome domain to the FQDN of the first public IP/Public IP for the Web Load balancer <br/>
2) SSL certificate: You should have a valid SSL certificate purchased from a CA or be self signed <br/>
3) Create an Azure KeyVault and upload the certificate to the KeyVault. Currently, Azure KeyVault supports certificates in pfx format. If the certificates are not in pfx format then import those to a windows cert store on a local machine and then export those to a pfx format with embeded private key and root certficate. <br/>

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

Script to upload the combined pfx certificate to an Azure Key Vault:(replace the values within '<>' before running the script)
$securepfxpwd = ConvertTo-SecureString –String '<strongpassword>' –AsPlainText –Force
$cer = Import-AzureKeyVaultCertificate -VaultName '<Azurekeyvaultname>' -Name '<CertStoreName>' -FilePath '<C:\myCerts\www_custDomain_com.pfx>' -Password $securepfxpwd
Set-AzureRmKeyVaultAccessPolicy -VaultName '<Azurekeyvaultname>' -UserPrincipalName '<udsarm@microsoft.com>' -PermissionsToCertificates all
