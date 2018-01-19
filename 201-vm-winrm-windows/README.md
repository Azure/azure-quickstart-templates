# Deploys a Windows VM and Configures a WinRM Https listener. It creates a self signed certificate, so no extra certificate is required.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-winrm-windows%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-winrm-windows%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

Description of Template
=======================
This template allows you to deploy a simple Windows VM using a few different options for the Windows version. 
This will then configure a WinRM https listener by creating a new test certificate.

The template uses a custom script extension which executes the script 'https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/201-vm-winrm-windows/ConfigureWinRM.ps1' on the target machine.
This script creates a self signed certificate and configures the WinRM Https listener using the certificate's thumbprint.

This template has been tested with Windows Server 2008-R2-SP1, 2012-Datacenter, and 2012-R2-Datacenter.



How to connect to a Target Azure VM post WinRM configuration
============================================================
Use the below script to connect to an azure vm post winrm configuration. Assign the exact fqdn of your azure vm to $hostname.
The script pops up a credential window, provide the credentials of azure vm.

	$hostName=<fqdn-of-vm> # example: "myvm.westus.cloudapp.azure.com"
	$winrmPort = '5986'

	# Get the credentials of the machine
	$cred = Get-Credential

	# Connect to the machine
	$soptions = New-PSSessionOption -SkipCACheck
	Enter-PSSession -ComputerName $hostName -Port $winrmPort -Credential $cred -SessionOption $soptions -UseSSL
