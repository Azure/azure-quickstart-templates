# KEMP LoadMaster Multinic ARM template

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/kemp/kemp-loadmaster-multinic/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/kemp/kemp-loadmaster-multinic/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/kemp/kemp-loadmaster-multinic/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/kemp/kemp-loadmaster-multinic/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/kemp/kemp-loadmaster-multinic/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/kemp/kemp-loadmaster-multinic/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fkemp%2Fkemp-loadmaster-multinic%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fkemp%2Fkemp-loadmaster-multinic%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fkemp%2Fkemp-loadmaster-multinic%2Fazuredeploy.json)

Since 2000, KEMP has been a consistent leader in innovation with a number of industry firsts, including high performance ADC appliance virtualization, application-centric SDN and NFV integration, innovative pricing and licensing models and true platform ubiquity that can scale to support enterprises of every size and workload requirement.

Note: This template requires an existing Subnet and VNET prior to deployment.

This template deploys a KEMP LoadMaster with multiple NICs. Doing so will enabled the Virtual LoadMaster to have more than one interface and expose additional fucntionality such as:

* Greater performance enhanced by additive bandwidth
* Enabling extended topologies
* Multiple networks without the need for VLAN trunking
* Management isolation to a specific NIC

More information can be [found here](https://kemptechnologies.com/solutions/microsoft-load-balancing/loadmaster-azure/).

``Tags: loadbalancers, networking, lb``
