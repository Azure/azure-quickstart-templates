# Deploy Microsoft Discovery infrastructure

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.discovery/discovery-infra-deployment/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.discovery/discovery-infra-deployment/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.discovery/discovery-infra-deployment/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.discovery/discovery-infra-deployment/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.discovery/discovery-infra-deployment/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.discovery/discovery-infra-deployment/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.discovery/discovery-infra-deployment/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.discovery%2Fdiscovery-infra-deployment%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.discovery%2Fdiscovery-infra-deployment%2Fazuredeploy.json)

This template deploys the full **Microsoft Discovery** stack into a single resource group using the `2026-02-01-preview` API. Microsoft Discovery is a platform for scientific computing that provisions networking, identity, storage, supercomputer, workspace, and project resources.

## Sample overview and deployed resources

This template provisions the complete infrastructure for a Microsoft Discovery environment in a single deployment. It creates a virtual network with five purpose-built subnets, a user-assigned managed identity with the required role assignments, a CORS-enabled storage account, and the core Discovery resources: a Supercomputer with a Node Pool, a Workspace with a Chat Model Deployment and Project, and a Storage Container.

The following resources are deployed as part of the solution

### Microsoft.Network

- **Microsoft.Network/virtualNetworks**: Virtual network with five subnets for Supercomputer Node Pool, AKS, Workspace, Private Endpoint, and Agent workloads.

### Microsoft.ManagedIdentity

- **Microsoft.ManagedIdentity/userAssignedIdentities**: User-Assigned Managed Identity used by the Supercomputer and Workspace for authentication and RBAC.

### Microsoft.Storage

- **Microsoft.Storage/storageAccounts**: Azure Blob Storage account with CORS rules enabled for Discovery Studio and VS Code integrations.
- **Microsoft.Storage/storageAccounts/blobServices/containers**: Blob container for Discovery outputs.

### Microsoft.Authorization

- **Microsoft.Authorization/roleAssignments**: Storage Blob Data Contributor (on Storage Account), Microsoft Discovery Platform Contributor and AcrPull (on Resource Group) for the UAMI.

### Microsoft.Discovery

- **Microsoft.Discovery/supercomputers**: Supercomputer resource with cluster, kubelet, and workload identities.
- **Microsoft.Discovery/supercomputers/nodePools**: Configurable Node Pool with VM size, min/max node count, and scale set priority.
- **Microsoft.Discovery/workspaces**: Workspace linked to the Supercomputer with agent, private endpoint, and workspace subnets.
- **Microsoft.Discovery/workspaces/chatModelDeployments**: Chat model deployment (e.g. GPT-5.2) under the Workspace.
- **Microsoft.Discovery/workspaces/projects**: Project linked to the Discovery Storage Container.
- **Microsoft.Discovery/storageContainers**: Storage Container backed by the Azure Blob Storage account.

## Prerequisites

- An active Azure subscription with access to the **Microsoft Discovery** preview.
- The **Microsoft.Discovery** resource provider registered on your subscription, along with `Microsoft.App`, `Microsoft.ContainerService`, `Microsoft.Network`, `Microsoft.ManagedIdentity`, and `Microsoft.Storage`.
- Sufficient role assignments: *Discovery Platform Admin*, *Managed Identity Contributor*, *Network Contributor*, and *Storage Account Contributor* at the target resource-group scope.
- Microsoft Discovery is available in **East US**, **East US 2**, **Sweden Central**, and **UK South**.

## Deployment steps

You can click the "Deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

```bash
az group create --name rg-discovery --location eastus

az deployment group create \
  --resource-group rg-discovery \
  --template-file main.bicep
```

> **Note** – The Supercomputer and Workspace resources can each take **15–30 minutes** to provision.

## Usage

### Connect

Sign in to [Discovery Studio](https://studio.discovery.microsoft.com) and verify the Workspace appears. Select the Workspace, create a new Project investigation, and start a chat.

#### Management

Add additional Node Pools, Storage Containers, or Tools via the Azure portal or additional Bicep modules.

## Notes

- All resources must reside in the same region.
- The `storageAccountName` parameter must be globally unique (3-24 lowercase alphanumeric characters).
- GPU SKU examples for `nodePoolVmSize`: `Standard_NC24ads_A100_v4`, `Standard_NC4as_T4_v3`.

Tags: `Microsoft.Discovery/supercomputers`, `Microsoft.Discovery/workspaces`, `Microsoft.Discovery/storageContainers`, `Microsoft.Discovery/workspaces/projects`, `Microsoft.Network/virtualNetworks`, `Microsoft.ManagedIdentity/userAssignedIdentities`, `Microsoft.Storage/storageAccounts`
