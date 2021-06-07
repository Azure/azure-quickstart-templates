# 1 VM in vNet - Multiple data disks

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/storage-iops-latency-throughput-demo/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/storage-iops-latency-throughput-demo/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/storage-iops-latency-throughput-demo/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/storage-iops-latency-throughput-demo/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/storage-iops-latency-throughput-demo/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/storage-iops-latency-throughput-demo/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fstorage-iops-latency-throughput-demo%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)(https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fstorage-iops-latency-throughput-demo%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fstorage-iops-latency-throughput-demo%2Fazuredeploy.json)
    

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fstorage-iops-latency-throughput-demo%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fstorage-iops-latency-throughput-demo%2Fazuredeploy.json)

This template is designed to create a demo environment to test the IOPS, latency and throughput on different types of Azure disks, as described in the following blogs posts:

<a href="https://blogs.technet.microsoft.com/andrewc/2016/09/09/understanding-azure-virtual-machine-iops-throughput-and-disk-latency/" target="_blank">https://blogs.technet.microsoft.com/andrewc/2016/09/09/understanding-azure-virtual-machine-iops-throughput-and-disk-latency/

<a href="https://blogs.technet.microsoft.com/andrewc/2016/09/09/understanding-azure-virtual-machine-iops-throughput-and-disk-latency-part-2/" target="_blank">https://blogs.technet.microsoft.com/andrewc/2016/09/09/understanding-azure-virtual-machine-iops-throughput-and-disk-latency-part-2/

This template creates a single VM running Windows Server 2016 with multiple data disks attached.

This template also deploys a Storage Account, Virtual Network and Public IP Address.

The VM is an S-class size which supports Azure Premium Storage disks.

The template also used the PowerShell Desired State Configuration (DSC) VM extension to: 
* Prepare and format the data disks
* Install ioMeter using Chocolatey
* Download and extract 20 pre-defined ioMeter tests to C:\iometerTests


