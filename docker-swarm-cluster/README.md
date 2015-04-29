# Deploy Docker swarm cluster on a Virtual Machines

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdocker-swarm-cluster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to create a Docker swarm cluster on a VM on Azure.

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| storageAccountNamePrefix  | Storage Account Name Prefix where the Virtual Machine's disks will be placed. |
| adminUsername  | Username for the Virtual Machines  |
| adminPassword  | Password for the Virtual Machines  |
| subscriptionId  | Subscription ID where the template will be deployed |
| scaleNumberPerRegion  | Number of Virtual Machine instances to create per Region  |
| virtualNetworkNamePrefix | Virtual Network Name Prefix |
| vmNamePrefix | Virtual Machine Name Prefix |
| publicIPAddressNamePrefix | Public IP address Name Prefix |
| nicNamePrefix | Network Interface Name Prefix |
