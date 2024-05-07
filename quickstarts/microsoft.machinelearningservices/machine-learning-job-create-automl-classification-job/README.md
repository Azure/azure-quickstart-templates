---
description: This template creates an Azure Machine Learning AutoML classification job to find out the best model for predicting if a client will subscribe to a fixed term deposit with a financial institution.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: machine-learning-job-create-automl-classification-job
languages:
- json
- bicep
---
# Create an Azure Machine Learning AutoML classification job

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/machine-learning-job-create-automl-classification-job/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/machine-learning-job-create-automl-classification-job/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/machine-learning-job-create-automl-classification-job/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/machine-learning-job-create-automl-classification-job/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/machine-learning-job-create-automl-classification-job/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/machine-learning-job-create-automl-classification-job/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/machine-learning-job-create-automl-classification-job/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.machinelearningservices%2Fmachine-learning-job-create-automl-classification-job%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.machinelearningservices%2Fmachine-learning-job-create-automl-classification-job%2Fazuredeploy.json)

### Overview

This template creates an Azure Machine Learning AutoML classification job to find out the best model for predicting if a client will subscribe to a fixed term deposit with a financial institution. See this tutorial for reference: [Tutorial](https://docs.microsoft.com/en-us/azure/machine-learning/tutorial-first-experiment-automated-ml).

### Prerequisites

To run this template you need to have an Azure Machine Learning Workspace and an Azure Machine Learning Compute Instance/Cluster. The template expects these as parameters: `workspaceName` and `computeName`. You can use the following samples to create these:

1. [Azure Machine Learning Workspace](https://docs.microsoft.com/en-us/samples/azure/azure-quickstart-templates/modules-machine-learning-workspace-0.9/)
2. [Azure Machine Learning Compute Instance](https://docs.microsoft.com/en-us/samples/azure/azure-quickstart-templates/machine-learning-compute-create-computeinstance/)

### Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

You may set `_artifactsLocation` parameter to `https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/quickstarts/microsoft.machinelearningservices/machine-learning-job-create-automl-classification-job/` to let the Azure Machine Learning Job use sample training and validation data.

### Notes

If you are new to Azure Machine Learning, see:

- [Azure Machine Learning service](https://azure.microsoft.com/services/machine-learning-service/)
- [Azure Machine Learning documentation](https://docs.microsoft.com/azure/machine-learning/)
- [Azure Machine Learning compute instance documentation](https://docs.microsoft.com/azure/machine-learning/concept-compute-instance)
- [Azure Machine Learning template reference](https://docs.microsoft.com/azure/templates/microsoft.machinelearningservices/allversions)
- [Quickstart templates](https://azure.microsoft.com/resources/templates/)

`Tags: Microsoft.MachineLearningServices/workspaces/jobs, Microsoft.MachineLearningServices/workspaces/computes, Microsoft.MachineLearningServices/workspaces, systemAssigned`
