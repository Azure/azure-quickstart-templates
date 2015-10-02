# Application Gateway With Public IP and HTTPS Listener

Built by: [puneetsaraswat](https://github.com/puneetsaraswat)

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-create-applicationgateway-publicip-ssl-offload%2Fazuredeploy.json)


This template creates an Application Gateway, Public IP address for the Application Gateway, and the Virtual Network in which Application Gateway is deployed. Also configures Application Gateway for Ssl Offload and Load balancing with Two backend servers. 

Tip: To get the certData from pfx file in PowerShell you can use this: [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes("path to pfx file"))


Below are the parameters that the template expects

| Name                      | Description                                               |
|:-------------------------:|:---------------------------------------------------------:|
| location                  | Azure region where the resource will be deployed to       |
| addressPrefix             | Prefix for the address in CIDR format                     |
| subnetPrefix              | Prefix for the subnet in CIDR format                      |
| skuName                   | Sku Name                                                  |
| capacity                  | Number of instances                                       |
| backendIpAddress1         | IP Address for Backend Server 1                           |
| backendIpAddress2         | IP Address for Backend Server 2                           |
| certData                  | Base-64 encoded form of the .pfx file                     |
| certPassword              | Password for .pfx certificate                             |