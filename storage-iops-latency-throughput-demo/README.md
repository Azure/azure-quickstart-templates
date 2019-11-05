# 1 VM in vNet - Multiple data disks

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/storage-iops-latency-throughput-demo/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/storage-iops-latency-throughput-demo/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/storage-iops-latency-throughput-demo/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/storage-iops-latency-throughput-demo/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/storage-iops-latency-throughput-demo/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/storage-iops-latency-throughput-demo/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fstorage-iops-latency-throughput-demo%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fstorage-iops-latency-throughput-demo%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template is designed to create a demo environment to test the IOPS, latency and throughput on different types of Azure disks, as described in the following blogs posts:

<a href="https://blogs.technet.microsoft.com/andrewc/2016/09/09/understanding-azure-virtual-machine-iops-throughput-and-disk-latency/" target="_blank">https://blogs.technet.microsoft.com/andrewc/2016/09/09/understanding-azure-virtual-machine-iops-throughput-and-disk-latency/</a>

<a href="https://blogs.technet.microsoft.com/andrewc/2016/09/09/understanding-azure-virtual-machine-iops-throughput-and-disk-latency-part-2/" target="_blank">https://blogs.technet.microsoft.com/andrewc/2016/09/09/understanding-azure-virtual-machine-iops-throughput-and-disk-latency-part-2/</a>

This template creates a single VM running Windows Server 2016 with multiple data disks attached.

This template also deploys a Storage Account, Virtual Network and Public IP Address.

The VM is an S-class size which supports Azure Premium Storage disks.

The template also used the PowerShell Desired State Configuration (DSC) VM extension to: 
* Prepare and format the data disks
* Install ioMeter using Chocolatey
* Download and extract 20 pre-defined ioMeter tests to C:\iometerTests

