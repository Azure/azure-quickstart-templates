# VM-DSC-Extension-Azure-Automation-Pull-Server

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/dsc-extension-azure-automation-pullserver/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/dsc-extension-azure-automation-pullserver/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/dsc-extension-azure-automation-pullserver/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/dsc-extension-azure-automation-pullserver/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/dsc-extension-azure-automation-pullserver/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/dsc-extension-azure-automation-pullserver/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdsc-extension-azure-automation-pullserver%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdsc-extension-azure-automation-pullserver%2Fazuredeploy.json)

## UPDATE: THIS IS NO LONGER REQUIRED

This example was originally published
to assist with onboarding new virtual machines in Azure
to the Azure Automation DSC service.
Based on customer feedback,
as of
[DSC Extension version 2.72](https://blogs.msdn.microsoft.com/powershell/2014/11/20/release-history-for-the-azure-dsc-extension/),
a script to onboard machines is included in DSC Extension.

To leverage the
[Default Configuration Script](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/extensions-dsc-overview),
you only need to
[leave the Settings.Configuration values null](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/extensions-dsc-template#details)
and provide values for
[RegistrationKey, RegistrationID, and NodeConfigurationName](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/extensions-dsc-template#default-configuration-script).

## More Information

For more information on Azure Automation DSC (including more examples and usage), please see the
[Azure Automation DSC Overview](http://aka.ms/DSCLearnMore).


