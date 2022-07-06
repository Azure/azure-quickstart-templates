---
description: This is a common template for creating single instance CentOS 7.2/7.1/6.5 or Ubuntu Server 16.04.0-LTS with configurable number of data disks (configurable sizes). Maximum 16 disks can be mentioned in the portal parameters and maximum size of each disk should be less than 1023 GB. The MDADM RAID0 Array is automounted and survives restarts. Latest Docker 1.12(cs3) (Swarm), docker-compose 1.9.0 & docker-machine 0.8.2 is available for usage from user azure-cli is auto running as a docker container. This single instance template is an offshoot of the HPC/GPU Clusters Template @ https&#58;//aka.ms/azurebigcompute
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: vm-linux-dynamic-data-disks
languages:
- json
---
# CentOS/UbuntuServer Auto Dynamic Disks & Docker 1.12(cs)

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-linux-dynamic-data-disks/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-linux-dynamic-data-disks/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-linux-dynamic-data-disks/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-linux-dynamic-data-disks/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-linux-dynamic-data-disks/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-linux-dynamic-data-disks/CredScanResult.svg)
## A great Control Machine for All your Azure Automation Needs

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvm-linux-dynamic-data-disks%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)]( https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvm-linux-dynamic-data-disks%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvm-linux-dynamic-data-disks%2Fazuredeploy.json)
   <img alt="Deploy to Azure" src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true"/>

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

`Tags: Microsoft.Compute/availabilitySets, Microsoft.Network/networkSecurityGroups, Microsoft.Network/virtualNetworks, Microsoft.Network/publicIPAddresses, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines, Microsoft.Compute/virtualMachines/extensions, CustomScript`
