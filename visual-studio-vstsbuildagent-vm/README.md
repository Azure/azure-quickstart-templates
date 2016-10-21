# A Visual Studio based Visual Studio Team Services Build and Release Agent VM

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fvisual-studio-vsobuildagent-vm%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fvisual-studio-vsobuildagent-vm%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template is based on the <a href="https://github.com/Azure/azure-quickstart-templates/tree/master/visual-studio-dev-vm">Visual Studio Dev VM</a> template created by [dtzar](https://github.com/dtzar).  
You need to provide in the azuredeploy.parameters.json file the following input:
* the name of the Vurtual Machine to be created;
* the user name of password and the administrative account of the VM;
* the name of an existing virtual network and of its subnet (and of its resource group if it differs from the one the VM is created in);
* a public DNS name; the VM could be reached then by RDP by using *YOURDNSNAME.GEOLOCATION*.cloudapp.azure.com;
* the Visual Studio Team Services account name , e.g. microsoft.visualstudio.com;
* Your VSTS <a href="https://www.visualstudio.com/en-us/get-started/setup/use-personal-access-tokens-to-authenticate">Personal Access Token</a> (PAT); the token must have at least the scope of "Agent Pools (read, manage)";
* a Agent Pool name;

With that data it creates with the ARM compute Azure stack a VM with the desired OS, then installs most recent version of the Visual Studio Team Service build and release agent based on .NET Core.

Note that by default it deploys Visual Studio 2015 Update 3 Community Edition with Azure SDK 2.9 on Windows Server 2012 with a DS2 size on top of a new premium storage account.
