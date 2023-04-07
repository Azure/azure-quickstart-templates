# ARM template version for MSSPs

This is a special version of the Azure Sentinel All-In-One artifact that includes Azure Lighthouse delegation/s as part of the deployment. This is specially useful for MSSPs or multi-tenant organizations.

<span style="color:red">**IMPORTANT!**</span> - You need to modify several parameters to match you Azure Lighthouse deployment. Specifically, you need to modify the following parameters in the *msspdeploy.json* template:

- *mspOfferName* - A name describing this definition. This value is displayed to the customer as the title of the offer and must be a unique value.
- *mspOfferDescription* - A brief description of your offer (for example, "Azure Sentinel Managed Services").
- *managedByTenantId* - The MSSP Azure Active Directory Tenant ID
- *authorizations* - An array of authorizations that define the access that principals from the MSSP tenant will have on the customer tenant.

The template performs the following tasks:

- Creates resource group (if given resource group doesn't exist yet)
- Creates the **Azure Lighthouse** registration definition
- Creates the **Azure Lighthouse** registration assignments to the resource group that will contain the Azure Sentinel resources
- Creates Log Analytics workspace (if given workspace doesn't exist yet)
- Installs Azure Sentinel on top of the workspace (if not installed yet)
- Enables the following Data Connectors: 
    + Azure Activity
    + Azure Security Center
    + Azure Active Directory Identity Protection
    + Office 365 (Sharepoint, Exchange and Teams)
    + Microsoft Cloud App Security
    + Azure Advanced Threat Protection
    + Microsoft Defender Advanced Threat Protection
    + Security Events
    + Linux Syslog
    + DNS (Preview)
    + Windows Firewall
- Enables analytics rules for selected Microsoft 1st party products 
- Enables Fusion rule and ML Behavior Analytics rules for RDP or SSH (if selected)
- Enables Scheduled analytics rules that apply to all the enabled connectors 


[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FAzure-Sentinel%2Fmaster%2FTools%2FSentinel-All-In-One%2FMSSPversion%2Fmsspdeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FAzure-Sentinel%2Fmaster%2FTools%2FSentinel-All-In-One%2FMSSPversion%2FcreateUiDefinition.json)
