# Setup Linux Dynamic data disks 

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-linux-dynamic-data-disks%2Fazuredeploy.json" target="_blank">
   <img alt="Deploy to Azure" src="http://azuredeploy.net/deploybutton.png"/>
</a>

  <a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-linux-dynamic-data-disks%2Fazuredeploy.json" target="_blank">  
<img src="http://armviz.io/visualizebutton.png"/> </a>  

### This creates configurable number of disks with configurable size for centos
* Latest Docker configurable - default is 1.10
* Latest docker-compose configurable - default is 1.7.1
* Latest Rancher available @ <code>8080</code> <Unauthenticated.. Authentication is manual setup>
* Azure CLI usage is <code>docker exec -ti azure-cli bash -c "azure login && bash"</code>
* Disk auto mounting is at /<<parameter>>/data
* NFS4 is on on the above
* Strict ssh public key enabled 
* Nodes that share public RSA key shared can be used as direct jump boxes as azureuser@DNS
* NSG is required.
* Internal firewalld is off.
* gcc and other necessary software available
* WALinuxAgent updates are disabled on first deployment.
