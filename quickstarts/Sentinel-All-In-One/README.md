# Azure Sentinel All In One

![logo](./media/Sentinel21Logo.PNG)

**Author: Javier Soriano; Sreedhar Ande; Hesham Saad**

Azure Sentinel All in One is a project that seeks to speed up deployment and initial configuration tasks of an Azure Sentinel environment. This is ideal for Proof of Concept scenarios and connector onboarding when highly privileged users are needed.

There's two versions of Sentinel All-In-One: **Powershell script** and **ARM template**. There's slight differences on what things get automated with each. We try to summarize them here:

| All-In-One version                                 | Data Connectors         |  Analytics Rules  |
| -------------------------------------------------- | ----------------------- |-------------------|
| Powershell script                                  | Azure Activity, Azure Security Center, Azure Active Directory, Azure Active Directory Identity Protection, Office 365, Microsoft Cloud App Security, Azure Advanced Threat Protection, Microsoft Defender Advanced ThreatProtection, Threat Intelligence Platforms | Microsoft Incident Creation rules |
| ARM template                                       | Azure Activity, Azure Security Center, Azure Active Directory Identity Protection, Office 365, Microsoft Cloud App Security, Azure Advanced Threat Protection, Microsoft Defender Advanced ThreatProtection, Security Events, DNS (Preview), Windows Firewall     | Microsoft Incident Creation, Fusion, ML Behavior Analytics, Scheduled      |

## Prerequisites

