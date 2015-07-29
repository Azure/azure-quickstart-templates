# Create a VM with multiple NICs and RDP accessible

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-1-vm-loadbalancer-2-nics%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to create a Virtual Machines with multiple (2) network interfaces (NICs), and RDP connectable with a configured load balancer and an inbound NAT rule. More NICs can easily  be added with this template. This template also deploys a Storage Account, Virtual Network, Public IP address, and 2 Network Interfaces (front-end and back-end).

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
