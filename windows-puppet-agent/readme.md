# Deploy a windows VM with Puppet agent .


| Deploy to Azure  | Author                          | Template Name
|:-----------------|:--------------------------------| :---------------| :---------------|
| <a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fwindows-puppet-agent%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton_small.png"/></a> | [kundanap](https://github.com/gbowerman) | [Puppet Agent on windows Azure VM(https://github.com/azurermtemplates/azurermtemplates/tree/master/windows-puppet-agent)

This template provisions a Windows VM on Azure with the Puppet Agent installed using a VM Extension.

The pre-requiste for deploying this template is to having a running Puppet server. You can host your own Puppet server in Azure or on-prem or create a Puppet Server in Azure using the Azure Marketplace image and following the guidelines for: <a href="https://puppetlabs.com/sites/default/files/Microsoft-Powershell-cmdlets.pdf" target="_blank">Getting Started Guide for Deploying Puppet Enterprise in Azure</a>

 This template expects the following parameters:

 | Name   | Description    |
 |:--- |:---|
 | location | Location name where the corresponding Azure artifacts will be created |
 | storage account  | Unique  Name for the Storage Account where the Virtual Machine's disks will be placed |
 | dnsName | Unique DNS Name for the VM. |
 | vm Size  <Optional> | Size of the Virtual Machine. The default is Standard_A0 |
 | adminUsername  | Admin user name for the Virtual Machines  |
 | adminPassword  | Admin password for the Virtual Machines  |
 | image Publisher <Optional> | Publisher for the OS image, the default is MicrosoftWindowsServer|
 | image Offer <Optional> | The name of the image offer. The default is WindowsServer |
 | image SKU  <Optional> | Version of the image. The default is 2012-R2-Datacenter |
 | puppet_master_server | Puppet Master URL |
