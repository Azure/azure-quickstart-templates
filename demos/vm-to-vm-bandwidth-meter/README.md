---
description: This template allows you to run VM-to-VM bandwidth test with PsPing utility.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: vm-to-vm-bandwidth-meter
languages:
- json
---
# Azure VM-to-VM bandwidth meter

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vm-to-vm-bandwidth-meter/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vm-to-vm-bandwidth-meter/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vm-to-vm-bandwidth-meter/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vm-to-vm-bandwidth-meter/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vm-to-vm-bandwidth-meter/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vm-to-vm-bandwidth-meter/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fvm-to-vm-bandwidth-meter%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fvm-to-vm-bandwidth-meter%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fvm-to-vm-bandwidth-meter%2Fazuredeploy.json)

This template allows you to run a VM-to-VM bandwidth test using PsPing utility.
Please note that by deploying this template you are automatically accepting [Sysinternals Software License Terms](https://technet.microsoft.com/sysinternals/bb469936).

The VM sizes selected should be available in chosen regions. Please check availability [here](https://azure.microsoft.com/regions/services/).
See VM series/sizes [description](https://azure.microsoft.com/documentation/articles/virtual-machines-windows-sizes/).

Upon template deployment you will have the bandwidth between the VMs automatically measured. You can see the measurements:

```powershell
OutputsString           :
                          Name                 Type                       Value
                          ===============      =========================  ==========
                          bandwidthtestresult  String                     Minimum = 124.83 MB/s, Maximum = 124.83 MB/s, Average = 124.83 MB/s
```

![alt text](images/bandwidth.png "Bandwidth measurement output")

To re-measure the bandwidth you can login to the probe VM with credentials you provided during deployment.

In case you don't need to re-measure, it is safe to delete the created resource group.

`Tags: Microsoft.Network/publicIPAddresses, Microsoft.Network/virtualNetworks, Microsoft.Network/networkSecurityGroups, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines, Microsoft.Compute/virtualMachines/extensions, CustomScriptExtension, CustomScript`