- Azure user account with enough permissions to enable the required connectors. See table below for additional permissions. Write permissions to the workspace are **always** needed.
- Some data connectors also require a license to be present in order to be enabled. See table below.
- [PowerShell Core](https://github.com/PowerShell/PowerShell) needs to be installed ONLY if using Powershell version
- Threat Intelligence Platforms connector requires additional setup documented [here](https://docs.microsoft.com/azure/sentinel/connect-threat-intelligence#connect-azure-sentinel-to-your-threat-intelligence-platform)

The following table summarizes permissions, licenses and permissions needed and related cost to enable each Data Connector:

| Data Connector                                 | License         |  Permissions                    | Cost      |
| ---------------------------------------------- | --------------- |---------------------------------|-----------|
| Azure Activity                                 | None            | Subscription Reader             | Free      |
| Azure Defender	                             | ASC Standard    | Security Reader                 | Free      |
| Azure Active Directory                         | Any AAD license | Global Admin or Security Admin  | Billed    |
| Azure Active Directory Identity Protection     | AAD Premium 2   | Global Admin or Security Admin  | Free      |
| Office 365                                     | None            | Global Admin or Security Admin  | Free      |
| Microsoft Cloud App Security                   | MCAS            | Global Admin or Security Admin  | Free      |
| Microsoft Defender for Identity                | AATP            | Global Admin or Security Admin  | Free      |
| Microsoft Defender for Endpoint                | MDATP           | Global Admin or Security Admin  | Free      |
| Threat Intelligence Platforms                  | None            | Global Admin or Security Admin  | Billed    |
| Security Events                                | None            | None                            | Billed    |
| Linux Syslog                                   | None            | None                            | Billed    |
| DNS (preview)                                  | None            | None                            | Billed    |
| Windows Firewall                               | None            | None                            | Billed    |

## ARM template instructions

The template performs the following tasks:

- Creates resource group (if given resource group doesn't exist yet)
- Creates Log Analytics workspace (if given workspace doesn't exist yet)
- Installs Azure Sentinel on top of the workspace (if not installed yet)
- Enables selected Data Connectors from tihs list: 
    + Azure Activity
    + Azure Defender
    + Azure Active Directory Identity Protection
    + Office 365 (Sharepoint, Exchange and Teams)
    + Microsoft Cloud App Security
    + Microsoft Defender for Identity
    + Microsoft Defender for Endpoint
    + Security Events
    + Linux Syslog
    + DNS (Preview)
    + Windows Firewall
- Enables analytics rules for selected Microsoft 1st party products 
- Enables Fusion rule and ML Behavior Analytics rules for RDP or SSH (if Security Events or Syslog data sources are selected)
- Enables Scheduled analytics rules that apply to all the enabled connectors 

It takes around **10 minutes** to deploy if enabling Scheduled analytics rules is selected. If Scheduled rules are not needed it will complete in less than 1 minute.

In order to create the Scheduled analytics rules, the deployment template uses an [ARM deployment script](https://docs.microsoft.com/azure/azure-resource-manager/templates/deployment-script-template) which requires a [user assigned identity](https://docs.microsoft.com/azure/active-directory/managed-identities-azure-resources/overview). You will see this resource in your resource group when the deployment finishes. You can remove after depployment if desired.

### Try it now

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FAzure-Sentinel%2Fmaster%2FTools%2FSentinel-All-In-One%2FARMTemplates%2Fazuredeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FAzure-Sentinel%2Fmaster%2FTools%2FSentinel-All-In-One%2FARMTemplates%2FcreateUiDefinition.json)


## Powershell script Instructions

The Powershell script inside the Powershell folder (*SentinelallInOne.ps1*) takes care of the following steps:

- Creates resource group (if given resource group doesn't exist yet)
- Creates Log Analytics workspace (if given workspace doesn't exist yet)
- Installs Azure Sentinel on top of the workspace (if not installed yet)
- Enables the following Data Connectors: 
    + Azure Activity
    + Azure Defender
    + Azure Active Directory
    + Azure Active Directory Identity Protection
    + Office 365 (Sharepoint, Exchange and Teams)
    + Microsoft Cloud App Security
    + Microsoft Defender for Identity
    + Microsoft Defender for Endpoint
    + Threat Intelligence Platforms
- Enables Analytics Rules for enabled Microsoft 1st party products 

### Getting started
These instructions will show you what you need to now to use Sentinel All in One.

#### Prerequisites

- [PowerShell Core](https://github.com/PowerShell/PowerShell)
- Azure user account with enough permissions to enable the required connectors. See table below.
- Some data connectors also require a license to be present in order to be enabled. See table below.
- Threat Intelligence Platforms connector requires additional setup documented [here](https://docs.microsoft.com/azure/sentinel/connect-threat-intelligence#connect-azure-sentinel-to-your-threat-intelligence-platform)

The following table summarizes permissions, licenses needed and cost to enable each Data Connector:

| Data Connector                                 | License         |  Permissions                   | Cost      |
| ---------------------------------------------- | --------------- |--------------------------------|-----------|
| Azure Activity                                 | None            |Reader                          | Free      |
| Azure Defender                                 | ASC Standard    |Security Reader                 | Free      |
| Azure Active Directory                         | Any AAD license |Global Admin or Security Admin  | Billed    |
| Azure Active Directory Identity Protection     | AAD Premium 2   |Global Admin or Security Admin  | Free      |
| Office 365                                     | None            |Global Admin or Security Admin  | Free      |
| Microsoft Cloud App Security                   | MCAS            |Global Admin or Security Admin  | Free      |
| Microsoft Defender for Identity                | AATP            |Global Admin or Security Admin  | Free      |
| Microsoft Defender for Endpoint			     | MDATP           |Global Admin or Security Admin  | Free      |
| Threat Intelligence Platforms                  | None            |Global Admin or Security Admin  | Billed    |

#### Usage

Once you have PowerShell Core installed on your machine, you just need two files from this repo: 

* *connectors.json* - contains all the connectors that will be enabled. If you don't want some of the connectors to be enabled, just remove them from the your copy of the file.

* *SentinelAllInOne.ps1* - script that automates all the steps outlined above.

The script uses your current Azure context, if you want to change the subscription you want to use, make sure you do that before executing the script. You can use `Connect-AzAccount -SubscriptionId <subscription_id>`  to do that

Open a PowerShell core terminal, navigate to the folder where these two files are located and execute *SentinelAllInOne.ps1*. You will be asked to enter the following parameters:

 - **Resource Group** - Resource Group that will contain the Azure Sentinel environment. If the provided resource group already exists, the script will skip its creation.
 - **Workspace** - Name of the Azure Sentinel workspace. If it already exists, the script will skip its creation.
 - **Location** - Location for the resource group and Azure Sentinel workspace.

If not logged in already, the script will ask you to log in to your Azure account. Make sure you have the right permissions to enable the connectors specified in *connectors.json* file.

The script will then iterate through the connectors specified in the *connectors.json* file and enable them. It will also enable the corresponding Microsoft analytics rules.

Here you have a GIF that shows the execution process:

![demo](./media/SentinelAllInOne.gif)
