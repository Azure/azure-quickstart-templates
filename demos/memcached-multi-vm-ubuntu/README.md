# Create multiple Ubuntu 14.04 VMs with memcached service and one VM with Apache and PHP test page

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/memcached-multi-vm-ubuntu/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/memcached-multi-vm-ubuntu/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/memcached-multi-vm-ubuntu/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/memcached-multi-vm-ubuntu/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/memcached-multi-vm-ubuntu/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/memcached-multi-vm-ubuntu/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fmemcached-multi-vm-ubuntu%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fmemcached-multi-vm-ubuntu%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fmemcached-multi-vm-ubuntu%2Fazuredeploy.json)

This template allows you to create multiple (based on the 'numberOfMemcachedInstances' parameter) Ubuntu 14.04 VMs in a private-only subnet and installs and configures memcached service on each VM. It also creates one publicly accessible Apache VM with a PHP test page to confirm that memcached is installed and accessible.

The template creates the following deployment resources:
* Virtual Network with two subnets: Subnet-DMZ for the Apache VM and Subnet-Memcached for the memcached VMs
* Storage account to storage the VM VHDS
* Public IP address (named publicip) for accessing the Apache web server and the hosted PHP test page
* Network Interface Card (NIC) for Apache web (named nicapache)
* Multiple Network Interface Cards (NICs) for memcached servers (named memcachednic0, memcachednic1, etc.)
* One remotely-hosted CustomScript (install_apache.sh with passed in parameters) extension to install Apache, PHP5, memcached PHP extension, and the index.php test page on the Apache VM
* Multiple remotely-hosted CustomScript (install_memcached.sh with passed in parameters) extensions to install and configure the memcached service on each of the numberOfMemcachedInstances VMs

NOTE: In the current version of the template, Apache test page is dynamically configured with the IP addresses of the memcached servers by assuming that they are always deployed into an empty Subnet-Memcached and that the first server is at x.x.x.4, second at x.x.x.5, third at x.x.x.6, etc. IP addresses.


