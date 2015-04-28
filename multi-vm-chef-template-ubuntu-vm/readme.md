# Single Click provisioning of multiple instances of Ubuntu VMs and with Chef Agent.

| Deploy to Azure  | Author                          | Template Name   |
|:-----------------|:--------------------------------| :---------------| :---------------|
| <a href="https://azuredeploy.net/" target="_blank"><img src="http://azuredeploy.net/deploybutton_small.png"/></a> | [kundanap](https://github.com/kundanap) | Provision a Ubuntu VM and  bootstrapp the Chef Agent (https://github.com/Azure/azure-quickstart-templates/tree/master/multi-vm-chef-template-ubuntu-vm)


This template provisions multiple Linux Ubuntu VMs on Azure and bootstraps it with Chef client version 1201.12.

Useful Links for learning about Chef:

<a href="http://learn.chef.io/" target="_blank">Get Started with Chef</a>

<a href="https://www.chef.io/chef/#plans-and-pricingx" target="_blank">Chef Pricing and Licensing</a>

<a href="https://www.chef.io/training/" target="_blank">Chef Training</a>

<a href="https://docs.chef.io/azure_portal.html#azure-marketplace" target="_blank">Using Chef Server in the Azure Marketplace</a>

<a href="http://docs.chef.io/" target="_blank">Chef Documentation</a>

 For deploying the Chef agent on a VM, you can create a hosted Chef account or spin off Chef Server in Azure using the Marketplace image which is free upto 20 nodes. More on Marketplace image : <a href="https://docs.chef.io/azure_portal.html#azure-marketplace" target="_blank">Using Chef Server in the Azure Marketplace</a>

 This template expects the following parameters:

 | Name   | Description    |
 |:--- |:---|
 | location | Location name where the corresponding Azure artifacts will be created |
 | storage account  | Unique  Name for the Storage Account where the Virtual Machine's disks will be placed |
 | dnsName | DNS subnet name for operations center public IP address |
 | virtualNetworkName | Name of the Virtual Network that is created and that resources will be deployed in to |
 | adminUsername  | Admin user name for the Virtual Machines  |
 | adminPassword  | Admin password for the Virtual Machines  |
 | numberOfInstances <Optional>  | Number of VMs to create from 1-40, default is 2 |
 | availabilitySetName  | Name of the availability set for placing the VMs. |
 | image Publisher <Optional> | Publisher for the OS image, the default is Canonical|
 | image Offer <Optional> | The name of the image offer. The default is Ubuntu |
 | image SKU  <Optional> | Version of the image. The default is 14.04.2-LTS |
 | chef_node_name | The name for the node (VM) in the Chef Organization |
 | chef_server_url | Organization URL for the Chef Server. Example "https://ChefServerDnsName.cloudapp.net/organizations/Orgname"|
 | validation_client_name | Validator key name for the organization. Example : MyOrg-validator |
 | runlist <Optional> | An optional runlist to execute post provisioning. Example "recipe[getting-started]" |
 | autoUpdateClient <Optional> | Flag for enrolling the VM into auto-updates. The default is 'false.''|
 | validation_key | Json escaped contents of the org valiator pem file.|
