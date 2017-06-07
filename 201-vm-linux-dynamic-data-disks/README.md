# Setup Linux Dynamic data disks 
## A great Control Machine for All your Azure Automation Needs

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-linux-dynamic-data-disks%2Fazuredeploy.json" target="_blank">
   <img alt="Deploy to Azure" src="http://azuredeploy.net/deploybutton.png"/>
</a>

  <a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-linux-dynamic-data-disks%2Fazuredeploy.json" target="_blank">  
<img src="http://armviz.io/visualizebutton.png"/> </a>  

### This creates configurable number of disks with configurable size for centos
* Latest Docker configurable - default is 1.12.3-cs3 (For CentOS 7.1/7.2, kernel 3.10.x and above) and for Ubuntu.
* Latest docker-compose configurable - default is 1.9.0-rc2 (or CentOS 7.1/7.2, kernel 3.10.x and above) and for Ubuntu 16.04.0-LTS.
* Latest docker-machine configurable - default is the now latest v0.8.2 (or CentOS 7.1/7.2, kernel 3.10.x and above) and for Ubuntu  Ubuntu 16.04.0-LTS. [Docs](https://docs.docker.com/machine/drivers/azure/)
* Latest Rancher available dockerized (7.1/7.2/16.04.0-LTS) @ <code>8080</code> i.e. <code>http://'DNS Name'.'location'.cloudapp.azure.com:8080 - Unauthenticated.. Authentication and agent setup is manual setup>.</code>
* Azure CLI usage is <code>docker exec -ti azure-cli bash -c "azure login && bash"</code>.
* Disk auto mounting is at /'parameter'/data.
* NFS4 is on on the above.
* Strict ssh public key enabled.
* Nodes that share public RSA key shared can be used as direct jump boxes as azureuser@DNS.
* NSG is required.
* Internal firewalld is off.
* gcc and other necessary software available for Plain CentOS 6.5/6.6/7.1/7.2 and for Ubuntu 16.04.0-LTS
* WALinuxAgent updates are disabled on first deployment.
* Specific Logic in <code>install_packages_all()</code> to distinguish between sku for CentOS 6.5/6.6 and 7.1/7.2 as well as UbuntuServer 16.04.0-LTS, primarily for docker usage.
