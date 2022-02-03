# Copy data from on-premises SQL Server to Azure Blob Storage

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datafactory/data-factory-v2-onprem-sql-to-blob-copy/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datafactory/data-factory-v2-onprem-sql-to-blob-copy/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datafactory/data-factory-v2-onprem-sql-to-blob-copy/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datafactory/data-factory-v2-onprem-sql-to-blob-copy/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datafactory/data-factory-v2-onprem-sql-to-blob-copy/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datafactory/data-factory-v2-onprem-sql-to-blob-copy/CredScanResult.svg)

[![Deploy to Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.datafactory%2Fdata-factory-v2-onprem-sql-to-blob-copy%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.datafactory%2Fdata-factory-v2-onprem-sql-to-blob-copy%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.datafactory%2Fdata-factory-v2-onprem-sql-to-blob-copy%2Fazuredeploy.json)

This template creates a data factory of version 2 with a pipeline that copies data from a table in an on-premises SQL Server database to a folder of a container in an Azure blob storage.  

When you deploy this Azure Resource Manager template, a data factory of version 2 is created with the following entities: 

- On-premises SQL Server linked service
- Azure Storage linked service 
- On-premises SQL Server input dataset
- Azure Blob output dataset
- Pipeline with a copy activity

## Prerequisites
The prerequisites for this template are mentioned in the [Tutorial: copy data from on-premises SQL Server database to Azure Blob Storage](https://docs.microsoft.com/en-us/azure/data-factory/tutorial-hybrid-copy-portal#prerequisites) article.

## Next steps
1. Click the **Deployment succeeded** message.
2. Click **Go to resource group**.
3. Search for *datafactory that's created. 
4. Select your data factory to launch the Data Factory page. 
5. Click **Author & Monitor** to launch the Data Factory UI application in a separate tab.
6. Click **Connections** at the bottom of the window.
7. Switch to the **Integration Runtimes** window.
8. Click the **Edit** (Pencil icon) for your self-hosted IR. 
9. Click the **Copy** button for **Key1** to copy the key to the clipboard. 
10. Install  the self-hosted integration runtime by following instructions in this article: [Install and register self-hosted IR from download center](https://docs.microsoft.com/en-us/azure/data-factory/create-self-hosted-integration-runtime#install-and-register-self-hosted-ir-from-download-center). Use the key you copied in the previous step to register the integration runtime.
11. Now, run and monitor the pipeline by using the steps in the [tutorial article](https://docs.microsoft.com/en-us/azure/data-factory/tutorial-hybrid-copy-portal#trigger-a-pipeline-run).




