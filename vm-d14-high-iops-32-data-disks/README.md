# VM-high-iops-data-disks

Create a VM from 32 Data Disks configured for high IOPS

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fvm-d14-high-iops-32-data-disks%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template creates an instance with the maximum number of data disks configured in a simple storage space.   It creates a new volume with the target interleave of 64KB striped across the number of disks present.  The volume is formatted with NTFS and presented as the H:\.    This is ideal for IOPS and throughput intensive workloads while still leveraging standard storage.  The storage account created is locally redundant (LRS) as geo-redundant (GRS) would potentially be corrupted replicas to do the async process.


Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| newStorageAccountName  | Name of the storage account to create |
| adminUsername | Admin username for the VM |
| adminPassword | Admin password for the VM |
| vmSourceImageName | Name of image to use for the VM <br> <ul><li>a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-R2-201503.01-en.us-127GB.vhd **(default)**</li></ul>|
| location  | Location where to deploy the resource  |
| vmSize | Size of the VM <br> <ul>**Currenlty allowed values**<li>Standard_D14 **(default)**</li></ul>|
| sizeOfEachDataDiskInGB | The disks created will all be of this size <ul><li>1023 **(default)**</li></ul>|
| publicIPAddressName | Name of the public IP address to create |
| dnsName | DNS name that will map to the public IP |
| vmStorageAccountContainerName | Name of storage account container for the VM <br> <ul><li>vhds **(default)**</li></ul>|
| vmName | Name for the VM |
| virtualNetworkName | Name of the Virtual Network |
| nicName | Name for the Network Interface |
| modulesUrl | Url for the DSC configuration module <br> <ul> <li><b>https://github.com/Azure/azure-quickstart-templates/blob/master/vm-d14-high-iops-32-data-disks/StoragePool.ps1.zip?raw=true</li></ul>|
