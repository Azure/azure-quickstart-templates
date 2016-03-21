# Create 2 Windows VMs in load balancing with port 80 open and a backend VM with SQL Server 2014.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F301-2fe-lb80-rdp-1be-nsg-rdp%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F301-2fe-lb80-rdp-1be-nsg-rdp%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template creates 2 Windows VMs with in an Availability Set and a Load Balancer with port 80 open and two RDP connection for the two VMs with port 6001 and 6002 open. It also creates a SQL Server 2014 VM with a NIC that uses a NSG where is defined a Inbound rule for an RDP connection.