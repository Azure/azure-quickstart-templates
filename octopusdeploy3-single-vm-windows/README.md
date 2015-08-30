# Octopus Deploy 3.0 with trial license

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Foctopusdeploy3-single-vm-windows%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

Built by: [paulbouwer](https://github.com/paulbouwer)

This template allows you to deploy a single Octopus Deploy 3.0 server with a trial license. This will deploy on a single Windows Server 2012R2 VM (Standard D2) and SQL DB (S1 tier) into the location specified for the Resource Group.

Below are the parameters that the template expects: 

| Name   | Description    |
|:--- |:---|
| vmStorageAccountName  | Unique DNS Name for the Storage Account that will hold the Octopus Deploy Virtual Machine Disks.  |
| vmAdminUsername  | Admin username for the Octopus Deploy Virtual Machine. Azure will not allow common usernames like 'admin' or 'administrator' so ensure you pick something else. Default value: **octoadmin**. |
| vmAdminPassword  | Admin password for the Octopus Deploy Virtual Machine. |
| networkDnsName | Unique DNS Name used to access the Octopus Deploy server via HTTP or RDP. |
| sqlServerName | Unique DNS Name for the SQL DB Server that will hold the Octopus Deploy data. |
| sqlAdminUsername | Admin username for the Octopus Deploy SQL DB Server. Default value: **sqladmin**. |
| sqlAdminPassword | Admin password for the Octopus Deploy SQL DB Server. |
| licenseFullName | Octopus Deploy Trial license - Full Name. |
| licenseOrganisationName | Octopus Deploy Trial license - Organisation Name. |
| licenseEmailAddress | Octopus Deploy Trial license - Email Address. |
| octopusAdminUsername | Admin username for the Octopus Deploy web application. Default value: **admin**. |
| octopusAdminPassword | Admin password for the Octopus Deploy web application. |
