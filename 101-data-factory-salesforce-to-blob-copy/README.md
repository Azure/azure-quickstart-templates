# Azure Data Factory Data Copy Activity
Update values for the following parameters in the **azuredeploy.parameters.json** file.

- storageAccountName with name of your Azure storage account.
- storageAccountKey with key of your Azure storage account. 
- SfUserName with name of the user who has access to Salesforce. 
- SfPassword with password of the user. 
- SfSecurityToken with security token for accessing Salesforce. 
- SfTable with table in Salesforce.
 
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-data-factory-blob-to-sql%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-data-factory-blob-to-sql%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

When you deploy this Azure Resource Template, a data factory is created with the following entities: 

- Azure Storage linked service
- Salesforce linked service
- Salesforce dataset
- Azure Blob dataset
- Pipeline with a copy activity

The copy activity in the pipeline copies data from Salesforce to Azure Blob Storage. 

## Deploy using PowerShell
1. Save files to C:\ADFGetStarted folder. 
2. Enter correct values for parameters in **azuredeploy.parameters.json**. 
2. Run the following command:
	
	New-AzureRmResourceGroupDeployment -Name MyARMDeployment -ResourceGroupName ADFTutorialResourceGroup -TemplateFile C:\ADFGetStarted\azuredeploy.json -TemplateParameterFile C:\ADFGetStarted\azuredeploy.parameters.json

See [Tutorial: Create a pipeline using Resource Manager Template](https://azure.microsoft.com/documentation/articles/data-factory-copy-activity-tutorial-using-azure-resource-manager-template/?rnd=1#create-data-factory) article for a detailed walkthrough with step-by-step instructions. 