# VM-DSC-Extension-Azure-Automation-Pull-Server

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdsc-extension-azure-automation-pullserver%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template configures an existing Virtual Machine Local Configuration Manager (LCM) via the DSC extension, registering it to an existing Azure Automation Account DSC Pull Server.

<b>NOTE:</b> The DSC configuration module requires three specific Azure Automation DSC parameters: Registration Key, Registration URL, and Configuration Function. These prerequisites are available only after successful creation and configuration of an Azure Automation Account for Azure Automation DSC.

For more information on Azure Automation DSC, please see the following: <a href="http://aka.ms/DSCLearnMore" target="_blank">Azure Automation DSC Overview</a>

<b>DISCLAIMER:</b> This template does not create a new VM, it only includes what is necessary to create/update a DSC VM Extension for an existing VM. The contents of this template can be leveraged as part of a VM creation template, either by nesting, or copying/pasting the relevant template metadata.

Below are the parameters that the template expects:

| Name   | Description    |
|:--- |:---|
| location  | Location of the existing Virtual Machine. <br> <ul>**Allowed Values**<li>East US</li><li>West US **(default)**</li><li>West Europe</li><li>East Asia</li><li>Southeast Asia</li></ul> |
| vmName | Name of the existing VM to apply the DSC configuration to |
| modulesUrl | URL for the DSC configuration package. NOTE: Can be a Github url(raw) to the zip file <br> <ul> <li><b>Example:</b> https://xyz.blob.core.windows.net/abc/UpdateLCMforAAPull.zip</li></ul>|
| configurationFunction | DSC configuration function to call. Should contain filename and function in <br> <ul> <li><b>Format Example:</b> UpdateLCMforAAPull.ps1\\ConfigureLCMforAAPull **(default)**</li></ul> |
| registrationKey | Registration key to use to onboard to the Azure Automation DSC pull/reporting server |
| registrationUrl | Registration url of the Azure Automation DSC pull/reporting server |
| nodeConfigurationName | The name of the node configuration, on the Azure Automation DSC pull server, that this node will be configured as |
| configurationMode | DSC agent (LCM) configuration mode setting. <br> <ul>**Allowed Values**<li>ApplyOnly</li><li>ApplyAndMonitor **(default)**</li><li>ApplyAndAutoCorrect</li></ul> |
| configurationModeFrequencyMins | DSC agent (LCM) configuration mode frequency setting, in minutes <br> <ul><li>15 **(default)**</li></ul> |
| refreshFrequencyMins | DSC agent (LCM) refresh frequency setting, in minutes <br> <ul><li>30 **(default)**</li></ul> |
| rebootNodeIfNeeded | DSC agent (LCM) rebootNodeIfNeeded setting <br> <ul><li>true **(default)**</li></ul> |
| actionAfterReboot | DSC agent (LCM) actionAfterReboot setting. <br> <ul>**Allowed Values**<li>ContinueConfiguration **(default)**</li><li>StopConfiguration</li></ul> |
| allowModuleOverwrite | DSC agent (LCM) allowModuleOverwrite setting <br> <ul><li>false **(default)**</li></ul> |