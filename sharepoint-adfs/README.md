# AzureRM template for SharePoint 2016 and 2013 configured with ADFS

## Description

This template deploys a full SharePoint 2013 or 2016 environment with 3 VMs (DC, SQL and SharePoint), each with its own public IP address and a subnet protected with a Network Security Group:

* A Domain Controller with AD CS and AD FS configured, and 2 additional DNS zones to support SharePoint apps.
* A SQL Server 2016
* SharePoint (2013 or 2016) VM is configured with 1 web application and 2 zones (Default uses Windows and Intranet uses ADFS). Latest version of claims provider [LDAPCP](http://ldapcp.com/) is installed and configured. User Profile and Apps (addins) services are fully configured in the farm.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsharepoint-adfs%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsharepoint-adfs%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

With the default sizes of virtual machines, provisioning of the template takes about 1h to complete.
