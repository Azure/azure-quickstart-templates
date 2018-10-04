# Copy data from on-premises SQL Server to Azure Blob Storage
This template creates a data factory of version 2 with a pipeline that copies data from a table in an on-premises SQL Server database to a folder of a container in an Azure blob storage.  

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-data-factory-v2-blob-to-sql-copy%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-data-factory-v2-blob-to-sql-copy" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

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


