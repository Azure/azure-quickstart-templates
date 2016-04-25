
# DevTest environment with P2S VPN and Win-IIS

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdevtest-p2s-iis%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdevtest-p2s-iis%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template creates a simple DevTest environment with a Point-to-Site VPN and a VM with Windows Server 2012 R2 Datacenter and IIS installed. There are no public IP addresses except for the VPN Gateway. DSC is used to install IIS. The VM is a Standard_D1. 

In order to use the template you will need to have a CA certificate. This is used by the Point-to-Site VPN Gateway. 

For more information about VPN Gateway's in Azure and how to create your own CA and client certificates, goto 
[Configure a Point-to-Site connection to a virtual network using PowerShell](https://azure.microsoft.com/en-us/documentation/articles/vpn-gateway-howto-point-to-site-rm-ps/)

After your template is deployed, you will need to get the client package for the VPN. 

You can request the creation of this package using the Azure PowerShell module. After you Login, make sure you select the right Subscription, and then run the following command:

	Get-AzureRmVpnClientPackage -ResourceGroupName "resource_group_name" -VirtualNetworkGatewayName "gateway_name" -ProcessorArchitecture Amd64

This command will return a URL for the client executable that will install the VPN client for this Gateway on a Windows machine.  
If you have the client certificate installed, then all you have to do is Connect to the VPN. 



