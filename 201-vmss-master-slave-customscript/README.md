# Deploy a VM Scale Set of Linux VMs with a custom script extension in master / slave architecture

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vmss-master-slave-customscript/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vmss-master-slave-customscript/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vmss-master-slave-customscript/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vmss-master-slave-customscript/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vmss-master-slave-customscript/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vmss-master-slave-customscript/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https://github.com/Azure/azure-quickstart-templates/tree/master/201-vmss-master-slave-customscript/azuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https://github.com/Azure/azure-quickstart-templates/tree/master/201-vmss-master-slave-customscript/azuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

## Description
This template allows you to deploy a VM Scale Set of Linux VMs and create a new virtual network at the same time. These VMs have a custom script extension for customization and are behind a load balancer with NAT rules for SSH connections. This allows to specify the master node number and data node number, adapt to any master / slave architecture

## Using new features 

To enable Accelerated Networking feature ( SR-IOV ) which is a free feature, using the following example : 

In network profile of VMSS , set "enableAcceleratedNetworking" to true, to have more information, please go to https://docs.microsoft.com/en-us/azure/virtual-network/create-vm-accelerated-networking-cli

If availability zone is available in your region,  adding the following in your template to improve the availability of your VMSS :
```
      "zones": [
        "1",
        "2",
        "3"
      ]
}

```

Note that your Load Balancer should be STANDARD tier as well as your public IP ( if you're using it ), check here to know more about it : https://docs.microsoft.com/en-us/azure/load-balancer/load-balancer-standard-availability-zones

More information at https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-use-availability-zones

