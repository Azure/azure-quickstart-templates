# Creates Remote Desktop Sesson Collection deployment

This template deploys the following resources:

<ul><li>storage account;</li><li>vnet, public ip, load balancer;</li><li>domain controller vm;</li><li>RD Gateway/RD Web Access vm;</li><li>RD Connection Broker/RD Licensing Server vm;</li><li>a number of RD Session hosts (number defined by 'numberOfRdshInstances' parameter)</li></ul>

The template will deploy DC, join all vms to the domain and configure RDS roles in the deployment.

Click the button below to deploy

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Frds-deployment%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| publicDnsName | The DNS prefix for the public IP address |
| storageAccount | Name of the storage account to create |
| domainName | Domain name (e.g. 'contoso.com') |
| adminUsername | Domain admin username |
| adminPassword | Domain admin password |
| numberOfRdshInstances | Number of RDSH instances **(default: 2)** |
| rdshVmSize | The size of the RDSH VMs **(default: Standard_A2)** |




