# Deploy a Virtual Machine with CustomData

<a href="https://azuredeploy.net/" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to create a Virtual Machine with Custom Data. This template also deploys a Storage Account, Virtual Network, Public IP addresses and a Network Interface.

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| newStorageAccountName  | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed. |
| adminUsername  | Username for the Virtual Machines  |
| adminPassword  | Password for the Virtual Machine  |
| customData  | Specifies a base-64 encoded string of custom data. The base-64 encoded string is decoded to a binary array that is saved as a file on the Virtual Machine. The maximum length of the binary array is 65535 bytes. In Linux VMs, The base-64 encoded string is located in the ovf-env.xml file on the ISO of the Virtual Machine. The file is copied to /var/lib/waagent/ovf-env.xml by the Azure Linux Agent. The agent will also place the base-64 encoded data in /var/lib/waagent/CustomData during provisioning. In Windows VMs, the file is saved to %SYSTEMDRIVE%\AzureData\CustomData.bin. If the file exists, it is overwritten. The security on directory is set to System:Full Control and Administrators:Full Control. |
| dnsNameForPublicIP  | Unique DNS Name for the Public IP used to access the Virtual Machine. |
| vmSize | Size of the Virtual Machine |