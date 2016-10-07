# Azure Data Factory Data Copy Activity

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-data-factory-blob-to-sql%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-data-factory-blob-to-sql%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template creates a very simple Data Factory pipeline that copies data from a file in a Blob Storage into a SQL Database table. Prior to  executing this make sure you have a Storage Account and a SQL Database provisioned. 

## Prerequisites:

- See [Overview and prerequisites](https://azure.microsoft.com/documentation/articles/data-factory-copy-data-from-azure-blob-storage-to-sql-database/) for the list of prerequisites.


## Deploy using PowerShell
1. Enter right values for parameters in the **azuredeploy.parameters.json**. 
2. See [Deploy Data Factory entities](https://azure.microsoft.com/documentation/articles/data-factory-copy-activity-tutorial-using-azure-resource-manager-template/?rnd=1#create-data-factory). Run the following command:
	
	New-AzureRmResourceGroupDeployment -Name MyARMDeployment -ResourceGroupName ADFTutorialResourceGroup -TemplateFile C:\ADFGetStarted\azuredeploy.json -TemplateParameterFile C:\ADFGetStarted\azuredeploy.parameters.json