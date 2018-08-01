# AzureRM template for SharePoint 2016 and 2013 configured with ADFS

## Description

This template deploys SharePoint 2013 or 2016 with following configuration:

* 1 web application with 2 zones: Default zone uses Windows and Intranet zone uses ADFS. A couple of site collections are created
* User Profiles and Addins service applications are provisioned
* 2 extra DNS zones are created to support SharePoint apps, and app domains are set in all zones of the web application.
* Latest version of claims provider [LDAPCP](https://ldapcp.com/) is installed and configured
* A certificate authority (ADCS) is provisioned on the DC and is used for all certificates issued (ADFS and the HTTPS site in Intranet zone)
* ADFS is configured on the DC with a relying party for SharePoint web application
* A font-end can be optionnally added to the farm
* Super user / super reader are set

Each VM has its own public IP address and is in a subnet protected with a Network Security Group.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsharepoint-adfs%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsharepoint-adfs%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

With the default sizes of virtual machines, provisioning of the template takes about 1h15 to complete.
