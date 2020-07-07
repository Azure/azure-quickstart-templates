# Create a Standard Load Balancer and configure the Backend Pool with two Virutal Machines via IP Address
![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/path-to-sample/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/path-to-sample/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/path-to-sample/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/path-to-sample/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/path-to-sample/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/path-to-sample/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fpath-to-sample%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fpath-to-sample%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fpath-to-sample%2Fazuredeploy.json)


## Oerview and deployed resources
This template is used to demonstrate how ARM Templates can be used to configure the Backend Pool of a Load Balancer by IP Address as outlined in the [Backend Pool management](https://docs.microsoft.com/azure/load-balancer/backend-pool-management) document.

The following resources are deployed in this template:
  * One Standard Public Load Balancer
  * One Standard Public IP Address
  * 2 Virtual Machines
  * 1 Virtual Network
 
The Load Balancer will be deployed and it's Backend Pool configured by IP Addresses. From here Virtual Machines will be added to the created Backend Pool by setting the IP Address in the IP Configuration of their attached NIC to the Backend Addresses that have been added to the Backend Pool. 

For an example template which configures the Backend Pool by Network Interface please refer to the [Create an Internet-facing Standard Load Balancer with three VMs](.../101-load-balancer-standard-create) template. 
