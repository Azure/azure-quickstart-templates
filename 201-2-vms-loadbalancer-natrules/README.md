# Create 2 Virtual Machines in an Availability Set and Configure NAT Rules through the Load balancer

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/201-2-vms-loadbalancer-natrules/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/201-2-vms-loadbalancer-natrules/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/201-2-vms-loadbalancer-natrules/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/201-2-vms-loadbalancer-natrules/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/201-2-vms-loadbalancer-natrules/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/201-2-vms-loadbalancer-natrules/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-2-vms-loadbalancer-natrules%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-2-vms-loadbalancer-natrules%2Fazuredeploy.json)

This template allows you to create 2 Virtual Machines in an Availability Set and configure NAT rules through the load balancer. This template also deploys a Storage Account, Virtual Network, Public IP address and Network Interfaces.

In this template, we use the resource loops capability to create the network interfaces and virtual machines


