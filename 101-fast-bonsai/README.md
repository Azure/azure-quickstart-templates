# Fast Azure Bonsai Suite Deployment ![Bonsai logo](https://static.docs.com/ui/media/product/azure/bonsai.svg)

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-fast-bonsai/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-fast-bonsai/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-fast-bonsai/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-fast-bonsai/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-fast-bonsai/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-fast-bonsai/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-fast-bonsai%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-fast-bonsai%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-fast-bonsai%2Fazuredeploy.json)

This template demonstrates the fast deployment of an Azure Bonsai suite to create AI models (brains) that control and optimize complex systems, with no neural net design required.

## What is Bonsai?
Bonsai is the machine teaching service in the Autonomous Systems suite from Microsoft. It builds on innovations in reinforcement learning to simplify AI development.

![Bonsai components](https://docs.microsoft.com/en-us/bonsai/media/components/bonsai.svg)

The Bonsai platform simplifies machine teaching with deep reinforcement learning so you can train and deploy smarter autonomous systems:

Integrate training simulations that implement real-world problems and provide realistic feedback during training.
Train adaptive brains with intuitive goals and learning objectives, real-time success assessments, and automatic versioning control.
Export the optimized brain and deploy it on-premises, in the cloud, or at the edge.

> The Bonsai platform runs on Azure and charges resource costs to your Azure subscription:
> * Azure Container Registry (basic tier) for storing exported brains and uploaded simulators.
> * Azure Container Instances for running simulations.
> * Azure Storage for storing uploaded simulators as zip files.

For more information about Bonsai, you can check the [official Bonsai documentation](https://docs.microsoft.com/en-us/bonsai/).
