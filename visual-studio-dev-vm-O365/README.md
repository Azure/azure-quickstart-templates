# A Visual Studio Development VM for O365 Developers

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/visual-studio-dev-vm-O365/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/visual-studio-dev-vm-O365/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/visual-studio-dev-vm-O365/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/visual-studio-dev-vm-O365/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/visual-studio-dev-vm-O365/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/visual-studio-dev-vm-O365/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fvisual-studio-dev-vm-O365%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fvisual-studio-dev-vm-O365%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template creates a Visual Studio 2015 VM from the base gallery VM images available complete with Office 2013 or Office 2016 Desktop installed.  It creates the VM in a new vnet, storage account, nic, and public ip with the new compute stack. There are various combinations of Visual Studio skus and underlying operating system available to deploy with this template.  Selecting a VM image other than the Visual Studio Community Edition will require appropriate licenses to work properly after you login to the VM and start Visual Studio. Also a valid MSDN subscription user must be authenticated to be able to create the VM images which are not Visual Studio Community Edition on top of Windows Server.

By default, it will deploy Visual Studio 2015 Update 3 Community Edition with Azure SDK 2.91 on Windows Server 2012R2 with Office 2016 Desktop on top of a new premium storage account.


