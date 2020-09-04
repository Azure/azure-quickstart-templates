# Create a SQL Server AlwaysOn Availability Group in an existing Azure VNET and Active Directory domain across Availability Zones using an Internal Load Balancer

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/301-sql-alwayson-md-ilb-zones/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/301-sql-alwayson-md-ilb-zones/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/301-sql-alwayson-md-ilb-zones/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/301-sql-alwayson-md-ilb-zones/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/301-sql-alwayson-md-ilb-zones/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/301-sql-alwayson-md-ilb-zones/CredScanResult.svg)

*Tests executed on 11/18/2019 show this template is working fine on Azure Public, despite the status of the above badges. You need to provision an AD domain and a virtual network with correct DSN resolution for domain names.*

This template will create a SQL Server AlwaysOn Availability Group using the PowerShell DSC Extension in an existing Azure Virtual Network and Active Directory environment. Both SQL Server 2016 and SQL Server 2017 are supported by this template. The SQL Server VMs will be provisioned across multiple Azure Availability Zones and requests will be directed to the Listener using the Internal Load Balancer (ILB) Standard.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F301-sql-alwayson-md-ilb-zones%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F301-sql-alwayson-md-ilb-zones%2Fazuredeploy.json)

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
.\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation 'eastus2' -ArtifactsStagingDirectory '301-sql-alwayson-md-ilb-zones' -UploadArtifacts 
```
```bash
azure-group-deploy.sh -a '301-sql-alwayson-md-ilb-zones' -l eastus2 -u
```
Tags: ``cluster, ha, sql, sql server 2016, sql server 2017, alwayson, availability zones``


