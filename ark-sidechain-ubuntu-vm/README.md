# Deployment of Ark.io Sidechain

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fark-sidechain-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fdavepinkawa%2Fazure-quickstart-templates%2Fmaster%2Fark-sidechain-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

<p>This template creates an Ubuntu VM with user-specified credentials. It then sets the PublicDNS name, creates a network security group for all ark firewall settings, and leaves you with a fresh Ubuntu 16.04-LTS VM in less than 5 minutes.</p>
<p>FQDN:  PublicDNSname.datacenter-region.cloudapp.azure.com</p>
<p>Once the server is fully deployed, connect via SSH (PuTTY > PublicDNSName > Credentials) and then run: <p> 
<code>curl -o- https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/ark-sidechain-on-ubuntu/Script/arkdefaultinstall.sh | bash </code>





