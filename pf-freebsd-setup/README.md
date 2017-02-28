#NAT firewall with round-robin load balancing using FreeBSD's pf

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fostclilideng%2Fazure-quickstart-templates%2Fmaster%2Fpf-freebsd-setup%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fpf-freebsd-setup%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template can help you deploy NAT firewall with round-robin load balancing using FreeBSD's pf on Azure.

Since the front VM has 2 NICs, please refer [**HERE**](https://docs.microsoft.com/en-us/azure/virtual-machines/virtual-machines-windows-sizes) to choose satisfied VM size. 

[**HERE**](https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release/blob/master/docs/get-started/create-service-principal.md) is how to create a service principal.

Note: There is an issue that install Azure CLI using CustomScript extension in FreeBSD, after template deploy successfully, there is a script (deploy.sh) running to finish deployment, if you can access nginx using public IP of frontend VM from IE, the whole deployment is finished. You can see installation log under /tmp/install.log for detail installation process.
      