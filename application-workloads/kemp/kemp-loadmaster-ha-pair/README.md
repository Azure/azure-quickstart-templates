# KEMP LoadMaster HA Pair ARM Template

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/kemp/kemp-loadmaster-ha-pair/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/kemp/kemp-loadmaster-ha-pair/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/kemp/kemp-loadmaster-ha-pair/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/kemp/kemp-loadmaster-ha-pair/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/kemp/kemp-loadmaster-ha-pair/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/kemp/kemp-loadmaster-ha-pair/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)]( https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fkemp%2Fkemp-loadmaster-ha-pair%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fkemp%2Fkemp-loadmaster-ha-pair%2Fazuredeploy.json)  
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fkemp%2Fkemp-loadmaster-ha-pair%2Fazuredeploy.json)

Since 2000, KEMP has been a consistent leader in innovation with a number of industry firsts, including high performance ADC appliance virtualization, application-centric SDN and NFV integration, innovative pricing and licensing models and true platform ubiquity that can scale to support enterprises of every size and workload requirement.

This template deploys a KEMP LoadMaster high availability (HA) Pair. Once deployed an end-user can setup two KEMP Virtual LoadMasters as outlined in the [LoadMaster Documentation](https://support.kemptechnologies.com/hc/en-us/articles/203859775-HA-for-Azure-Marketplace-Classic-Interface-)

More information can be [found here](https://kemptechnologies.com/solutions/microsoft-load-balancing/loadmaster-azure/).

Specifically, the template provides:

* An Azure Internal LoadBalancer
* Azure ILB Probe
* LB Rules
* NAT Rules

``Tags: loadbalancers, networking, lb``
