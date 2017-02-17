#NAT firewall with round-robin load balancing using FreeBSD's pf

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fostclilideng%2Fazure-quickstart-templates%2Fmaster%2Fpf-freebsd-setup%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fpf-freebsd-setup%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template can help you deploy NAT firewall with round-robin load balancing using FreeBSD's pf on Azure.

Since the front VM has 2 NICs, please refer [**HERE**](https://docs.microsoft.com/en-us/azure/virtual-machines/virtual-machines-windows-sizes) to choose satisfied VM size. 

After template deploys successfully, you can access nginx using public IP of frontend VM from IE.
      