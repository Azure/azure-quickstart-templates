# Azure Data Factory to copy data from Salesforce to Azure Blobs

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-data-factory-salesforce-to-blob-copy/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-data-factory-salesforce-to-blob-copy/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-data-factory-salesforce-to-blob-copy/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-data-factory-salesforce-to-blob-copy/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-data-factory-salesforce-to-blob-copy/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-data-factory-salesforce-to-blob-copy/CredScanResult.svg" />&nbsp;
Update values for the following parameters in **azuredeploy.parameters.json** file.

- storageAccountName with name of your existing Azure storage account.
- storageAccountKey with key to your existing your Azure storage account. 
- SfUserName with the username to your Salesforce account. 
- SfPassword with password corresponding to the Salesforce account. 
- SfSecurityToken with security token for accessing Salesforce account. 
- SfTable with object in Salesforce that should be copied over.
 
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-data-factory-salesforce-to-blob-copy%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-data-factory-salesforce-to-blob-copy%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

When you deploy this Azure Resource Template, an Azure Data Factory instance is created with the following entities: 

- Salesforce linked service
- Azure Storage linked service
- Salesforce dataset
- Azure Blob dataset
- Pipeline with a copy activity

The copy activity in the pipeline copies data from the Salesforce object to Azure Blob Storage. 

## Deploy using PowerShell
1. Save files to C:\ADFGetStarted folder. 
2. Enter correct values for parameters in **azuredeploy.parameters.json**. 
2. Run the following command:
	
	New-AzureRmResourceGroupDeployment -Name MyARMDeployment -ResourceGroupName ADFTutorialResourceGroup -TemplateFile C:\ADFGetStarted\azuredeploy.json -TemplateParameterFile C:\ADFGetStarted\azuredeploy.parameters.json

See [Tutorial: Create a pipeline using Resource Manager Template](https://azure.microsoft.com/documentation/articles/data-factory-copy-activity-tutorial-using-azure-resource-manager-template/?rnd=1#create-data-factory) article for a detailed walkthrough with step-by-step instructions. 

