# Provision Azure SSIS Integration Runtime

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datafactory/data-factory-v2-provision-ssis-runtime/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datafactory/data-factory-v2-provision-ssis-runtime/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datafactory/data-factory-v2-provision-ssis-runtime/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datafactory/data-factory-v2-provision-ssis-runtime/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datafactory/data-factory-v2-provision-ssis-runtime/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datafactory/data-factory-v2-provision-ssis-runtime/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.datafactory%2Fdata-factory-v2-provision-ssis-runtime%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.datafactory%2Fdata-factory-v2-provision-ssis-runtime%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.datafactory%2Fdata-factory-v2-provision-ssis-runtime%2Fazuredeploy.json)

This template creates a data factory of version 2, and then configures an Azure SSIS integration runtime in the cloud.  Then, you can use SQL Server Data Tools or SQL Server Management Studio to deploy SQL Server Integration Services (SSIS) packages to this runtime on Azure.

The prerequisites for this template are mentioned in the [Tutorial: Provision Azure SSIS integration runtime](https://docs.microsoft.com/en-us/azure/data-factory/tutorial-deploy-ssis-packages-azure#prerequisites) article.

When you deploy this Azure Resource Manager template, a data factory of version 2 is created with an Azure SSIS integration runtime. It also creates the SSIS Catalog (SSISDB) database in the Azure SQL database you specify as an argument.

## Next steps

1. Click the **Deployment succeeded** message.
2. Click **Go to resource group**.
3. Search for *datafactory that's created.
4. See [Provision Azure SSIS integration runtime](https://docs.microsoft.com/en-us/azure/data-factory/tutorial-create-azure-ssis-runtime-portal#provision-an-azure-ssis-integration-runtime) section to navigate to the Integration Runtimes page.
5. Start/stop the integration runtime as needed.
