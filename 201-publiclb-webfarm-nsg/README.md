# Secure public load-balanced website on Windows IIS

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-publiclb-webfarm-nsg%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to create a Secure public load-balanced website on Windows IIS Server using DSC extension.

PowerShell Usage: 
$password = ConvertTo-SecureString '{your password}' -AsPlainText -Force

New-AzureResourceGroup `
    -Name '{Resource Group Name}' `
    -TemplateFile '{path to github}\azure-quickstart-templates\201-publiclb-webfarm-nsg\azuredeploy.json' `
    -Location '{Azure Region}' `
    -namePrefix '{Name Prefix}' `
    -newStorageAccountName '{New Storage Account Name}' `
    -publicIpAddressDnsName '{Public Ip Address Name}' `
    -adminUserName '{Website VM Username}' `
    -adminPassword $password `
    -modulesUrl '{URL to the Powershell DSC zip file}' `
    -Verbose