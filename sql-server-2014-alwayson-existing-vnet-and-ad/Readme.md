# Create an Always On Availability Group with SQL Server 2014 replica virtual machines in an existing Azure virtual network and an existing Active Directory instance

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsql-server-2014-alwayson-existing-vnet-and-ad%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsql-server-2014-alwayson-existing-vnet-and-ad%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

## Solution overview

This template uses the PowerShell DSC extension to deploy a fully configured Always On Availability Group with SQL Server 2014 replicas in an existing Azure Virtual Network and Active Directory environment.

This template creates the following resources:

+	3 Azure storage accounts
+	1 internal load balancer for the SQL Server replicas
    +   A SQL Server Always On listener is created using this internal load balancer
+	3 virtual machines in a Windows Server Cluster
    +    2 SQL Server 2014 Enterprise edition replicas with an availability group
    +    1 virtual machine is a File Share Witness for the Cluster
+	1 Availability Set for these 3 virtual machines
    +    configured with three Update Domains and three Fault Domains

For nested templates and DSC resources specific to SQL Server AlwaysOn, this template references these resources from this <a href="https://github.com/Azure/azure-quickstart-templates/tree/master/sql-server-2014-alwayson-dsc">SQL Server AlwaysOn AG QuickStart</a> template repository.

## Deploying from PowerShell

For details on how to install and configure Azure Powershell see [here].(https://azure.microsoft.com/en-us/documentation/articles/powershell-install-configure/)

Launch a PowerShell console

Ensure that you are in Resource Manager Mode

```PowerShell

Switch-AzureMode AzureResourceManager

```
Change working folder to the folder containing this template

```PowerShell

New-AzureResourceGroup -Name "<new resourcegroup name>" -Location "<new resourcegroup location>"  -TemplateParameterFile .\azuredeploy-parameters.json -TemplateFile .\azuredeploy.json

```
## Notable Variables

|Name|Description|
|:---|:---------------------|
|sqlLBName|Resource name of the SQL ILB|
|sqlAvailabilitySetName|Name for Azure availability set for SQL and Witness VMs|
|lbFE|Load balancer front-end pool name|
|lbBE|Load balancer back-endpool name|
|sqlWitnessSharePath|Shared folder name for Witness|
|windowsImagePublisher|The name of the pulisher of the AD and Witness Image|
|windowsImageOffer|The Offer Name for the Image used by AD and Witness VMs|
|windowsImageSKU|The Image SKU for the AD and Witness Image|
|sqlImagePublisher|The name of the pulisher of the SQL Image|
|sqlImageOffer|The Offer Name for the Image used by SQL|
|sqlImageSKU|The Image SKU for the SQL Image|
|windowsDiskSize|The size of the VHD allocated for AD and Witness VMs Data Disk|
|sqlDiskSize|The size of the VHD allocated for SQL VMs Data and Log Disks|

## Notes

+   The default settings for storage are to deploy using **premium storage**.  The SQL VMs use two P30 disks each (for both data and log).  These sizes can be changed by changing the relevant variables. In addition there is a P10 Disk used for each VM OS Disk.

+   The default settings for compute require that you have at least 9 cores of free quota to deploy.

+   The images used to create this deployment are
    +   SQL Server - Latest SQL Server 2014 on Windows Server 2012 R2 Image
    +   Witness - Latest Windows Server 2012 R2 Image

+   The image configuration is defined in variables - details below - but the scripts that configure this deployment have only been tested with these versions and may not work on other images.

+   To successfully deploy this template, be sure that the subnet to which the SQL VMs are being deployed already exists on the specified Azure virtual network, AND this subnet should be defined in Active Directory Sites and Services for the appropriate AD site in which the closest domain controllers are configured.

+ To deploy the required Azure VNET and Active Directory infrastructure, if not already in place, you may use <a href="https://github.com/Azure/azure-quickstart-templates/tree/master/active-directory-new-domain-ha-2-dc">this template</a>.

# Known Issues

This template is serial in nature for deploying some of the resources, due to some issues between the platform agent and the DSC extension which cause problems when multiple VM and\or extension resources are deployed concurrently.
