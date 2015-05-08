# Linux Virtual Machine creation with new version of Azure Linux Agent from Github using Custom Script Linux Extension

<a href="https://azuredeploy.net/" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template creates a Linux Virtual Machine with new version of Azure Linux Agent from Github instead of Linux Distro repository. You need check the Linux Agent release ingithub https://github.com/Azure/WALinuxAgent/releases and point out the agent version via parameter LinuxAgentVersion, the default value is 2.0.12. It's a solution before Linux Agent could update itself automatically to latest version. This template also deploys a Storage Account, Virtual Network, Public IP addresses and a Network Interface.

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| newStorageAccountName  | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed. |
| adminUsername  | Username for the Virtual Machines  |
| adminPassword  | Password for the Virtual Machine  |
| dnsNameForPublicIP  | Unique DNS Name for the Public IP used to access the Virtual Machine. |
| subscriptionId  | Subscription ID where the template will be deployed |
| vmSourceImageName  | Source Image Name for the VM. Example: b39f27a8b8c64d52b05eac6a62ebad85__Ubuntu-12_04_5-LTS-amd64-server-20140927-en-us-30GB |
| location | location where the resources will be deployed |
| virtualNetworkName | Name of Virtual Network |
| vmSize | Size of the Virtual Machine |
| vmName | Name of Virtual Machine |
| publicIPAddressName | Name of Public IP Address Name |
| nicName | Name of Network Interface |
| LinuxAgentVersion | Version of Azure Linux Agent, default version 2.0.12 |
