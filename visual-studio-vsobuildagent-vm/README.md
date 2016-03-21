# A Visual Studio based Visual Studio Online Build Agent VM

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fvisual-studio-vsobuildagent-vm%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fvisual-studio-vsobuildagent-vm%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template is based on the <a href="https://github.com/Azure/azure-quickstart-templates/tree/master/visual-studio-dev-vm">Visual Studio Dev VM</a> template created by [dtzar](https://github.com/dtzar).  It creates the VM in a new vnet, storage account, nic, and public ip with the new compute stack then installs the Visual Studio Online build agent.
By default, it will deploy Visual Studio 2015 with Azure SDK 2.7 on Windows Server 2012 with a DS2 size on top of a new premium storage account.

This template requires you to pass in your Visual Studio Online account name, and Pool name. You can revoke or change the credentials in Visual Studio Online after the VM has been created.


## Authentication
In order to authenticate your agent as a member of Agent Pool Administrators group, you must use one of the following methods:
* set up and use a <a href="https://www.visualstudio.com/en-us/get-started/setup/use-personal-access-tokens-to-authenticate">Personal Access Token</a>, set VSOPass to the token value, the VSOUser parameter can be anything.
* set up and pass in <a href="https://www.visualstudio.com/integrate/get-started/auth/overview">Alternate Authentication Credentials</a> from Visual Studio Online. 

In both cases you can revoke or change the credentials in Visual Studio Online after the VM has been created.
