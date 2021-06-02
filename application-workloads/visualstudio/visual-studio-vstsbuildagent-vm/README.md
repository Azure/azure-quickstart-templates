# A Visual Studio based Visual Studio Team Services (VSTS) Build Agent VM

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/visualstudio/visual-studio-vstsbuildagent-vm/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/visualstudio/visual-studio-vstsbuildagent-vm/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/visualstudio/visual-studio-vstsbuildagent-vm/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/visualstudio/visual-studio-vstsbuildagent-vm/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/visualstudio/visual-studio-vstsbuildagent-vm/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/visualstudio/visual-studio-vstsbuildagent-vm/CredScanResult.svg)

[![Deploy to Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fvisualstudio%2Fvisual-studio-vstsbuildagent-vm%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fvisualstudio%2Fvisual-studio-vstsbuildagent-vm%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fvisualstudio%2Fvisual-studio-vstsbuildagent-vm%2Fazuredeploy.json)

This template is based on the <a href="https://github.com/Azure/azure-quickstart-templates/tree/master/visual-studio-dev-vm">Visual Studio Dev VM template created by [dtzar](https://github.com/dtzar).  It creates the VM in a new vnet, storage account, nic, and public ip with the new compute stack then installs the Visual Studio Team Services build agent.
By default, it will deploy Visual Studio 2015 Update 3 with Azure SDK 2.9 on Windows Server 2012 with a DS1 size on top of a new premium storage account.

## Authentication
In order to authenticate your agent as a member of Agent Pool Administrators group, you must use one of the following methods:
* set up and use a <a href="https://www.visualstudio.com/en-us/get-started/setup/use-personal-access-tokens-to-authenticate">Personal Access Token, set PersonalAccessToken to the token value.

You can revoke or change the credentials in Visual Studio Team Services after the VM has been created.


