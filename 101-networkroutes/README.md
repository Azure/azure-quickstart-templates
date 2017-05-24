# Secure public load-balanced website on Windows IIS

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-networkroutes%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to create a VNet with subnets and network routes.

PowerShell Usage: 
New-AzureResourceGroup `
    -Name '{Resource Group Name}' `
    -TemplateFile '{path to github}\azure-quickstart-templates\101-networkroutes\azuredeploy.json' `
    -Location '{Azure Region}' `
    -namePrefix '{Name Prefix}' `
    -Verbose