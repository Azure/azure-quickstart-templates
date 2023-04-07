# ARM template version

The ARM template in this folder allows you to delploy your Azure Sentinel environments in a few clicks. The template is very easy to use as it comes with a wizard interface that guides you through the setup steps.

The template performs the following tasks:

- Creates resource group (if given resource group doesn't exist yet)
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


[![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FAzure-Sentinel%2Fmaster%2FTools%2FSentinel-All-In-One%2FARMTemplates%2Fazuredeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FAzure-Sentinel%2Fmaster%2FTools%2FSentinel-All-In-One%2FARMTemplates%2FcreateUiDefinition.json)
