# Creates Remote Desktop Sesson Collection deployment

This template deploys the following resources:

<ul><li>storage account;</li><li>vnet, public ip, load balancer;</li><li>domain controller vm;</li><li>RD Gateway/RD Web Access vm;</li><li>RD Connection Broker/RD Licensing Server vm;</li><li>a number of RD Session hosts (number defined by 'numberOfRdshInstances' parameter)</li></ul>

The template will deploy DC, join all vms to the domain and configure RDS roles in the deployment.

Click the button below to deploy

<a href="https://azuredeploy.net" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| storageAccountName  | Name of the storage account to create    |
| location  | Location where to deploy the resource <br><ul>**Allowed Values**<li>**West US (default)**</li><li>East US</li><li>West Europe</li><li>East Asia</li><li>Southeast Asia</li>|
| domainName | The FQDN of the AD Domain created |
| adminUsername | Domain admin username |
| adminPassword | Domain admin password |
| sourceImageName | Name of image to use for all the vm <br> <ul><li>a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-R2-201503.01-en.us-127GB.vhd **(default)**</li></ul>|
| publicDnsName | The DNS prefix for the public IP address |
| numberOfRdshInstances | Number of RDSH instances **(default: 2)** |
| rdshVmSize | The size of the RDSH VMs **(default: Standard_A2)** |


