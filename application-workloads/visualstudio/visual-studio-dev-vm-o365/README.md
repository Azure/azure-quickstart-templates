# A Visual Studio Development VM for O365 Developers

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/visualstudio/visual-studio-dev-vm-o365/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/visualstudio/visual-studio-dev-vm-o365/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/visualstudio/visual-studio-dev-vm-o365/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/visualstudio/visual-studio-dev-vm-o365/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/visualstudio/visual-studio-dev-vm-o365/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/visualstudio/visual-studio-dev-vm-o365/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fvisualstudio%2Fvisual-studio-dev-vm-o365%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fvisualstudio%2Fvisual-studio-dev-vm-o365%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fvisualstudio%2Fvisual-studio-dev-vm-o365%2Fazuredeploy.json)

This template creates a Visual Studio 2015 VM from the base gallery VM images available complete with Office 2013 or Office 2016 Desktop installed.  It creates the VM in a new vnet, storage account, nic, and public ip with the new compute stack. There are various combinations of Visual Studio skus and underlying operating system available to deploy with this template.  Selecting a VM image other than the Visual Studio Community Edition will require appropriate licenses to work properly after you login to the VM and start Visual Studio. Also a valid MSDN subscription user must be authenticated to be able to create the VM images which are not Visual Studio Community Edition on top of Windows Server.

By default, it will deploy Visual Studio 2015 Update 3 Community Edition with Azure SDK 2.91 on Windows Server 2012R2 with Office 2016 Desktop on top of a new premium storage account.



