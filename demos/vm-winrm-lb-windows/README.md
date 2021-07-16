# Deploys set of Windows VM instances under Load Balancer and configures WinRM Https listener on VMs using a self-signed certificate.

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vm-winrm-lb-windows/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vm-winrm-lb-windows/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vm-winrm-lb-windows/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vm-winrm-lb-windows/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vm-winrm-lb-windows/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vm-winrm-lb-windows/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fvm-winrm-lb-windows%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fvm-winrm-lb-windows%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fvm-winrm-lb-windows%2Fazuredeploy.json)

Description of Template
=======================
This template allows you to create a set of Virtual Machines under a Load Balancer. It also configures a WinRM https listener by creating a new test certificate.

The template uses a custom script extension which executes the script 'ConfigureWinRM.ps1' on the target VMs.
This script creates a self signed certificate and configures the WinRM Https listener using the certificate's thumbprint.

How to connect to a Target Azure VM post WinRM configuration
============================================================
Use the below script to connect to an azure vm post winrm configuration. Assign the exact fqdn of your azure vm to $hostname.
The script pops up a credential window, provide the credentials of azure vm.

	$hostName=<fqdn-of-vm>  #example: "myvm.westus.cloudapp.azure.com"
	$winrmPort = '40003'

	# Get the credentials of the machine
	$cred = Get-Credential

	# Connect to the machine
	$soptions = New-PSSessionOption -SkipCACheck
	Enter-PSSession -ComputerName $hostName -Port $winrmPort -Credential $cred -SessionOption $soptions -UseSSL



