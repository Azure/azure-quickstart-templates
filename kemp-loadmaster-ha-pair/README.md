# KEMP LoadMaster HA Pair ARM Template

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2Fkemp-loadmaster-ha-pair%2Fazuredeploy.json" target="_blank">
  <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fkemp-loadmaster-ha-pair%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/AzureGov.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2Fkemp-loadmaster-ha-pair%2Fazuredeploy.json" target="_blank">
  <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

Since 2000, KEMP has been a consistent leader in innovation with a number of industry firsts, including high performance ADC appliance virtualization, application-centric SDN and NFV integration, innovative pricing and licensing models and true platform ubiquity that can scale to support enterprises of every size and workload requirement.

This template deploys a KEMP LoadMaster high availability (HA) Pair. Once deployed an end-user can setup two KEMP Virtual LoadMasters as outlined in the [LoadMaster Documentation](https://support.kemptechnologies.com/hc/en-us/articles/203859775-HA-for-Azure-Marketplace-Classic-Interface-)

More information can be [found here](https://kemptechnologies.com/solutions/microsoft-load-balancing/loadmaster-azure/).

Specifically, the template provides:
* An Azure Internal LoadBalancer
* Azure ILB Probe
* LB Rules
* NAT Rules 


``Tags: loadbalancers, networking, lb``
