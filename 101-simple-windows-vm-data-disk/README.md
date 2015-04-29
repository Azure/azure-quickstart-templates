# Very simple deployment of an Windows VM with a single empty Data Disk 

    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

Built by: [kenazk](https://github.com/kenazk)

This template allows you to deploy a simple Windows VM using a few different options for the Windows version, using the latest patched version. This will deploy in West US on a D1 VM Size and attach an empty data disk to it. 

Below are the parameters that the template expects: 

| Name   | Description    |
|:--- |:---|
| newStorageAccountName  | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed. |
| adminUsername  | Username for the Virtual Machine  |
| adminPassword  | Password for the Virtual Machine  |
| dnsNameForPublicIP  | Unique DNS Name for the Public IP used to access the Virtual Machine. |
| windowsOSVersion  | The Windows version for the VM. This will pick a fully patched image of this given Windows version. Allowed values: 2008-R2-SP1, 2012-Datacenter, 2012-R2-Datacenter, Windows-Server-Technical-Preview |
| sizeOfDiskInGB | The size of disk in GB | 
