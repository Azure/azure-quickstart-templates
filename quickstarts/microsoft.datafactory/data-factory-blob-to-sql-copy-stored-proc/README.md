---
description: This template creates a data factory pipeline for a copy activity from Azure Blob into an Azure SQL Database while invoking a stored procedure
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: data-factory-blob-to-sql-copy-stored-proc
languages:
- json
---
# Create a Data Factory, Copy from Blob to SQL with Sproc

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datafactory/data-factory-blob-to-sql-copy-stored-proc/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datafactory/data-factory-blob-to-sql-copy-stored-proc/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datafactory/data-factory-blob-to-sql-copy-stored-proc/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datafactory/data-factory-blob-to-sql-copy-stored-proc/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datafactory/data-factory-blob-to-sql-copy-stored-proc/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datafactory/data-factory-blob-to-sql-copy-stored-proc/CredScanResult.svg)
This template creates a Data Factory pipeline that copies data from a file in a Blob Storage into a SQL Database table while invoking a [Stored Procedure](https://azure.microsoft.com/documentation/articles/data-factory-stored-proc-activity/) (SProc).

Please do the following steps before deploying the template:

1. Complete the prerequisites mentioned in [Overview and prerequisites](https://azure.microsoft.com/documentation/articles/data-factory-copy-data-from-azure-blob-storage-to-sql-database/) article.
2. Update values for the following parameters in **azuredeploy.parameters.json** file.
	1. storageAccountName
	2. storageAccountKey
	3. sqlServerName
	4. sqlDatabaseName
	5. sqlUserId
	6. sqlPassword
3. Create a Stored Procedure in your SQL Database. Run the following queries to align with the tutorial.

```
CREATE PROCEDURE spWriteEmployee READONLY
AS
BEGIN
	INSERT INTO [dbo].[emp](First, Last)
	VALUES  ('Bill', 'Gates')
END
```

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.datafactory%2Fdata-factory-blob-to-sql-copy-stored-proc%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.datafactory%2Fdata-factory-blob-to-sql-copy-stored-proc%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.datafactory%2Fdata-factory-blob-to-sql-copy-stored-proc%2Fazuredeploy.json)

<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-data-factory-blob-to-sql-stored-proc%2Fazuredeploy.json" target="_blank">

## Deploying sample
You can deploy this sample directly through the Azure Portal or by using the scripts supplied in the root of the repository.

To deploy a sample using the Azure Portal, click the **Deploy to Azure** button at the top of the article.

To deploy the sample via the command line (using [Azure PowerShell or the Azure CLI](https://azure.microsoft.com/downloads/)) you can use the scripts.

Simply execute the script from the root folder and pass in the folder name of the sample (101-data-factory-blob-to-sql-copy-stored-proc). For example:

```PowerShell
.\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation 'eastus' -ArtifactStagingDirectory 101-data-factory-blob-to-sql-copy-stored-proc
```
```bash
azure-group-deploy.sh -a 101-data-factory-blob-to-sql-copy-stored-proc -l eastus
```

`Tags: Microsoft.DataFactory/datafactories, linkedservices, AzureStorage, AzureSqlDatabase, datasets, AzureBlob, TextFormat, AzureSqlTable, dataPipelines, Copy, BlobSource, SqlSink, SqlServerStoredProcedure`
