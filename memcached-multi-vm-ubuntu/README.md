# Create multiple Ubuntu 14.04 VMs with memcached service and one VM with Apache and PHP test page

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FDrewm3%2Fazure-quickstart-templates%2Fmaster%2Fmemcached-multi-vm-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to create multiple (based on the 'numberOfMemcachedInstances' parameter) Ubuntu 14.04 VMs in a private-only subnet and installs and configures memcached service on each VM. It also creates one publicly accessible Apache VM with a PHP test page to confirm that memcached is installed and accessible.

The template creates the following deployment resources:
* Virtual Network with two subnets: Subnet-DMZ for the Apache VM and Subnet-Memcached for the memcached VMs
* Storage account to storage the VM VHDS
* Public IP address (named publicip) for accessing the Apache web server and the hosted PHP test page
* Network Interface Card (NIC) for Apache web (named nicapache)
* Multiple Network Interface Cards (NICs) for memcached servers (named memcachednic0, memcachednic1, etc.)
* One remotely-hosted CustomScriptForLinux (install_apache.sh with passed in parameters) extension to install Apache, PHP5, memcached PHP extension, and the index.php test page on the Apache VM
* Multiple remotely-hosted CustomScriptForLinux (install_memcached.sh with passed in parameters) extensions to install and configure the memcached service on each of the numberOfMemcachedInstances VMs

NOTE: In the current version of the template, Apache test page is dynamically configured with the IP addresses of the memcached servers by assuming that they are always deployed into an empty Subnet-Memcached and that the first server is at x.x.x.4, second at x.x.x.5, third at x.x.x.6, etc. IP addresses.

Template expects the following parameters

| Name   | Description    |
|:--- |:---|
| newStorageAccountName  | Unique DNS name for the Storage Account where the Virtual Machines' disks will be placed |
| location | Location where the resources will be deployed |
| domainName | Domain name of the publicly accessible Apache test web server |
| adminUsername  | Username for the Virtual Machines  |
| adminPassword  | Password for the Virtual Machine  |
| numberOfMemcachedInstances  | Number of memcached servers to create |
| memcachedVmSize | Size of the memcached virtual machine |
| apacheVmSize | Size of the Apache virtual machine |
| virtualNetworkName | Virtual network name |
| addressPrefix | Address prefix for the virtual network specified in CIDR format |
| subnetDmzName | Name of Subnet-DMZ where Apache server is deployed |
| subnetMemcachedName | Name of Subnet-DMZ where memcached servers are deployed |
| subnetDmzPrefix | Prefix for the Subnet-DMZ specified in CIDR format |
| subnetMemcachedPrefix | Prefix for the Subnet-Memcached specified in CIDR format |
