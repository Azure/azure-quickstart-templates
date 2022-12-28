---
description: This template creates an Azure Machine Learning Sweep job for hyperparameter tuning.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: machine-learning-job-create-sweep-job
languages:
- json
- bicep
---
# Create an Azure Machine Learning Sweep job

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/machine-learning-job-create-sweep-job/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/machine-learning-job-create-sweep-job/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/machine-learning-job-create-sweep-job/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/machine-learning-job-create-sweep-job/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/machine-learning-job-create-sweep-job/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/machine-learning-job-create-sweep-job/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/machine-learning-job-create-sweep-job/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.machinelearningservices%2Fmachine-learning-job-create-sweep-job%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.machinelearningservices%2Fmachine-learning-job-create-sweep-job%2Fazuredeploy.json)

### Overview

This template creates an Azure Machine Learning Sweep job for hyperparameter tuning to find the configuration of hyperparameters that results in the best performance.

### Prerequisites

To run this template you need to have an Azure Machine Learning Workspace, an Azure Machine Learning Compute Cluster and an Azure Machine Learning Storage Account. The template expects these as parameters: `workspaceName`, `computeName` and `storageAccountName`. You can use the following samples to create these:

1. [Azure Machine Learning Workspace](https://docs.microsoft.com/en-us/samples/azure/azure-quickstart-templates/modules-machine-learning-workspace-0.9/)
2. [Azure Machine Learning Compute Cluster](https://docs.microsoft.com/en-us/samples/azure/azure-quickstart-templates/machine-learning-compute-create-amlcompute/)

Also, the prereq template in prereq folder can be deployed first to get Azure Machine Learning Workspace, an Azure Machine Learning Compute Cluster and an Azure Machine Learning Storage Account. The prereq template will help to setup the basic Azure Machine Learning resources needed to create Sweep job resource.

`Important Note : main.py script is using lightgbm curated environment AzureML-lightgbm-3.2-ubuntu18.04-py37-cpu defined in main.bicep. Please check if the curated environment is deprecated or not, if it is make sure to use the non deprecated curated environment.`

### Notes

If you are new to Azure Machine Learning, see:

- [Azure Machine Learning service](https://azure.microsoft.com/services/machine-learning-service/)
- [Azure Machine Learning documentation](https://docs.microsoft.com/azure/machine-learning/)
- [Azure Machine Learning compute instance documentation](https://docs.microsoft.com/azure/machine-learning/concept-compute-instance)
- [Azure Machine Learning template reference](https://docs.microsoft.com/azure/templates/microsoft.machinelearningservices/allversions)
- [Quickstart templates](https://azure.microsoft.com/resources/templates/)

`Tags: Microsoft.MachineLearningServices/workspaces/jobs, Microsoft.MachineLearningServices/workspaces/computes, Microsoft.MachineLearningServices/workspaces, systemAssigned`
