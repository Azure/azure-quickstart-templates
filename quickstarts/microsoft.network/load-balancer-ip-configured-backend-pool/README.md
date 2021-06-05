# Create a Standard Load Balancer and configure the Backend Pool with two Virutal Machines via IP Address
![Azure Public Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/load-balancer-ip-configured-backend-pool/PublicLastTestDate.svg)
![Azure Public Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/load-balancer-ip-configured-backend-pool/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/load-balancer-ip-configured-backend-pool/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/load-balancer-ip-configured-backend-pool/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/load-balancer-ip-configured-backend-pool/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/load-balancer-ip-configured-backend-pool/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fload-balancer-ip-configured-backend-pool%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fload-balancer-ip-configured-backend-pool%2Fazuredeploy.json)


## Oerview and deployed resources
This template is used to demonstrate how ARM Templates can be used to configure the Backend Pool of a Load Balancer by IP Address as outlined in the [Backend Pool management](https://docs.microsoft.com/azure/load-balancer/backend-pool-management) document.

The following resources are deployed in this template:
  * One Standard Public Load Balancer
  * Two Standard Public IP Addresses
  * 3 Virtual Machines
  * 1 Virtual Network
  * 2 Sub-networks
  * 1 Bastion Host
 
The Load Balancer will be deployed and it's Backend Pool configured by IP Addresses. From here Virtual Machines will be added to the created Backend Pool by setting the IP Address in the IP Configuration of their attached NIC to the Backend Addresses that have been added to the Backend Pool. Each Virtual Machine will be configured to run Windows and host an IIS web server. 

The Load Balancer will have two seperate frontend IP addresses. One IP address will be used for a load balancing rule on port 80 and the other for an outbound rule for outbound connections. There will also be a Bastion host which can be used to RDP into the backend VMs.

The resulting deployment can be tested by visiting the Public IP address of the Load Balancer on port 80.


For an example template which configures the Backend Pool by Network Interface please refer to the [Create an Internet-facing Standard Load Balancer with three VMs](.../101-load-balancer-standard-create) template. 
