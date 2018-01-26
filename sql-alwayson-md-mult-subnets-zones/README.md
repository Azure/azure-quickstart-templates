# Create a SQL Server 2016 AlwaysOn Availability Group in an existing Azure VNET and Active Directory domain across AZ's and multiple subnets

This template will create a SQL Server 2016 AlwaysOn Availability Group using the PowerShell DSC Extension in an existing Azure Virtual Network and Active Directory environment. The SQL Server VMs will be provisioned across multiple Azure AZ's and multiple subnets (1 subnet per AZ).

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fresiliency%2Fmaster%2F301-sql-alwayson-md-az-mult-subnets-zones%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/>
</a>

## Deploying Sample Templates

You can deploy these samples directly through the Azure Portal or by using the scripts supplied in the root of the repo.

To deploy a sample using the Azure Portal, click the **Deploy to Azure** button found in the README.md of each sample.

To deploy the sample via the command line (using [Azure PowerShell or the Azure CLI](https://azure.microsoft.com/en-us/downloads/)) you can use the scripts.

Simple execute the script and pass in the folder name of the sample you want to deploy.  For example:

```PowerShell
.\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation 'eastus' -ArtifactsStagingDirectory '[foldername]'
```
```bash
azure-group-deploy.sh -a [foldername] -l eastus -u
```
If the sample has artifacts that need to be "staged" for deployment (Configuration Scripts, Nested Templates, DSC Packages) then set the upload switch on the command.
You can optionally specify a storage account to use, if so the storage account must already exist within the subscription.  If you don't want to specify a storage account
one will be created by the script or reused if it already exists (think of this as "temp" storage for AzureRM).

```PowerShell
.\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation 'eastus' -ArtifactsStagingDirectory '301-sql-alwayson-md-az-mult-subnets' -UploadArtifacts 
```
```bash
azure-group-deploy.sh -a '301-sql-alwayson-md-az-mult-subnets' -l eastus -u
```
Tags: ``cluster, ha, sql, alwayson``
