# Azure Resource Manager QuickStart Templates

# Contributing guide

This is a repo that contains all the currently available Azure Resource Manager templates contributed by the community. These templates are indexed on Azure.com and available to view here http://azure.microsoft.com/en-us/documentation/templates/

To make sure your template is added to Azure.com index, please follow these guidelines. Any templates that are out of compliance will be added to the **blacklist** and not be indexed on Azure.com

1.	Every template must be contained in its own **folder**. Name this folder something that describes what your template does. Usually this naming pattern looks like **appName-osName**
2.	The template file must be named **azuredeploy.json**
3.	The template folder must host the **scripts** that are needed for successful template execution
4.	The template folder must contain a **metadata.json** file to allow the template to be indexed on [Azure.com](http://azure.microsoft.com)
  *	Guidelines on the metadata file below
5. Include a **Readme.md** file that explains how the template works
6. Template parameters should follow **camelCasing**
7. Every parameter in the template must have the **description** specified using the metadata property. This looks like below

  ```json
  "newStorageAccountName": {
        "type": "string",
        "metadata": {
            "description": "The name of the new storage account created to store the VMs disks"
        }
  }
  ```

See the starter template [here](https://github.com/Azure/azure-quickstart-templates/tree/master/100-starter-template-with-validation) for more information on passing validation


## metadata.json file

Here are the required parameters for a valid metadata.json file

To be more consistent with the Visual Studio and Gallery experience we're updating the metadata.json file structure. The new structure looks like below

    {
      "itemDisplayName": "",
      "description": "",
      "summary": "",
      "githubUsername": "",
      "dateUpdated": "<e.g. 2015-12-20>"
    }

The metadata.json file will be validated using these rules

**itemDisplayName**
*	Cannot be more than 60 characters

**description**
*	Cannot be more than 1000 characters
*	Cannot contain HTML
* This is used for the template description on the Azure.com index template details page

**summary**
*	Cannot be more than 200 characters
* This is shown for template description on the main Azure.com template index page

**githubUsername**
*	Username must be the same as the username of the author submitting the Pull Request
* This is used to display template author and Github profile pic in the Azure.com index

**dateUpdated**
*	Must be in yyyy-mm-dd format.
*	The date must not be in the future to the date of the pull request

## Good practice

* It is a good practice to pass your template through a JSON linter to remove extraneous commas, paranthesis, brackets that may break the "Deploy to Azure" experience

## Starter template

A starter template is provided [here](https://github.com/Azure/azure-quickstart-templates/tree/master/100-starter-template-with-validation) for you to follow



## 101 templates
These are simple example templates with single actions for common requirements.

| Type | #  | Author                          | Template Name   | Description     |
|:------|:------|:-----------------|:--------------------------------| :---------------| :---------------|
| 101 | 1 | [mahthi](https://github.com/mahthi) | [Deploy an Availability Set](https://github.com/Azure/azure-quickstart-templates/tree/master/101-create-availability-set) | This template allows you to create an Availability Set in your subscription.|
| 101 | 2 | [mahthi](https://github.com/mahthi) | [Deploy a Load Balancer with an Inbound NAT Rule](https://github.com/Azure/azure-quickstart-templates/tree/master/101-loadbalancer-with-nat-rule) | This template allows you to create a load balancer with NAT rule in your subscription.|
| 101 | 3 | [mahthi](https://github.com/mahthi) | [Deploy a Virtual Network](https://github.com/Azure/azure-quickstart-templates/tree/master/101-virtual-network) | This template allows you to deploy a Virtual Network. |
| 101 | 4 | [mahthi](https://github.com/mahthi) | [Deploy a Simple Virtual Machine from an  Image](https://github.com/Azure/azure-quickstart-templates/tree/master/101-simple-vm-from-image) | This template allows you to deploy a Simple Virtual Machines from an Image. |
| 101 | 5 | [mahthi](https://github.com/mahthi) | [Create a Network Interface in a Virtual Network and associate it with a Public IP](https://github.com/Azure/azure-quickstart-templates/tree/master/101-networkinterface-with-publicip-vnet) | This template creates a simple Network Interface in a Virtual Network and attaches a Public IP Address to it. |
| 101 | 6 | [mahthi](https://github.com/mahthi) | [Deploy a Virtual Machine with Custom Data](https://github.com/Azure/azure-quickstart-templates/tree/master/101-vm-customdata) | This template allows you to deploy a Virtual Machines by passing Custom Data to the VM. |
| 101 | 7 | [singhkay](https://github.com/singhkay) | [Create a key Vault](https://github.com/Azure/azure-quickstart-templates/tree/master/101-create-key-vault) | This template creates a Key Vault |
| 101 | 8 | [mahthi](https://github.com/mahthi) | [Deploy a Virtual Machine from a User Image](https://github.com/Azure/azure-quickstart-templates/tree/master/101-vm-from-user-image) | This template allows you to create a Virtual Machines from a User image. Prerequisite - The Storage Account with the User Image VHD should already exist in the same resource group. |
| 101 | 9 | [manavis](https://github.com/manavis) | [Assign RBAC BuiltInRoles to an Existing Resource Group](https://github.com/Azure/azure-quickstart-templates/tree/master/101-rbac-builtinrole-resourcegroup) | This template assigns Owner, Reader or Contributor access to an existing resource group. |
| 101 | 10 | [kenazk](https://github.com/kenazk) | [Create an Availability Set with 3 FDs configured](https://github.com/Azure/azure-quickstart-templates/tree/master/101-create-availability-set-3FDs) | This template snippet creates an Availability Set with 3 FDs |
| 101 | 11 | [singhkay](https://github.com/singhkay) | [Create a network Security Group](https://github.com/Azure/azure-quickstart-templates/tree/master/101-create-security-group) | This template creates a Network Security Group|
| 101 | 12 |[kenazk](https://github.com/kenazk) | [Create a VM from a Windows Image with 4 Empty Data Disks](https://github.com/Azure/azure-quickstart-templates/tree/master/101-vm-multiple-data-disk) | Create a VM from a Windows Image with 4 Empty Data Disks|
| 101 | 13 | [kenazk](https://github.com/kenazk) | [Linux VM with Empty Data Disk](https://github.com/Azure/azure-quickstart-templates/tree/master/101-vm-multiple-data-disk) | This template creates a Linux VM with a new empty data disk. |
| 101 | 14 | [ggalow](https://github.com/ggalow) | [Create a public IP with DNS Name](https://github.com/Azure/azure-quickstart-templates/tree/master/101-public-ip-dns-name) | Create a public IP with DNS Name |
| 101 | 15 | [ManaviS](https://github.com/ManaviS) | [RBAC - Grant Built In Role Access for an existing VM in a Resource Group](https://github.com/Azure/azure-quickstart-templates/tree/master/101-rbac-builtinrole-virtualmachine) | RBAC - Grant Built In Role Access for an existing VM in a Resource Group |

## 201 templates
These are more complex example templates with single actions for more advanced requirements.

| Type | # |  Author                          | Template Name   | Description     |
|:------|:------|:-----------------|:--------------------------------| :---------------| :---------------|
| 201 | 1 | [singhkay](https://github.com/singhkay) | [Discover a VMs Private IP Dynamically](https://github.com/Azure/azure-quickstart-templates/tree/master/201-discover-private-ip-dynamically) | This templates discovers a private ip of another VM dynamically|
| 201 | 2 | [mahthi](https://github.com/mahthi) | [Deploy 2 Windows VMs under Availability Set with NAT Rules through Load balancer](https://github.com/Azure/azure-quickstart-templates/tree/master/201-2-vms-loadbalancer-natrules) | This template allows you to create 2 Windows Virtual Machines in an Availability Set and configure NAT rules through a load balancer. We also use the resource loops capability to create the network interfaces and virtual machines |
| 201 | 3 | [ypitsch](https://github.com/ypitsch) | [Deploy 2 Windows VMs under a load balancer and configure a LB rule](https://github.com/Azure/azure-quickstart-templates/tree/master/201-2-vms-loadbalancer-lbrules) | This template allows you to create 2 Windows Virtual Machines in an under a Load Balancer, configure LB rules for load balancing and NAT rules for RDP Access to each VM. We also use the resource loops capability to create the network interfaces and virtual machines. |
| 201 | 4 | [singhkay](https://github.com/singhkay) | [Create a VM referencing a VNET in a different Resource Group](https://github.com/Azure/azure-quickstart-templates/tree/master/201-vm-different-rg-vnet) | This template creates a VM in a VNET which is in a different Resource Group. You'll need to have the VNET created before running this template and pass the VNET name and its resource group name as input to this parameter. |
| 201 | 5 | [singhkay](https://github.com/singhkay) | [Create a VM and install a certificate referenced from an Azure Key Vault](https://github.com/Azure/azure-quickstart-templates/tree/master/windows-vm-push-certificate) | This template creates a VM and installs a certificate from the Azure Key Vault on the Virtual Machine. The template expects the Key Vault Name and the certificate URL of the certificate in Key Vault. |
| 201 | 6 | [mahthi](https://github.com/mahthi) | [Execute Dependent script extensions to Configure and Install Mongo DB on a Ubuntu Virtual Machine](https://github.com/Azure/azure-quickstart-templates/tree/master/201-dependency-between-scripts-using-extensions) | This template deploys Configures and Installs Mongo DB on a Ubuntu Virtual Machine in two separate scripts. This template is a sample that showcases how to express dependencies between two scripts running on the same virtual machine.|
| 201 | 7 | [singhkay](https://github.com/singhkay) | [Create 2 VMs in a Availability Set with 2 FDs without resource loops](https://github.com/Azure/azure-quickstart-templates/tree/master/201-2-vms-2-FDs-no-resource-loops) | This template allows you to create 2 VMs in an Availabiltiy Set with 2 Fault Domains without resource loops |
| 201 | 8 | [singhkay](https://github.com/singhkay) | [Create a VM from a specialized VHD disk](https://github.com/Azure/azure-quickstart-templates/tree/master/201-vm-from-specialized-vhd) | This template creates a VM from a specialized VHD |
| 201 | 9 | [narayan](https://github.com/narayan) | [Create a virtual Network with DMZ Subnet](https://github.com/Azure/azure-quickstart-templates/tree/master/201-nsg-dmz-in-vnet) |  Virtual Network with DMZ Subnet |
| 201 | 10 | [ypitsch](https://github.com/ypitsch) | [2 VMs in a VNET with an Internal Load Balancer and Load Balancer rules](https://github.com/Azure/azure-quickstart-templates/tree/master/201-2-vms-internal-load-balancer) | 2 VMs in a VNET with an Internal Load Balancer and Load Balancer rules |
| 201 | 11 | [ManaviS](https://github.com/ManaviS) | [RBAC - Grant Built In Role Access for multiple existing VMs in a Resource Group](https://github.com/Azure/azure-quickstart-templates/tree/master/201-rbac-builtinrole-multipleVMs) | RBAC - Grant Built In Role Access for multiple existing VMs in a Resource Group |

## General Workloads
You can deploy the template to Azure by clicking the "Deploy to Azure" button below next to each template.

| Type | # | Author                          | Template Name   | Description     |
|:------|:------|:-----------------|:--------------------------------| :---------------| :---------------|
| APP | 1 | [singhkay](https://github.com/singhkay) | [VM DSC Extension IIS Server](https://github.com/Azure/azure-quickstart-templates/tree/master/dsc-extension-iis-server-windows-vm) | This template allows you to deploy a VM with with a DSC extension that sets up an IIS server |
| DEV | 2 | [coreysa](https://github.com/coreysa) | [Deploy an Ubuntu VM with Docker](https://github.com/Azure/azure-quickstart-templates/tree/master/docker-simple-on-ubuntu) | This template allows you to deploy an Ubuntu VM with Docker installed. |
| DEV | 3 | [ahmetalpbalkan](https://github.com/ahmetalpbalkan) | [Deploy WordPress+MySQL on Docker Containers](https://github.com/Azure/azure-quickstart-templates/tree/master/docker-wordpress-mysql) | This template allows you to create an Ubuntu VM with Docker installed and WordPress/MySQL containers configured to serve a blog. |
| DEV | 4 | [coreysa](https://github.com/coreysa) | [Deploy Ubuntu Azure Dev VM](https://github.com/coreysa/ubuntu-azure-dev-vm) | This template deploys an Ubuntu VM with the Azure Dev tools installed, which includes node. This executes a bash script pulled from GitHub. |
| 201 | 5 | [coreysa](https://github.com/coreysa) | [Deploy an Ubuntu VM with an additional sudo user](https://github.com/coreysa/ubuntu-azure-add-new-user) | The purpose of this script is to show how to execute a custom script with parameters passed throguh the template that will create an additional user with sudo access. The value of the sample is to show how to pass template parameter based input into a bash Linux script.|
| DEV | 6 | [paigeliu](https://github.com/liupeirong) | [Deploy a 3 node Percona XtraDB Cluster](https://github.com/Azure/azure-quickstart-templates/tree/master/mysql-ha-pxc) | Deploy a 3 node MySQL HA Percona XtraDB Cluster on CentOS 6.5 or Ubuntu 12.04. Each node has 2 disks stripped, and the cluster can be accessed through a load balancer. |
| DEV | 7 |[gbowerman](https://github.com/gbowerman) | [Deploy LAMP app on Ubuntu](https://github.com/Azure/azure-quickstart-templates/tree/master/lamp-app) | This template uses the Azure Linux CustomScript extension to deploy a LAMP application by creating an Ubuntu VM, doing a silent install of MySQL, Apache and PHP, then creating a simple PHP script.|
| DEV | 8 | [snallami](https://github.com/snallami) | [VM-Ubuntu - Tomcat and Open JDK installation](https://github.com/Azure/azure-quickstart-templates/tree/master/openjdk-tomcat-ubuntu-vm) | This template allows you to create a Ubuntu VM with OpenJDK and Tomcat.|
| 201 | 9 | [mahthi](https://github.com/mahthi) | [Deploy 'N' Virtual Machines in a Single Click](https://github.com/Azure/azure-quickstart-templates/tree/master/resource-loop-vms-vnet) | This template allows you to deploy 'n' virtual machines in a Single Click. |
| DEV | 10 | [mahthi](https://github.com/mahthi) | [Install Mongo DB on CentOS Virtual Machine](https://github.com/Azure/azure-quickstart-templates/tree/master/mongodb-on-centos) | This template deploys Mongo DB on CentOS Virtual Machine. |
| DEV | 11 | [mahthi](https://github.com/mahthi) | [Install Mongo DB on Ubuntu Virtual Machine](https://github.com/Azure/azure-quickstart-templates/tree/master/mongodb-on-ubuntu) | This template deploys Mongo DB on Ubuntu Virtual Machine. |
| DEV | 12 | [singhkay](https://github.com/singhkay) | [Create a Zookeeper cluster](https://github.com/Azure/azure-quickstart-templates/tree/master/zookeper-cluster-ubuntu-vm) | This template deploys a 3-node Zookeeper cluster on Ubuntu Virtual Machines. |
| DEV | 13 | [gbowerman](https://github.com/gbowerman) | [Deploy an Apache webserver on Ubuntu](https://github.com/Azure/azure-quickstart-templates/tree/master/apache2-on-ubuntu-vm) | This template uses the Azure Linux CustomScript extension to deploy an Apache web server. The deployment template creates an Ubuntu VM, installs Apache2 and creates a demo HTML file. |
| DEV | 14 | [kundanap](https://github.com/kundanap) | [Bootstrap a Ubuntu VM with Chef Agent with Json paramters](https://github.com/Azure/azure-quickstart-templates/blob/master/chef-json-parameters-ubuntu-vm) | This templates provisions a Ubuntu VM and bootstraps Chef Client on it by taking only json parameters.|
| DEV | 15 | [tomconte](https://github.com/tomconte) | [Deploy a single-VM WordPress to Azure](https://github.com/Azure/azure-quickstart-templates/tree/master/wordpress-single-vm-ubuntu) | This template deploys a complete LAMP stack, then installs and initializes WordPress.Once the deployment is finished, you need to go to http://fqdn.of.your.vm/wordpress/ to finish the configuration, create an account, and get started with WordPress. |
| APP | 16 | [simongdavies](https://github.com/simongdavies) | [This template creates an Azure VM with AD](https://github.com/simongdavies/AzureRMActiveDirectory) | This template creates a new Azure VM, with a public IP address, load balancer and VNet, it configures the VM to be an AD DC for a new Forest. |
| 201 | 17 | [mahthi](https://github.com/mahthi) | [Deploy 'n' Virtual Machines from a user image using Resource Loops](https://github.com/Azure/azure-quickstart-templates/tree/master/resource-loop-vms-userimage) | This template allows you to create 'N' number of Virtual Machines from a User image based on the 'numberOfInstances' parameter specified during the template deployment.  |
| DEV | 18 | [arsenvlad](https://github.com/arsenvlad) | [Deploy 'n' Ubuntu VMs with memcached service and one Apache test VM](https://github.com/azure/azure-quickstart-templates/tree/master/memcached-multi-vm-ubuntu) | This template allows you to create multiple (based on the 'numberOfMemcachedInstances' parameter) Ubuntu 14.04 VMs in a private-only subnet and installs and configures memcached service on each VM. It also creates one publicly accessible Apache VM with a PHP test page to confirm that memcached is installed and accessible. |
| DEV | 19 | [thecaterminator](https://github.com/TheCATerminator) | [Deploy a Redis cluster with configurable number of nodes](https://github.com/Azure/azure-quickstart-templates/tree/master/redis-high-availability) | This template deploys a Redis cluster on the Ubuntu virtual machines. The deployment topology is comprised of a customizable number of nodes joined into a cluster. The cluster is pre-configured with persistence and other optimizations as per best practices. |
| DEV | 20 | [anweiss](https://github.com/anweiss) | [Deploy an Ubuntu VM with Drone CI.](https://github.com/Azure/azure-quickstart-templates/tree/master/drone-ubuntu-vm) | This template provisions an Ubuntu Linux VM on Azure and bootstraps it with the latest release of the Drone continuous integration toolset. |
| APP | 21 | [justintian](https://github.com/justintian) | [Create HPC Cluster on Azure](https://github.com/Azure/azure-quickstart-templates/tree/master/create-hpc-cluster) | This template provisions an HPC Pack Cluster on Azure |
| 101 | 22 | [singhkay](https://github.com/singhkay) | [Windows VM with Anti-Malware extension](https://github.com/Azure/azure-quickstart-templates/tree/master/anti-malware-extension-windows-vm) | This template creates a Windows VM with Anti-Malware extension|
| APP | 23 | [trentmswanson](https://github.com/trentmswanson) [arsenvlad](https://github.com/arsenvlad) | [PostgreSQL 9.3 on Ubuntu VMs](https://github.com/Azure/azure-quickstart-templates/tree/master/postgresql-on-ubuntu) | This template creates one master PostgreSQL 9.3 server with streaming-replication to multiple slave servers. |
| 101 | 24 | [singhkay](https://github.com/singhkay) | [Create a standard Storage Account](https://github.com/Azure/azure-quickstart-templates/tree/master/101-create-storage-account-standard) | This template creates a Storage Account|
| 201 | 25 | [trentmswanson](https://github.com/trentmswanson) | [Create Ubuntu vm data disk raid0](https://github.com/Azure/azure-quickstart-templates/tree/master/diskraid-ubuntu-vm) | Create Ubuntu vm data disk raid0|
| 101 | 26 | [sung-msft](https://github.com/sung-msft) | [Create a Windows VM with Symantec Endpoint Protection extension enabled](https://github.com/Azure/azure-quickstart-templates/tree/master/symantec-extension-windows-vm) | Create a Windows VM with Symantec Endpoint Protection extension enabled|
| APP | 27 | [johndehavilland](https://github.com/johndehavilland) | [Create an ElasticSearch cluster on Windows](https://github.com/Azure/azure-quickstart-templates/tree/master/elasticsearch-on-windows) | Create an ElasticSearch cluster on Windows |
| DEV | 28 | [madhana](https://github.com/madhana) | [Deploy a Django app](https://github.com/Azure/azure-quickstart-templates/tree/master/django-app) | Deploy a Django app |
| DEV | 29 | [paigeliu](https://github.com/liupeirong) | [Deploy a Gluster file system on CentOS](https://github.com/Azure/azure-quickstart-templates/tree/master/gluster-file-system) | Deploy a N node gluster file system with a replication factor of 2. Each node has 2 disks stripped |
