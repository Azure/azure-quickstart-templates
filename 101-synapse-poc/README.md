# Azure Synapse Proof-of-Concept
![Synapse Analytics](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-synapse-poc/images/synapse1.png)

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-synapse-poc/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-synapse-poc/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-synapse-poc/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-synapse-poc/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-synapse-poc/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-synapse-poc/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-synapse-poc%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-synapse-poc%2Fazuredeploy.json)

This template deploys necessary resources to run an Azure Synapse Proof-of-Concept

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-synapse-poc%2Fazuredeploy.json)

This template deploys the following:
- An Azure Synapse Workspace
    - (OPTIONAL) Allows All connections in by default (Firewall IP Addresses)
    - Allows Azure Services to access the workspace by default
    - Managed Virtual Network is Enabled
- An Azure Synapse SQL Pool
- (OPTIONAL) Apache Spark Pool
    - Auto-paused set to 15 minutes of idling 
- Azure Data Lake Storage Gen2 account
    - Azure Synapse Workspace identity given Storage Blob Data Contributor to the Storage Account
    - A new File System inside the Storage Account to be used by Azure Synapse
- A Logic App to Pause the SQL Pool at defined schedule
    - The Logic App will check for Active Queries. If there are active queries, it will wait 5 minutes and check again until there are none before pausing
- A Logic App to Resume the SQL Pool at defined schedule
- Both Logic App managed identities are given Contributor rights to the Resource Group
- Grants the Workspace identity CONTROL to all SQL pools and SQL on-demand pool

# Index

- [Purpose](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-synapse-poc#purpose)
- [Prerequisites](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-synapse-poc#prerequisites)
- [Deploy to Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-synapse-poc#deploy-to-azure)

## Purpose
This template allows the Administrator to deploy a Proof-of-Concept environment of Azure Synapse Analytics with some pre-set parameters. This allows more time to focus on the Proof-of-Concept at hand and test the service.

Using the Getting Started wizard inside of the workspace is recommended to use sample data if you do not have your own with you to add to the Storage Account.

## Prerequisites
- Owner to the Azure Subscription being deployed. This is for creation of a separate Proof-of-Concept Resource Group and to delegate roles necessary for this proof of concept

# Deploy to Azure