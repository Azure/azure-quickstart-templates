# Create a SQL Server 2016 AlwaysOn Availability Group in an existing Azure VNET and Active Directory domain across Availability Zones using an Internal Load Balancer

This template will create a SQL Server 2016 AlwaysOn Availability Group using the PowerShell DSC Extension in an existing Azure Virtual Network and Active Directory environment. The SQL Server VMs will be provisioned across multiple Azure Availability Zones and requests will be directed to the Listener using an Internal Load Balancer (ILB).

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsql-alwayson-md-ilb-zones%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/>
</a>

## Deploying Sample Templates

You can deploy these samples directly through the Azure Portal or by using the scripts supplied in the root of the repo.

To deploy a sample using the Azure Portal, click the **Deploy to Azure** button found in the README.md of each sample.

To deploy the sample via the command line (using [Azure PowerShell or the Azure CLI](https://azure.microsoft.com/en-us/downloads/)) you can use the scripts.

Simple execute the script and pass in the folder name of the sample you want to deploy.  For example:

```PowerShell
.\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation 'eastus2' -ArtifactsStagingDirectory '[foldername]'
```
```bash
azure-group-deploy.sh -a [foldername] -l eastus2 -u
```
If the sample has artifacts that need to be "staged" for deployment (Configuration Scripts, Nested Templates, DSC Packages) then set the upload switch on the command.
You can optionally specify a storage account to use, if so the storage account must already exist within the subscription.  If you don't want to specify a storage account
one will be created by the script or reused if it already exists (think of this as "temp" storage for AzureRM).

```PowerShell
.\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation 'eastus2' -ArtifactsStagingDirectory 'sql-alwayson-md-ilb-zones' -UploadArtifacts 
```
```bash
azure-group-deploy.sh -a 'sql-alwayson-md-ilb-zones' -l eastus2 -u
```
Tags: ``cluster, ha, sql, alwayson, availability zones``
