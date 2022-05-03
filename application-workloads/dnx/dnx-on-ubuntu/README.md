# DNX on Ubuntu 14.04

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/dnx/dnx-on-ubuntu/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/dnx/dnx-on-ubuntu/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/dnx/dnx-on-ubuntu/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/dnx/dnx-on-ubuntu/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/dnx/dnx-on-ubuntu/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/dnx/dnx-on-ubuntu/CredScanResult.svg)

This template will install the cross platform .NET execution context (DNX) on an Ubuntu Server installation, which allows you to write .NET apps on Linux!

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fdnx%2Fdnx-on-ubuntu%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)]( https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fdnx%2Fdnx-on-ubuntu%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fdnx%2Fdnx-on-ubuntu%2Fazuredeploy.json)
	

<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Azure%2azure-quickstart-templates%2master%2dnx-on-ubuntu%2azuredeploy.json" target="_blank">

After deploying the VM - SSH into the machine and do the following to see the DNX app in action:

```
cd sampleConsoleApp
dnx run
```

Open up nano to edit the samplecode `nano ~/sampleConsoleApp/main.cs` code - which has syntax highlighting for C# enabled.

```
dnu build --framework dnxcore50
dnx run
```


