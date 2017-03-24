### Application Gateway Integration fronting 3 VM Scale Sets and using URL Path based routing ###
2
​
3
This template deploys a Windows VM Scale Set integrated with Azure Application Gateway.
4
​
5
The Application Gateway is configured for round robin load balancing of incoming connections at port 80 (of the gateway's public IP address) to VMs in the scale set. 
6
 
7
Note that this template does not install an application on the VM Scale Set VMs, so if you want to demonstrate the round robin load balancing, the template will need to be updated (for example by adding an extension to install a web server). 
8
​
9
This template supports VM scale sets of up to 1,000 VMs, and uses Azure Managed Disks.
10
​
11
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vmss-windows-app-gateway%2Fazuredeploy.json" target="_blank">
12
    <img src="http://azuredeploy.net/deploybutton.png"/>
13
</a>
14
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vmss-windows-app-gateway%2Fazuredeploy.json" target="_blank">
15
    <img src="http://armviz.io/visualizebutton.png"/>
16
</a>
17
​
18
