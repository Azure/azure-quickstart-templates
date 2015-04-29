# Create 2 Virtual Machines under a Load balancer and configures Load Balancing rules for the VMs

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FDrewm3%2Fazure-quickstart-templates%2Fmaster%2F201-2-vms-loadbalancer-lbrules%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to create 2 Virtual Machines under a Load balancer and configure a load balancing rule on Port 80. This template also deploys a Storage Account, Virtual Network, Public IP address, Availability Set and Network Interfaces.

In this template, we use the resource loops capability to create the network interfaces and virtual machines

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| storageAccountName  | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed. |
| adminUsername  | Username for the Virtual Machines  |
| adminPassword  | Password for the Virtual Machine  |
| dnsNameForLBIP  | Unique DNS Name for the Public IP used to access the Virtual Machine. |
| subscriptionId  | Subscription ID where the template will be deployed |
| vmSourceImageName  | Source Image Name for the VM. Example: b39f27a8b8c64d52b05eac6a62ebad85__Ubuntu-12_04_5-LTS-amd64-server-20140927-en-us-30GB |
| region | location where the resources will be deployed |
| vnetName | Name of Virtual Network |
| vmSize | Size of the Virtual Machine |
| vmNamePrefix | NamePrefix for Virtual Machines |
| publicIPAddressName | Name of Public IP Address Name |
| nicNamePrefix | NamePrefix for Network Interfaces |
| lbName | Name for the load balancer |
| backendPort | The Back End Port that needs to be opened on the Virtual Machine Instance. For example: 3389 for RDP, 22 for SSH etc., |
