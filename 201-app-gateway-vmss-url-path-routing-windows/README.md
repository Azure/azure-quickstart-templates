### Application Gateway Integration fronting 3 VM Scale Sets and using URL Path based routing ###


This template deploys an Azure Application Gateway fronting 3 Windows VM Scale Sets.  It uses URL path routing to route to the different scale set.  Optionnally it can use cookie based affinity to route to the same VM of each scale set for the same user (cookie).

The Application Gateway is configured to listen to port 80 and route requests to VMs in the scale set. 
 
Note that this template does not install an application on the VM Scale Set VMs, so if you want to demonstrate the round robin load balancing, the template will need to be updated (for example by adding an extension to install a web server). 

This template supports VM scale sets of up to 1,000 VMs, and uses Azure Managed Disks.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fvplauzon%2Fazure-quickstart-templates%2Fmaster%2F201-app-gateway-vmss-url-path-routing-windows%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fvplauzon%2Fazure-quickstart-templates%2Fmaster%2F201-app-gateway-vmss-url-path-routing-windows%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>
