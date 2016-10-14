# Copy data from Azure Blob Storage to Azure SQL Db with Stored Procedure
This template creates a Data Factory pipeline that copies data from a file in a Blob Storage into a SQL Database table while invoking a [Stored Procedure](https://azure.microsoft.com/en-us/documentation/articles/data-factory-stored-proc-activity/) (SProc). 

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

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-data-factory-blob-to-sql-copy-stored-proc%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-data-factory-blob-to-sql-stored-proc%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

## Deploy using PowerShell
1. Save files to C:\ADFGetStarted folder. 
2. Enter correct values for parameters in **azuredeploy.parameters.json**. 
2. Run the following command:
	
		New-AzureRmResourceGroupDeployment -Name MyARMDeployment -ResourceGroupName ADFTutorialResourceGroup -TemplateFile C:\ADFGetStarted\azuredeploy.json -TemplateParameterFile C:\ADFGetStarted\azuredeploy.parameters.json

See [Tutorial: Create a pipeline using Resource Manager Template](https://azure.microsoft.com/documentation/articles/data-factory-copy-activity-tutorial-using-azure-resource-manager-template/?rnd=1#create-data-factory)  article for a detailed walkthrough with step-by-step instructions.