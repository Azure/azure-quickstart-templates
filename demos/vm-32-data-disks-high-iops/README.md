---
description: This template creates a Standard D14 VM with 32 data disks attached.  Using DSC they are automatically striped per best practices to get maximum IOPS and formatted into a single volume.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: vm-32-data-disks-high-iops
languages:
- json
---
# High IOPS 32 Data Disk storage pool Standard D14 VM

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vm-32-data-disks-high-iops/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vm-32-data-disks-high-iops/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vm-32-data-disks-high-iops/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vm-32-data-disks-high-iops/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vm-32-data-disks-high-iops/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vm-32-data-disks-high-iops/CredScanResult.svg)

Create a VM from 32 Data Disks configured for high IOPS

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fvm-32-data-disks-high-iops%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fvm-32-data-disks-high-iops%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fvm-32-data-disks-high-iops%2Fazuredeploy.json)

This template creates an instance with the maximum number of data disks configured in a simple storage space.   It creates a new volume with the target interleave of 64KB striped across the number of disks present.  The volume is formatted with NTFS and presented as the H:\.    This is ideal for IOPS and throughput intensive workloads while still leveraging standard storage.  The storage account created is locally redundant (LRS) as geo-redundant (GRS) would potentially be corrupted replicas to do the async process.

`Tags: Microsoft.Network/publicIPAddresses, Microsoft.Network/networkSecurityGroups, Microsoft.Network/virtualNetworks, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines, Microsoft.Compute/virtualMachines/extensions, DSC`
