# Create an Environment with a VM that can be RDP'd Externally

<a
[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://azuredeploy.net/)
</a>
Built by: [danielsollondon](https://github.com/danielsollondon)

This template allows you to create a VNET, subnet, with the associated NSG, Public IP, load balancer with a sample RDP NAT rule. Finally it creates a VM with 2 data disks, Network Interface attached. You can specify the Windows OS you would like.

Below are the parameters that the template requires.

| Name   | Description    |
|:--- |:---|
| newStorageAccountName  | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed. |
storageAccountType | Storage Account type, e.g. "Standard LRS"
location | location of RG, e.g. "West US" |
dnsNameforLBIP | Unique DNS Name for the Public IP used to route to the Virtual Machine. |
vmName | Name of VM to create |
vmSize | E.g. "Standard_A1" |
adminUserName | Admin username |
adminPassword | Admin Password |
virtualNetworkName | Name of VNET to creates |
nicName | NIC Resource for VM name |
loadBalancerName | Loadbalancer Resource Name |
publicIPAddressName | Public IP Resource Name |
availabilitySetName | Availability Set Resource Name |
networkSecurityGroupName | Network Security Group Resource Name |
windowsOSVersion | Select windows OS to deploy "2012-R2-Datacenter" |
sizeOfDiskInGB | Size of data disks in GB, e.g. 20 |
