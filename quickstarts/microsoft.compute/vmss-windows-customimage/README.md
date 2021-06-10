# Deploy a VM Scale Set based on a Windows Custom Image

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-windows-customimage/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-windows-customimage/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-windows-customimage/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-windows-customimage/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-windows-customimage/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-windows-customimage/CredScanResult.svg)

This template deploys a VM Scale Set from a user provided Windows Custom Image

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvmss-windows-customimage%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvmss-windows-customimage%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvmss-windows-customimage%2Fazuredeploy.json)

The template allows a URL to a custom image to be provided as a parameter at run time. The custom image should be contained in a storage account which is in the same location as the VM Scale Set is created in, in addition the storage account which contains the image should also be under the same subscription that the scale set is being created in.

In addition to the VM Scale Set the template creates a public IP address and load balances HTTP traffic on port 80 to each VM in the scale set. The load balancer can be customised by parameters passed to the template.

To make it easier to see this template in action there is a PowerShell script located in the scripts folder which will use a demo custom image, this script will create a new resource group and storage account, copy a demo custom image from a publicly accessible URL and then deploy the template using the newly created demo instance. Use this script as follows:

```
.\deployscaleset.ps1 -location <location> -resourceGroupName <resourcegroupname> -scaleSetName <scalsetname> -newStorageAccountName <newstorageaccountname> -scaleSetVMSize <scalesetvmsize> -scaleSetDNSPrefix <scalesetdnsprefix> -newStorageAccountType <newstorageaccounttype>

```

A sample script with this command can be found at scripts/rundeployscaleset.ps1

The sample Windows Custom Image is based on Windows Server 2012 R2 and has a simple MVC application installed that will render the name of the server that processed a request, by default this application is exposed on port 80

**Note: This image may not have all the latest windows updates applied to it**

**Note: The maximum number of VMs in a storage account is 20, unless you set the "overprovision" property to false, in which case it is 40**


