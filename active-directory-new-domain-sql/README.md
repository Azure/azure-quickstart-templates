# Deploy a two Domain Controller VM and MS SQL VM.

<a href= | https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Ftcsatheesh%2Fazure-quickstart-templates%2Fmaster%2Factive-directory-new-domain-sql%2Fazuredeploy.json |  target= | _blank | >
    <img src= | http://azuredeploy.net/deploybutton.png | />
</a>

Based on the https://github.com/Azure/azure-quickstart-templates/tree/master/windows-vm-custom-script and https://github.com/Azure/azure-quickstart-templates/tree/master/active-directory-new-domain-ha-2-dc

This template allows you to deploy a Windows VM (default name adPDC) with a new Active Directory forest/domain. This is done by Desired State Configuration (CreateADPDC.ps1.zip).
The second VM with SQL (default name adPDC) is configured powershell script (skrypt.ps1). The scripts must be in stored in a azure blob storage.

You can connect to the AD by Remote Desktop (by your domainName.location.cloudapp.azure.com eg.: armadsqltst.westeurope.cloudapp.azure.com).
Default username: adarmtest\adAdministrator
Default password (please change it, but please notice that the password, SQLusername, SQL installation file and adPDC IP is also hardcoded in skrypt.ps1): Pa##w0rd

adPDC priveate IP: 10.0.0.4
adSQL private IP: 10.0.0.5
AD FQDN: adarmtest.com

SQLUsername: adarmtest\adSQL

By The Way - skrypt.ps1 resolves two major powershell problems:
-run start-process with credential from system account (Access Denied) - just try do it via Invoke-Command
-install Microsoft SQL Server using remoting - just add -Authentication CredSSP 

Step by step to deploy this template:
1.	Download and install Azure PowerShell using Web Platform Installer - https://azure.microsoft.com/en-us/documentation/articles/powershell-install-configure/
2.	Run Azure PowerShell
3.	Switch-AzureMode -Name AzureResourceManager
4.	Add-AzureAccount (and enter credentials to your Azure Account)
5.	Download azuredeploy.json and save it in eg. C:\arm\
6.	New-AzureResourceGroup -Name arm10 -Location "West Europe" –TemplateFile C:\arm\azuredeploy.json -TemplateVersion "2014-04-01-preview" -DeploymentName arm10


IMPORTANT IMPORTANT IMPORTANT:
All parameters have default values, only * parameters are necessary.

| Name   | Description    |
|:--- |:---|
| newStorageAccountName* | The name of the new storage account created to store the VMs disks |
| storageAccountType | The type of the Storage Account created |
| location | The region to deploy the resources into |
| virtualNetworkName | The name of the Virtual Network to Create |
| virtualNetworkAddressRange | The address range of the new VNET in CIDR format |
| adSubnetName | The name of the subnet created in the new VNET |
| adSubnet | The address range of the subnet created in the new VNET |
| adPDCNicName | The name of the NIC attached to the new PDC |
| adPDCNicIPAddress | The IP address of the new AD PDC |
| adSQLNicName | The name of the NIC attached to the new SQL |
| adSQLNicIPAddress | The IP address of the new AD SQL |
| publicIPAddressName | The name of the public IP address used by the Load Balancer |
| publicIPAddressType | The type of the public IP address used by the Load Balancer |
| adPDCVMName | The computer name of the PDC |
| adSQLVMName | The computer name of the SQL |
| adminUsername | The name of the Administrator of the new VM and Domain |
| adminPassword | The password for the Administrator account of the new VM and Domain |
| adVMSize | The size of the VM Created |
| imagePublisher | Image Publisher |
| imageOffer | Image Offer |
| imageSKU | Image SKU |
| adAvailabilitySetName | The name of the availability set that the AD VM is created in |
| domainName* | The FQDN of the AD Domain created  |
| dnsPrefix | The DNS prefix for the public IP address used by the Load Balancer |
| pdcRDPPort | The public RDP port for the PDC VM |
| SQLRDPPort | The public RDP port for the SQL VM |
| scriptFile | The script file location for SQL VM |
| scriptName | Name of the script file for SQL VM |
| AssetLocation | The location of resources such as templates and DSC modules that the script is dependent |

