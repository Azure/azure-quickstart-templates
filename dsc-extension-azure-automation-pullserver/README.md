# VM-DSC-Extension-Azure-Automation-Pull-Server

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdsc-extension-azure-automation-pullserver%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdsc-extension-azure-automation-pullserver%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

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
