# Load Balancer with 2 VIPs and LB rules

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-loadbalancer-with-nat-rule%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-loadbalancer-with-nat-rule%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to create a Load Balancer, 2 Public IP addresses for the Load balancer, Virtual Network, Network Interface in the Virtual Network. Each VIP is associated to a LB rule that is used by the Network Interface. See https://azure.microsoft.com/en-us/documentation/articles/load-balancer-multivip/ for documentation.
