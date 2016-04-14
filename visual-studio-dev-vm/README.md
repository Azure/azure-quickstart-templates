# A Visual Studio Development VM

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fvisual-studio-dev-vm%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fvisual-studio-dev-vm%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template creates a Visual Studio 2013 or 2015 VM from the base gallery VM images available.  It creates the VM in a new vnet, storage account, nic, and public ip with the new compute stack. There are various combinations of Visual Studio skus (2013 Community, 2013 Premium, 2013 Ultimate, 2015 Community, 2015 Professional, 2015 Enterprise), tools (Azure SDK, Cordova), as well as the underlying operating system (Windows 8.1 N, Windows 10 N, Windows Server 2012 R2) available to deploy with this template.  Selecting a VM image other than the Visual Studio community edition will require appropriate licenses to work properly after you login to the VM and start Visual Studio. Also a valid MSDN subscription user must be authenticated to be able to create the VM images which are not Visual Studio Community Edition on top of Windows Server.

By default, it will deploy Visual Studio 2015 Update 1 Community Edition with Azure SDK 2.8 on Windows Server 2012 with a DS2 size on top of a new premium storage account.
