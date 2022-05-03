# Azure VM-to-VM multithreaded throughput meter

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vm-to-vm-throughput-meter-multithreaded/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vm-to-vm-throughput-meter-multithreaded/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vm-to-vm-throughput-meter-multithreaded/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vm-to-vm-throughput-meter-multithreaded/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vm-to-vm-throughput-meter-multithreaded/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vm-to-vm-throughput-meter-multithreaded/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fvm-to-vm-throughput-meter-multithreaded%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fvm-to-vm-throughput-meter-multithreaded%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fvm-to-vm-throughput-meter-multithreaded%2Fazuredeploy.json)

This template allows you to run a VM-to-VM network throughput test for the same VNet/subnet using NTttcp utility. [See licence agreement](https://gallery.technet.microsoft.com/NTttcp-Version-528-Now-f8b12769).

The VM sizes selected should be available in chosen region. Please check availability [here](https://azure.microsoft.com/en-us/regions/services/).
See VM series/sizes [description](https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-windows-sizes/).

Upon template deployment you will have the network throughput between the VMs automatically measured. You can see the measurements:

```powershell
OutputsString           : 
                          Name             Type                       Value     
                          ===============  =========================  ==========
                          throughput MB/s  String                     229.453   
                          throughput mbps  String                     1924.787  
                          throughput buffers/s  String                     1835.620 
```

![alt text](images/throughput.png "Throughput measurement output")

To re-measure the throughput you can login to the probe and target VMs with credentials you provided during deployment.

In case you don't need to re-measure, it is safe to delete the created resource group.



