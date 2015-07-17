# Install Minecraft server on an Ubuntu Virtual Machine using the Linux Custom Script Extension

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fminecraft-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template deploys and sets up a customized Minecraft server on an Ubuntu Virtual Machine, with you as the operator. It also deploys a Storage Account, Virtual Network, Public IP addresses and a Network Interface.

You can set common Minecraft server properties as parameters at deployment time. Once the deployment is successful you can connect to the DNS address of the VM with a Minecraft launcher.

The following parameters can be set at deployment time Minecraft user name, difficulty, level-name, gamemode, white-list, enable-command-block, spawn-monsters, generate-structures, level-seed

| Name   | Description    |
|:--- |:---|
| location | Location where the resources will be deployed |
| minecraftUser | Your Minecraft user name |
| adminUsername  | Username for the Virtual Machines  |
| adminPassword  | Password for the Virtual Machine  |
| dnsNameForPublicIP  | Unique DNS Name for the Public IP used to access the Virtual Machine. |
| difficulty  | 0 - Peaceful, 1 - Easy, 2 - Normal, 3 - Hard |
| level-name | Name of the Minecraft world which will be created |
| gamemode | 0 - Survival, 1 - Creative, 2 - Adventure, 3 - Spectator |
| white-list | Only ops and whitelisted players can connect when true |
| enable-command-block | Allow command blocks to be created |
| spawn-monsters | Enable monster spawning |
| generate-structures | Generates villages, temples etc. |
| level-seed | Add a seed for your world |
