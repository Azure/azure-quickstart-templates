# 1 VM in vNet - Multiple data disks

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sample-managed-disks/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sample-managed-disks/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sample-managed-disks/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sample-managed-disks/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sample-managed-disks/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sample-managed-disks/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fjamesbannan%2Fazure-quickstart-templates%2Fmaster%2Fstorage-iops-latency-throughput-demo%2Fsample-managed-disks%2FmanagedDisksDemo.json" target="_blank">
    

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fjamesbannan%2Fazure-quickstart-templates%2Fmaster%2Fstorage-iops-latency-throughput-demo%2Fsample-managed-disks%2FmanagedDisksDemo.json target="_blank">

This template is designed to create a demo environment to test the IOPS, latency and throughput on different types of Azure disks, as described in the following blogs posts:

<a href="https://blogs.technet.microsoft.com/andrewc/2016/09/09/understanding-azure-virtual-machine-iops-throughput-and-disk-latency/" target="_blank">https://blogs.technet.microsoft.com/andrewc/2016/09/09/understanding-azure-virtual-machine-iops-throughput-and-disk-latency/

<a href="https://blogs.technet.microsoft.com/andrewc/2016/09/09/understanding-azure-virtual-machine-iops-throughput-and-disk-latency-part-2/" target="_blank">https://blogs.technet.microsoft.com/andrewc/2016/09/09/understanding-azure-virtual-machine-iops-throughput-and-disk-latency-part-2/

This template creates a single VM running Windows Server 2016 with multiple data disks attached using Managed Disks.

This template also deploys a Storage Account, Virtual Network and Public IP Address.

The VM is an S-class size which supports Azure Premium Storage disks.

The template also used the PowerShell Desired State Configuration (DSC) VM extension to: 
* Prepare and format the data disks
* Install ioMeter using Chocolatey
* Download and extract 20 pre-defined ioMeter tests to C:\iometerTests


