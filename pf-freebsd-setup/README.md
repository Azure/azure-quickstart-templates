#NAT firewall with round-robin load balancing using FreeBSD's pf

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fpf-freebsd-setup%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fpf-freebsd-setup%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template can help you deploy a NAT firewall with round-robin load balancing using FreeBSD's pf on Azure for common web server scenario where 2 FreeBSD virtual machines install the Nginix web server. 

Since the front-end VM acting as the NAT has 2 NICs, please refer [**HERE**](https://docs.microsoft.com/en-us/azure/virtual-machines/virtual-machines-windows-sizes) to choose satisfied VM size. 

After the template deploys successfully, you can access Nginx using the public IP of front-end VM from the explorer.
      
