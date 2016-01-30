# Deploys set of Windows VM instances under Load Balancer and configures WinRM Https listener on VMs using a self-signed certificate.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-winrm-lb-windows%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-winrm-lb-windows%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

Description of Template
=======================
This template allows you to create a set of Virtual Machines under a Load Balancer. It also configures a WinRM https listener by creating a new test certificate.

The template uses a custom script extension which executes the script 'https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/201-vm-winrm-lb-windows/ConfigureWinRM.ps1' on the target VMs.
This script creates a self signed certificate and configures the WinRM Https listener using the certificate's thumbprint.



How to connect to a Target Azure VM post WinRM configuration
============================================================
Use the below script to connect to an azure vm post winrm configuration. Assign the exact fqdn of your azure vm to $hostname.
The script pops up a credential window, provide the credentials of azure vm.

	$hostName=<fqdn-of-vm>  #example: "mywindowsvm.westus.cloudapp.azure.com"
	$winrmPort = '40003'

	# Get the credentials of the machine
	$cred = Get-Credential

	# Connect to the machine
	$soptions = New-PSSessionOption -SkipCACheck
	Enter-PSSession -ComputerName $hostName -Port $winrmPort -Credential $cred -SessionOption $soptions -UseSSL
