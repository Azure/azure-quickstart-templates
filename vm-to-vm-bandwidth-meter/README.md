# Azure VM-to-VM bandwidth meter

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/vm-to-vm-bandwidth-meter/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/vm-to-vm-bandwidth-meter/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/vm-to-vm-bandwidth-meter/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/vm-to-vm-bandwidth-meter/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/vm-to-vm-bandwidth-meter/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/vm-to-vm-bandwidth-meter/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fvm-to-vm-bandwidth-meter%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fvm-to-vm-bandwidth-meter%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>


This template allows you to run a VM-to-VM bandwidth test using PsPing utility.
Please note that by deploying this template you are automatically accepting [Sysinternals Software License Terms](https://technet.microsoft.com/en-us/sysinternals/bb469936).

The VM sizes selected should be available in chosen regions. Please check availability [here](https://azure.microsoft.com/en-us/regions/services/).
See VM series/sizes [description](https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-windows-sizes/).

Upon template deployment you will have the bandwidth between the VMs automatically measured. You can see the measurements:

```powershell
OutputsString           : 
                          Name             Type                       Value     
                          ===============  =========================  ==========
                          bandwidthtestresult  String                     Minimum = 124.83 MB/s, Maximum = 124.83 MB/s, Average = 124.83 MB/s
```

![alt text](images/bandwidth.png "Bandwidth measurement output")

To re-measure the bandwidth you can login to the probe VM with credentials you provided during deployment.

In case you don't need to re-measure, it is safe to delete the created resource group.

