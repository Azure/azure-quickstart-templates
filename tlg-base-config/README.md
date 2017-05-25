# Create the TLG Base Config in Azure (DC1, APP1, CLIENT1)

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Ftlg-base-config%2Fazuredeploy.json" target="_blank">
  <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Ftlg-base-config%2Fazuredeploy.json" target="_blank">
  <img src="http://armviz.io/visualizebutton.png"/>
</a>

## Solution overview

This template provisions the TLG Base Config lab based on <a href="https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-windows-test-config-env/">Base Configuration test environment</a>.

`Tags: Active Directory, IIS, TLG, DSC`

This template creates the following virtual machines:

+   DC1 (Domain Controller)
+   APP1 (IIS)
+   CLIENT1 (Member Server)

This template will also create the following resources:

+	  (1) Virtual Network
+   (3) Network Interfaces
+   (3) Public IP Addresses
+	  (1) Storage Account
+	  (1) Network Security Group