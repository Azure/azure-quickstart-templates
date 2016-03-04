# Create a 2 new Windows VMs, create a new AD Forest, Domain and 2 DCs in an availability set in an existing VNET

This template will deploy 2 new VMs (along with a new Storage Account and Load Balancer) and create a new  AD forest and domain, each VM will be created as a DC for the new domain and will be placed in an availability set. Each VM will also have an RDP endpoint added with a public load balanced IP address.

Different from [this template](https://github.com/Azure/azure-quickstart-templates/tree/master/active-directory-new-domain-ha-2-dc) it leverages your existing VNET instead of creating a new one.

At the end you have to manually set your two domain controllers as DNS servers of your existing VNET.
E.g. using the portal or Azure CLI

> azure network vnet set -n vnetname -g rg -d 10.0.0.5,10.0.0.6

For details on the template [see the parent template](https://github.com/Azure/azure-quickstart-templates/tree/master/active-directory-new-domain-ha-2-dc).

Click the button below to deploy

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Factive-directory-new-domain-ha-2-dc-existing-vnet%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Factive-directory-new-domain-ha-2-dc-existing-vnet%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

# Known Issues

+	This template is entirely serial due to some concurrency issues between the platform agent and the DSC extension which cause problems when multiple VM and\or extension resources are deployed concurrently, this will be fixed in the near future
