# Copy data from one folder to another folder in an Azure Blob Storage

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datafactory/data-factory-v2-transform-using-spark/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datafactory/data-factory-v2-transform-using-spark/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datafactory/data-factory-v2-transform-using-spark/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datafactory/data-factory-v2-transform-using-spark/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datafactory/data-factory-v2-transform-using-spark/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datafactory/data-factory-v2-transform-using-spark/CredScanResult.svg)
This template creates a data factory of version 2 with a pipeline that copies data from one folder to another in an Azure Blob Storage. 

Here are a few important points about the template: 

- The prerequisites for this template are mentioned in the [Quickstart: Create a data factory by using Azure PowerShell](https://docs.microsoft.com/azure/data-factory/quickstart-create-data-factory-powershell#prerequisites) article.
- Note that currently data factories of version 2 can only be created in **East US** and **East US 2** regions. 

[![Deploy to Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.datafactory%2Fdata-factory-v2-transform-using-spark%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.datafactory%2Fdata-factory-v2-transform-using-spark%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.datafactory%2Fdata-factory-v2-transform-using-spark%2Fazuredeploy.json)

When you deploy this Azure Resource Manager template, a data factory of version 2 is created with the following entities: 

- Azure Storage linked service
- Azure Blob datasets (input and output)
- Pipeline with a copy activity

## To get the name of the data factory
1. Click the **Deployment succeeded** message.
2. Click **Go to resource group**.
3. Search for **ADFTutorialResourceGroup0927&lt;unique string&gt;**

The following sections provide steps for running and monitoring the pipeline. For more information, see [Quickstart: Create a data factory by using Azure PowerShell](https://docs.microsoft.com/azure/data-factory/quickstart-create-data-factory-powershell).

## Run and monitor the pipeline
After you deploy the template, to run and monitor the pipeline, do the following steps: 

1. Download [runmonitor.ps1](https://github.com/Azure/azure-quickstart-templates/tree/master/101-data-factory-v2-blob-to-blob-copy/scripts) to a folder on your machine.
2. Launch Azure PowerShell.
3.  Run the following command to log in to Azure. 

	```powershell
	Login-AzureRmAccount
	```
4. Switch to the folder where you copied the script file. 
5. Run the following command to log in to Azure after specifying the names of your Azure resource group and the data factory. 

	```powershell
	.\runmonitor.ps1 -resourceGroupName "<name of your resource group>" -DataFactoryName "<name of your data factory>"
	```



