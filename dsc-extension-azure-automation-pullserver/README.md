# VM-DSC-Extension-Azure-Automation-Pull-Server

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdsc-extension-azure-automation-pullserver%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template configures an existing Virtual Machine Local Configuration Manager (LCM) via the DSC extension, registering it to an existing Azure Automation Account DSC Pull Server.

<b>NOTE:</b> The DSC configuration module requires three specific Azure Automation DSC parameters: Registration Key, Registration URL, and Node Configuration Name. These prerequisites are available only after successful creation and configuration of an Azure Automation Account for Azure Automation DSC.

For more information on Azure Automation DSC, please see the following: <a href="http://aka.ms/DSCLearnMore" target="_blank">Azure Automation DSC Overview</a>

<b>DISCLAIMER:</b> This template does not create a new VM, it only includes what is necessary to create/update a DSC VM Extension for an existing VM. The contents of this template can be leveraged as part of a VM creation template, either by nesting, or copying/pasting the relevant template metadata.
