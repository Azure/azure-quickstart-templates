# Install Minecraft server on an Ubuntu Virtual Machine using the Linux Custom Script Extension

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fminecraft-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fminecraft-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template deploys and sets up a customized Minecraft server on an Ubuntu Virtual Machine, with you as the operator. It also deploys a Storage Account, Virtual Network, Public IP addresses and a Network Interface.

You can set common Minecraft server properties as parameters at deployment time. Once the deployment is successful you can connect to the DNS address of the VM with a Minecraft launcher. 

The following Minecraft server configuration parameters can be set at deployment time: Minecraft user name, difficulty, level-name, gamemode, white-list, enable-command-block, spawn-monsters, generate-structures, level-seed.

For more information on how to use this template, refer to <a href="https://msftstack.wordpress.com/2015/09/05/creating-a-minecraft-server-using-an-azure-resource-manager-template/">Creating a Minecraft server using an Azure Resource Manager template</a>.
