# Create 2 Linux VMs in load balancing with port 80 open and a backend VM with SQL Server 2014 with 2 data disk as Premium Storage (SSD).

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/301-2fe-linux-lb80-ssh-1be-win-nsg-rdp-datadisk-ssd/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/301-2fe-linux-lb80-ssh-1be-win-nsg-rdp-datadisk-ssd/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/301-2fe-linux-lb80-ssh-1be-win-nsg-rdp-datadisk-ssd/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/301-2fe-linux-lb80-ssh-1be-win-nsg-rdp-datadisk-ssd/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/301-2fe-linux-lb80-ssh-1be-win-nsg-rdp-datadisk-ssd/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/301-2fe-linux-lb80-ssh-1be-win-nsg-rdp-datadisk-ssd/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F301-2fe-linux-lb80-ssh-1be-win-nsg-rdp-datadisk-ssd%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F301-2fe-linux-lb80-ssh-1be-win-nsg-rdp-datadisk-ssd%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template creates 2 Linux VMs with in an Availability Set and a Load Balancer with port 80 open and two SSH connection for the two VMs with port 6001 and 6002 open. It also creates a SQL Server 2014 VM with a NIC that uses a NSG where is defined a Inbound rule for an RDP connection and also 2 data disk are mounted on the SQL Server VM with different caching levels.
All VMs storage can use Premium Storage (SSD) and you can choose to creare VMs with all DS sizes.

