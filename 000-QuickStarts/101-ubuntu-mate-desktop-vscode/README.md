# Deploy an Ubuntu Mate Desktop VM with VSCode

This template creates a Linux developer workstation as follows:

- Create a VM based on the Ubuntu 17.10 image with Mate Desktop installed
- Installs Azure CLI v2
- Install Visual Studio Code editor
- Opens the RDP port for users to connect using remote desktop

This template creates a new Ubuntu VM with Mate desktop enabled. Mate desktop is light weight and has a simple UI. In addition to a nice GUI, this template also installs developer tools like Azure CLI and Visual Studio Code for editing files. Users can connect to the Desktop UI using remote destop.

To connect, run "mstsc" from windows desktop and connect to the fqdn/public ip of the VM. 

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-msi-linux-terraform%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>