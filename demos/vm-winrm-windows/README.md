---
description: This template allows you to deploy a simple Windows VM using a few different options for the Windows version. This will then configure a WinRM https listener. User need to provide the value of parameter 'hostNameScriptArgument' which is the fqdn of the VM. Example&#58; testvm.westus.cloupdapp.azure.com or *.westus.cloupdapp.azure.com
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: vm-winrm-windows
languages:
- json
---
# Deploy a Windows VM and configures WinRM https listener

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vm-winrm-windows/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vm-winrm-windows/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vm-winrm-windows/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vm-winrm-windows/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vm-winrm-windows/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vm-winrm-windows/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fvm-winrm-windows%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fvm-winrm-windows%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fvm-winrm-windows%2Fazuredeploy.json)

## Description of Template

This template allows you to deploy a simple Windows VM using a few different options for the Windows version.
This will then configure a WinRM https listener by creating a new test certificate.

The template uses a custom script extension which executes the script 'ConfigureWinRM.ps1' on the target machine.
This script creates a self signed certificate and configures the WinRM Https listener using the certificate's thumbprint.

This template has been tested with Windows Server 2008-R2-SP1, 2012-Datacenter, and 2012-R2-Datacenter.

## How to connect to a Target Azure VM post WinRM configuration

Use the below script to connect to an azure vm post winrm configuration. Assign the exact fqdn of your azure vm to $hostname.
The script pops up a credential window, provide the credentials of azure vm.

```powershell
$hostName=<fqdn-of-vm> # example: "myvm.westus.cloudapp.azure.com"
$winrmPort = '5986'

# Get the credentials of the machine
$cred = Get-Credential

# Connect to the machine
$soptions = New-PSSessionOption -SkipCACheck
Enter-PSSession -ComputerName $hostName -Port $winrmPort -Credential $cred -SessionOption $soptions -UseSSL

```

`Tags: Microsoft.Network/publicIPAddresses, Microsoft.Network/networkSecurityGroups, Microsoft.Network/virtualNetworks, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines, Microsoft.Compute/virtualMachines/extensions, CustomScriptExtension`
