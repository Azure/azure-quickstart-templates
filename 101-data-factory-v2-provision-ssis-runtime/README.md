# Provision Azure SSIS integration runtime 

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-data-factory-v2-provision-ssis-runtime/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-data-factory-v2-provision-ssis-runtime/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-data-factory-v2-provision-ssis-runtime/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-data-factory-v2-provision-ssis-runtime/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-data-factory-v2-provision-ssis-runtime/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-data-factory-v2-provision-ssis-runtime/CredScanResult.svg" />&nbsp;
This template creates a data factory of version 2, and then configures an Azure SSIS integration runtime in the cloud.  Then, you can use SQL Server Data Tools or SQL Server Management Studio to deploy SQL Server Integration Services (SSIS) packages to this runtime on Azure. 

The prerequisites for this template are mentioned in the [Tutorial: Provision Azure SSIS integration runtime](https://docs.microsoft.com/en-us/azure/data-factory/tutorial-deploy-ssis-packages-azure#prerequisites) article.


<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-data-factory-v2-provision-ssis-runtime%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-data-factory-v2-provision-ssis-runtime" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

When you deploy this Azure Resource Manager template, a data factory of version 2 is created with an Azure SSIS integration runtime. It also creates the SSIS Catalog (SSISDB) database in the Azure SQL database you specify as an argument. 
 

## Next steps
1. Click the **Deployment succeeded** message.
2. Click **Go to resource group**.
3. Search for *datafactory that's created. 
4. See [Provision Azure SSIS integration runtime](https://docs.microsoft.com/en-us/azure/data-factory/tutorial-create-azure-ssis-runtime-portal#provision-an-azure-ssis-integration-runtime) section to navigate to the Integration Runtimes page. 
5. Start/stop the integration runtime as needed. 

