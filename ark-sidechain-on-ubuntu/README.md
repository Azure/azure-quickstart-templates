# Very simple deployment of a Linux VM

<p>These buttons DO NOT WORK AT THIS TIME. Place-holders from another template.</p>
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-simple-linux%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-simple-linux%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>


This template creates an Ubuntu VM with user-specified credentials. It then sets the PublicDNS name, runs a script to install Ark dependencies, and creates a network security group for firewall settings.
FQDN:  PublicDNSname.datacenter-region.cloudapp.azure.com
To Do:
Additional VM sizes to choose from
Variables to run node installation / setup directly at template level before login
Fix dependency issues (Install nodejs 8.9.1 globally instead of via user-level NVM)
Fix 'Deploy to Azure' buttons
