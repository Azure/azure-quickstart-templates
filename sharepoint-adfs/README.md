# AzureRM template for SharePoint 2016 and 2013 configured with ADFS

## Description

This template deploys 3 new Azure VMs, each with its own public IP address and subnet:

* A new AD Domain Controller with a root certificate authority (AD CS) and AD FS configured
* A SQL Server 2016
* A single server running a SharePoint 2016 or 2013 farm configured with 1 web application and 2 zones. Default zone is using Windows authentication and Intranet zone is using federated authentication with ADFS. Latest version of claims provider [LDAPCP](http://ldapcp.com/) is installed and configured. Some service applications and site collections are also provisionned.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsharepoint-adfs%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsharepoint-adfs%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

With the default sizes of virtual machines, provisioning of the template takes about 1h30 - 1h45 to complete.

## Known issues or limitations

### On SQL VM

* SQL DSC module currently doesn't allow to change location of log/data files, so all SQL data/log files are created in their default folders in C drive.

### On SharePoint VM

* Download of 2016-12 CU from download.microsoft.com randomly fails, causing the whole SharePoint configuration to fail, so it is disabled until a reliable solution is found.
