# Openvpn Access Server on Ubuntu VM

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/openvpn-access-server-ubuntu/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/openvpn-access-server-ubuntu/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/openvpn-access-server-ubuntu/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/openvpn-access-server-ubuntu/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/openvpn-access-server-ubuntu/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/openvpn-access-server-ubuntu/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fopenvpn-access-server-ubuntu%2Fazuredeploy.json" target="_blank"><img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/></a>

This template uses the Azure Linux CustomScript extension to deploy an openvpn access server. It creates an Ubuntu VM, does a silent install of openvpn access server, then make the basic server network settings: define the VPN Server Hostname to be the VM's public ip's name.

The user is openvpn, password is defined by yourself during the deployment.

After deployment, you can go to https://VM's public ip or dns name:943 , then input the user and password, download the client software on your machine, connect to the VPN Server.

