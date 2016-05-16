# Deploy a Virtual Machine with CustomData

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-customdata-windows%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to create a Virtual Machine and passes in Custom Data. In this template the Virtual Machine Name, The Datacenter Region and the Fully Qualified DNS Name, FQDN will be passed in as Custom Data, but you could tweak it to provide other information to your VM. The information is then accessible from within the VM by reading and parsing the file C:\CustomData\AzureData.bin. Even if information is base64 encoded in the template, the data is automatically decoded and is easily consumed from within scripts or other. This kind of information could be useful if the VM need to be aware about itself or the deployment that created the VM. This template also deploys a Storage Account, Virtual Network, Public IP addresses and a Network Interface.