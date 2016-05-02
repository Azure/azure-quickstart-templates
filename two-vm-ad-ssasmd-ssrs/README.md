# Create a new Microsoft BI environment with Active Directory

This template creates two new Azure VMs, each with a public IP address and load balancer and a VNet, it configures one VM to be an AD DC for a new Forest and Domain, one with SQL Server SSAS MD/SSRS domain joined, both VMs have public facing RDP

Most of the configuration for openign the SSRS Report Manager up to the internet is completed. All that remains is to open the HTTP port on the firewall of the SQL VM. However, this should NOT be done until the Security Group has been configured to limit access.

Click the button below to deploy

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Ftwo-vm-ad-ssasmd-ssrs%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Ftwo-vm-ad-ssasmd-ssrs%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

Notes: Originally based on sharepoint-three-vm template by Simon Davies. Removed SharePoint and made other updates.
