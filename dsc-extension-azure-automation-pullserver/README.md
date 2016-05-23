# VM-DSC-Extension-Azure-Automation-Pull-Server

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdsc-extension-azure-automation-pullserver%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdsc-extension-azure-automation-pullserver%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template configures an existing Virtual Machine Local Configuration Manager (LCM) via the DSC extension, registering it to an existing Azure Automation Account DSC Pull Server.

<b>NOTE:</b> The DSC configuration module requires four specific settings:

1. modulesUrl: This parameter sets the URL for the zipped PS1 file responsible for passing the ARM Template values through the DSC VM Extension to configure the LCM, onboarding the VM to Azure Automation DSC. Both the Default value for this parameter and the azuredeploy.parameters.json for this template has the appropriate value for this parameter, as it references the RAW content URL for the provided module here in GitHub.

2. registrationKey: This parameter, combined with registrationUrl, enables the onboarding of the VM to Azure Automation DSC. This account specific Key can be found within the Azure Portal - Automation Account - All settings - Keys.

3. registrationUrl: This parameter, combined with registrationKey, enables the onboarding of the VM to Azure Automation DSC. This account specific URL can be found within the Azure Portal - Automation Account - All settings - Keys.

4. nodeConfigurationName: This parameter, identifies the name of the Azure Automation DSC Configuration to be applied to the VM, once it is onboarded. These Azure Automation DSC Configurations can be created and referenced within the Azure Portal - Automation Account - DSC Configurations.

   i. As an example, nodeConfigurationName would be set to MyWebConfig.WebServer in the following PowerShell DSC Module snippet:

      Configuration MyWebConfig {
           Node "WebServer" {
		   ...
           }

These prerequisites are available only after successful creation and configuration of an Azure Automation Account for Azure Automation DSC.

For more information on Azure Automation DSC (including more examples and usage), please see the following: <a href="http://aka.ms/DSCLearnMore" target="_blank">Azure Automation DSC Overview</a>

<b>DISCLAIMER:</b> This template does not create a new VM, it only includes what is necessary to create/update a DSC VM Extension for an existing VM. The contents of this template can be leveraged as part of a VM creation template, either by nesting, or copying/pasting the relevant template metadata.

<b>Final Note:</b> A timestamp parameter is included in this template. It can be any unique string, but the current datetime, as a string, was chosen as an example. This is used to force the request to go through ARM even if all fields are the same as last ARM deployment of this template; example in parameters file is in MM/dd/yyyy H:mm:ss tt format.