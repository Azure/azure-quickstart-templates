# TFS - 3 VM domain deployment

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/tfs-dual-server/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/tfs-dual-server/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/tfs-dual-server/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/tfs-dual-server/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/tfs-dual-server/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/tfs-dual-server/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Ftfs-dual-server%2Fazuredeploy.json)  [![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Ftfs-dual-server%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Ftfs-dual-server%2Fazuredeploy.json)

This template creates a TFS deployment with three VMs. One VM serves as a domain controller for the other two. One of the domain-joined VMs will run SQL Server Standard edition. The second will run TFS, configured to use SQL on the first. All three will support RDP through NAT rules on a load balancer. This template is meant to be used to evaluate TFS in Azure, not as a production deployment.

## After Deployment

All three VMs are behind a public-facing load balancer with NAT rules enabling RDP. To access TFS you can RDP into any of the VMs using the IP address on the load balancer, and the username & password provided during the deployment. TFS will be available on port 8080 (e.g. http://vmName:8080/tfs)
