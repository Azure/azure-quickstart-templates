# CoScale Single VM Template : Setup the CoScale platform on a single VM.

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/coscale/coscale-dev-env/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/coscale/coscale-dev-env/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/coscale/coscale-dev-env/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/coscale/coscale-dev-env/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/coscale/coscale-dev-env/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/coscale/coscale-dev-env/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fcoscale%2Fcoscale-dev-env%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fcoscale%2Fcoscale-dev-env%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fcoscale%2Fcoscale-dev-env%2Fazuredeploy.json)

CoScale is a full-stack monitoring solution tailored towards production environments running microservices, see https://www.coscale.com/ for more information.
This template installs the CoScale platform on a single VM and should only be used for Proof-Of-Concept environments.

This template automatically creates all required objects, such as a storage account, virtual network, nic, load balancer, public ip.

The following parameters should be provided by the user:
* coscaleKey: a CoScale registration key that can be retrieved at https://www.coscale.com/azure/
* coscaleEmail: email address for the super user on your private CoScale instance
* coscalePassword: password for the super user on your private CoScale instance

Once the template finishes it will output the URL of your private CoScale instance.

##Install agent
This directory also contains a deploy-agent.sh script to deploy the CoScale agent on all VMs in a resource group.

##Limitations
- This single VM deployment should only be used for Proof-Of-Concept environments.
- There is no backup of the data that is collected using this setup.
- Since the created objects have fixed names they can be deployed only once per resource group.


