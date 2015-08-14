<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fthinkbox-deadline%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>


This template creates a functioning Deadline 7.2 render environment on the Azure cloud platform. It includes a sample Maxwell render job and a standalone Krakatoa render job. 


## Using Deadline

It will start a repository machine and any number of slave instances (default is 2). Resume the jobs to start rendering.
All output will be sent to C:\Data\Output on the Repository Virtual Machine.

## Parameters

| Name   | Description    |
|:--- |:---|
| location | This is the location where all the resources will be deployed. |
| publicDnsName | Unique public dns name. | 
| storageAccount | Unique storage account name. |
| adminUsername | User name to remote into the Virtual Machine. |
| adminPassword | Password of the admin user. |
| numberOfSlaves | Number of slave Virtual Machines to start. |