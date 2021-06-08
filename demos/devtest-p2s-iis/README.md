# DevTest environment with P2S VPN and Win-IIS

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/devtest-p2s-iis/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/devtest-p2s-iis/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/devtest-p2s-iis/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/devtest-p2s-iis/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/devtest-p2s-iis/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/devtest-p2s-iis/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fdevtest-p2s-iis%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)]( https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fdevtest-p2s-iis%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fdevtest-p2s-iis%2Fazuredeploy.json)

This template creates a simple DevTest environment with a Point-to-Site VPN and a VM with Windows Server 2012 R2 Datacenter and IIS installed. There are no public IP addresses except for the VPN Gateway. DSC is used to install IIS. The VM is a Standard_D1. 

In order to use the template you will need to have a CA certificate. This is used by the Point-to-Site VPN Gateway. 

For more information about VPN Gateway's in Azure and how to create your own CA and client certificates, goto 
[Configure a Point-to-Site connection to a virtual network using PowerShell](https://azure.microsoft.com/en-us/documentation/articles/vpn-gateway-howto-point-to-site-rm-ps/)

After your template is deployed, you will need to get the client package for the VPN. 

You can request the creation of this package using the Azure PowerShell module. After you Login, make sure you select the right Subscription, and then run the following command:

	Get-AzureRmVpnClientPackage -ResourceGroupName "resource_group_name" -VirtualNetworkGatewayName "gateway_name" -ProcessorArchitecture Amd64

This command will return a URL for the client executable that will install the VPN client for this Gateway on a Windows machine.  
If you have the client certificate installed, then all you have to do is Connect to the VPN. 




