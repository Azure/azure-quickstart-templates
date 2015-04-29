# Provision a Ubuntu VM and  bootstrapping the Chef Agent.

| Deploy to Azure  | Author                          | Template Name   |
|:-----------------|:--------------------------------| :---------------| :---------------|
| <a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fchef-json-parameters-ubuntu-vm%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton_small.png"/></a> | [kundanap](https://github.com/kundanap) | Provision a Ubuntu VM and  bootstrapp the Chef Agent (https://github.com/Azure/azure-quickstart-templates/tree/master/chef-json-parameters-ubuntu-vm)


 This template provisions a Linux Ubuntu VM on Azure and bootstraps it with Chef client version 1201.12.

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
 | dnsName | DNS name for the VM |
 | adminUsername  | Admin user name for the Virtual Machines  |
 | adminPassword  | Admin password for the Virtual Machine  |
 | image Publisher <Optional> | Publisher for the OS image, the default is Canonical|
 | image Offer <Optional> | The name of the image offer. The default is Ubuntu |
 | image SKU  <Optional> | Version of the image. The default is 14.04.2-LTS |
 | vm Size  <Optional> | Size of the Virtual Machine. The default is Standard_A0 |
 | chef_node_name | The name for the node (VM) in the Chef Organization |
 | chef_server_url | Organization URL for the Chef Server. Example "https://ChefServerDnsName.cloudapp.net/organizations/Orgname"|
 | validation_client_name | Validator key name for the organization. Example : MyOrg-validator |
 | runlist <Optional> | An optional runlist to execute post provisioning. Example "recipe[getting-started]" |
 | autoUpdateClient <Optional> | Flag for enrolling the VM into auto-updates. The default is 'false.''|
 | validation_key | Json escaped contents of the org valiator pem file.|
