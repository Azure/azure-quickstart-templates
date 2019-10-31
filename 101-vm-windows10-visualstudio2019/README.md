# Windows 10 with Visual Studio 2019

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-vm-windows10-visualstudio2019/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-vm-windows10-visualstudio2019/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-vm-windows10-visualstudio2019/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-vm-windows10-visualstudio2019/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-vm-windows10-visualstudio2019/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-vm-windows10-visualstudio2019/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-windows10-visualstudio2019%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a><a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-windows10-visualstudio2019%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template deploys a **Windows 10 Machine with Visual Studio 2019 Community Edition**, informing only two parameters **adminUsername** and **adminPassword**. This will deploy a Standard_D2_v2 size VM in the resource group location and return the fully qualified domain name of the VM.


## Parameters
- **adminUsername:** Usernames can be a maximum of 20 characters in length and cannot end in a period (".").
- **adminPassword:** Complex password for your Virtual Machine. For more information about using this [link:](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/faq#what-are-the-password-requirements-when-creating-a-vm)
- **vmName:** The name of your Virtual Machine. Keep in mind that the Virtual Machine Name is key for you to deploy multiple resources in the same group. It will come with a default value, but you can change it when deploying your resource. Also, know that the maximum characters allowed are 15.

If you are new to Azure virtual machines, see:

- [Azure Virtual Machines](https://azure.microsoft.com/services/virtual-machines/).
- [Azure Linux Virtual Machines documentation](https://docs.microsoft.com/azure/virtual-machines/linux/)
- [Azure Windows Virtual Machines documentation](https://docs.microsoft.com/azure/virtual-machines/windows/)
- [Template reference](https://docs.microsoft.com/azure/templates/microsoft.compute/allversions)
- [Quickstart templates](https://azure.microsoft.com/resources/templates/?resourceType=Microsoft.Compute&pageNumber=1&sort=Popular)

If you are new to template deployment, see:

[Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)
