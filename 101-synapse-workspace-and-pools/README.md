# Azure Synapse Proof-of-Concept
![Synapse Analytics](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-synapse-workspace-and-pools/images/synapse1.png)

This template deploys necessary resources to run an Azure Synapse Proof-of-Concept

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
    - User Object ID specified in parameters during deploying given Storage Blob Data Contributor to the Storage Account
    - A new File System inside the Storage Account to be used by Azure Synapse
- A Logic App to Pause the SQL Pool at defined schedule
    - The Logic App will check for Active Queries. If there are active queries, it will wait 5 minutes and check again until there are none before pausing
- A Logic App to Resume the SQL Pool at defined schedule
- Both Logic App managed identities are given Contributor rights to the Resource Group
- Grants the Workspace identity CONTROL to all SQL pools and SQL on-demand pool

# Index

- [Purpose](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-synapse-workspace-and-pools#purpose)
- [Prerequisites](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-synapse-workspace-and-pools#prerequisites)
    - [Getting your Object ID](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-synapse-workspace-and-pools#getting-your-object-id)
        - [Option A - PowerShell](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-synapse-workspace-and-pools#option-a---powershell)
        - [Option B - Azure Portal](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-synapse-workspace-and-pools#option-b---azure-portal)
- [Deploy to Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-synapse-workspace-and-pools#deploy-to-azure)

## Purpose
This template allows the Administrator to deploy a Proof-of-Concept environment of Azure Synapse Analytics with some pre-set parameters. This allows more time to focus on the Proof-of-Concept at hand and test the service.

Using the Getting Started wizard inside of the workspace is recommended to use sample data if you do not have your own with you to add to the Storage Account.

## Prerequisites
- Owner to the Azure Subscription being deployed. This is for creation of a separate Proof-of-Concept Resource Group and to delegate roles necessary for this proof of concept
- Your **User Object ID**
    - This is used to give you access to the Storage Account so you can utilise the proof of concept
    - Follow the guide below to get your User Object ID

## Getting your Object ID

### Option A - PowerShell
- Download the PowerShell script from **[HERE](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-synapse-workspace-and-pools/scripts)**
    - This script will:
        - Check if the Azure Active Directory PowerShell module is installed
            - If the Azure Active Directory PowerShell module is **NOT** installed, then the script will attempt to install it
        - Connect to Azure Active Directory using the account the template is being deployed into Azure with, and to run the Proof-of-Concept
    - If the Azure Active Directory PowerShell module is not installed on your machine, **run PowerShell as Administrator to install the module**

### Option B - Azure Portal
- Sign into the Azure Portal (https://portal.azure.com/)
- Either search for Azure Active Directory at the top, or used the sidebar if you have it. Screenshot below shows the sidebar:

![AAD Sidebar](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-synapse-workspace-and-pools/images/1.png)

- Select 'Users' underneath the 'Manage' heading in the Azure Active Directory blade:

![Users View](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-synapse-workspace-and-pools/images/2.png)

- Search for your User Principal Name or your Display Name to load information about your account. Once you have clicked through into your account, you will see your Object ID:

![Find User](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-synapse-workspace-and-pools/images/3.png)

- Then copy the ID underneath 'Object ID' with the copy to clipboard button on the right hand side:

![Object ID](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-synapse-workspace-and-pools/images/4.png)

# Deploy to Azure

With all the pre-requisites in place and information at hand, you can now use the below to deploy into Azure. This will take you to the custom template deployment blade in Azure. Fill in the Parameters with the necessary information to deploy the Proof of Concept.

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-synapse-workspace-and-pools%2Fazuredeploy.json)