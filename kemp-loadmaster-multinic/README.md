# KEMP LoadMaster Multinic ARM template

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2Fkemp-loadmaster-multi-nic%2Fazuredeploy.json" target="_blank">
  <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2Fkemp-loadmaster-multi-nic%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/AzureGov.png"/>
</a>

<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2Fkemp-loadmaster-multi-nic%2Fazuredeploy.json" target="_blank">
  <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

Since 2000, KEMP has been a consistent leader in innovation with a number of industry firsts, including high performance ADC appliance virtualization, application-centric SDN and NFV integration, innovative pricing and licensing models and true platform ubiquity that can scale to support enterprises of every size and workload requirement.

Note: This template requires an existing Subnet and VNET prior to deployment.

This template deploys a KEMP LoadMaster with multiple NICs. Doing so will enabled the Virtual LoadMaster to have more than one interface and expose additional fucntionality such as:

* Greater performance enhanced by additive bandwith 
* Enabling extended topologies 
* Multiple networks without the need for VLAN trunking
* Management isolation to a specific NIC

More information can be [found here](https://kemptechnologies.com/solutions/microsoft-load-balancing/loadmaster-azure/).

``Tags: loadbalancers, networking, lb``
