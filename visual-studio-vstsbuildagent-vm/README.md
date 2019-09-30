# A Visual Studio based Visual Studio Team Services (VSTS) Build Agent VM

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/visual-studio-vstsbuildagent-vm/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/visual-studio-vstsbuildagent-vm/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/visual-studio-vstsbuildagent-vm/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/visual-studio-vstsbuildagent-vm/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/visual-studio-vstsbuildagent-vm/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/visual-studio-vstsbuildagent-vm/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2Fvisual-studio-vstsbuildagent-vm%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2Fvisual-studio-vstsbuildagent-vm%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template is based on the <a href="https://github.com/Azure/azure-quickstart-templates/tree/master/visual-studio-dev-vm">Visual Studio Dev VM</a> template created by [dtzar](https://github.com/dtzar).  It creates the VM in a new vnet, storage account, nic, and public ip with the new compute stack then installs the Visual Studio Team Services build agent.
By default, it will deploy Visual Studio 2015 Update 3 with Azure SDK 2.9 on Windows Server 2012 with a DS1 size on top of a new premium storage account.

## Authentication
In order to authenticate your agent as a member of Agent Pool Administrators group, you must use one of the following methods:
* set up and use a <a href="https://www.visualstudio.com/en-us/get-started/setup/use-personal-access-tokens-to-authenticate">Personal Access Token</a>, set PersonalAccessToken to the token value.

You can revoke or change the credentials in Visual Studio Team Services after the VM has been created.

