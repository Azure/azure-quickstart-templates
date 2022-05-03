# Deploy a specified number of Ubuntu VMs configured with Chef Client

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/chef/multi-vm-chef-template-ubuntu-vm/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/chef/multi-vm-chef-template-ubuntu-vm/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/chef/multi-vm-chef-template-ubuntu-vm/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/chef/multi-vm-chef-template-ubuntu-vm/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/chef/multi-vm-chef-template-ubuntu-vm/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/chef/multi-vm-chef-template-ubuntu-vm/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fchef%2Fmulti-vm-chef-template-ubuntu-vm%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fchef%2Fmulti-vm-chef-template-ubuntu-vm%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fchef%2Fmulti-vm-chef-template-ubuntu-vm%2Fazuredeploy.json)   

## Description

This template provisions multiple Linux Ubuntu VMs on Azure and bootstraps it with Chef client version 1210.12.

The pre-requisite for deploying this template is to have a running Chef Server. You can achieve this in Azure by using the [Chef Automate Marketplace image](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/chef-software.chef-automate?tab=Overview).  More instructions on [installing and configuring Chef Automate in the Azure Marketplace](https://docs.chef.io/azure_portal.html)

This template provides the minimum settings to get started. For a full list of configuration options/examples for the Chef VM Extension, please see the [ARM template documentation](https://docs.chef.io/azure_portal.html#azure-resource-manager-arm-templates)

## Useful Links for learning Chef

- [Get Started with Chef](http://learn.chef.io/)
- [Chef Pricing and Licensing](https://www.chef.io/chef/#plans-and-pricing)
- [Chef Training](https://www.chef.io/training/)
- [Using Chef Server in the Azure Marketplace](https://docs.chef.io/azure_portal.html)
- [Chef Documentation](http://docs.chef.io/)
