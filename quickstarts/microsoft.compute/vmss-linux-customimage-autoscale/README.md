# Deploy a VM Scale Set based on a Linux Custom Image and a script to deploy updates

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-linux-customimage-autoscale/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-linux-customimage-autoscale/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-linux-customimage-autoscale/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-linux-customimage-autoscale/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-linux-customimage-autoscale/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-linux-customimage-autoscale/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvmss-linux-customimage-autoscale%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvmss-linux-customimage-autoscale%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvmss-linux-customimage-autoscale%2Fazuredeploy.json)

This template deploys a VM Scale Set from a user provided Linux Custom Image.

The template allows a URL to a custom image to be provided as a parameter at run time. The custom image should be contained in a storage account which is in the same location as the VM Scale Set is created in, in addition the storage account which contains the image should also be under the same subscription that the scale set is being created in. If it's not, you should copy it to your location.

To create a custom Linux image you should first create a Linux VM in Azure, install everything you need and then generalize the image running the command

```bash
sudo waagent -deprovision+user
```

inside your Linux machine.

Once it is generalized, you must run this commands at client side from a [CLI](https://docs.microsoft.com/en-us/azure/xplat-cli-install) command line:

```bash
azure login
azure config mode arm
azure vm deallocate –g [rgName] –n [vmName]
azure vm generalize –g [rgName] –n [vmName]
azure vm capture [rgName] [vmName] vhdNamePrefix –t [templateName].json
```

This commands will export your machine inside the same storage account where the VM resides with the form:

**https://[storageaccountname].blob.core.windows.net/system/Microsoft.Compute/Images/vhds/[your-image-prefix]-osDisk.[GUID].vhd**

And you will find a [templateName].json file in the same folder that will help you to create a new VM based on this VHD.

>Note: running this commands will prepare your VM to be deployed to a new machine, but your current VM will stop working. You will need to redeploy a new VM with the created image to be able to run a similar machine.

In addition to the VM Scale Set the template creates a public IP address and load balances HTTP traffic on port 80 to each VM in the scale set. It also includes a script that deploys a custom package to the image each time you call a reimage of a VM, so you will be able to script an update of your VM Scale Set without the need to create a new VM image each time.

>Note: The maximum number of VMs in a storage account is 20, unless you set the "overprovision" property to false, in which case it is 40
