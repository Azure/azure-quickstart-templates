# Load Balancer with 2 VIPs and LB rules

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-loadbalancer-with-multivip/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-loadbalancer-with-multivip/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-loadbalancer-with-multivip/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-loadbalancer-with-multivip/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-loadbalancer-with-multivip/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-loadbalancer-with-multivip/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-loadbalancer-with-nat-rule%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-loadbalancer-with-nat-rule%2Fazuredeploy.json)

This template allows you to create a Load Balancer, 2 Public IP addresses for the Load balancer, Virtual Network, Network Interface in the Virtual Network. Each VIP is associated to a LB rule that is used by the Network Interface. See https://azure.microsoft.com/en-us/documentation/articles/load-balancer-multivip/ for documentation.


