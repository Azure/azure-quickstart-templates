# Create an empty Azure Quantum workspace

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.quantum/azure-quantum-create/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.quantum/azure-quantum-create/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.quantum/azure-quantum-create/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.quantum/azure-quantum-create/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.quantum/azure-quantum-create/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.quantum/azure-quantum-create/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.quantum/azure-quantum-create/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.quantum%2Fazure-quantum-create%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.quantum%2Fazure-quantum-create%2Fazuredeploy.json)

This template deploys a **Azure Quantum workspace** into a given resource group.

## Sample overview and deployed resources

The deployed Azure Quantum workspace acts as a management container for quantum computing jobs you can submit to it. The template only deploys the Microsoft QIO provider, but you can add additional providers after the deployment.

The following resources are deployed as part of the solution:

### Azure Quantum workspace

An Azure Quantum workspace resource, or workspace for short, is a collection of assets associated with running quantum or optimization applications.

### Azure Storage account

An Azure storage account contains all of your Azure Storage data objects: blobs, files, queues, and tables. In context of this template, the account will be used to store input- and output-data for quantum jobs.

### RBAC Role assignment

As part of the deployment, the quantum workspace is granted **Contributor**-role to the Storage account. This is required for the workspace being able to store job data there.

## Prerequisites

You need the following prerequisites to run the deployment successfully.

An Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/free/).

You must be an **Owner** of the resource group you use, to create a new storage account. For more information about how resource groups work in Azure, see [Manage Azure Resource Manager resource groups by using the Azure portal](https://docs.microsoft.com/azure/azure-resource-manager/management/manage-resource-groups-portal).

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

`Tags: quantum, quantum computing, azure quantum`
