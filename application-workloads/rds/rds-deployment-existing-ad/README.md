---
description: This template creates a RDS farm deployment using existing active directory in same resource group
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: rds-deployment-existing-ad
languages:
- json
---
# RDS farm deployment using existing active directory

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/rds/rds-deployment-existing-ad/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/rds/rds-deployment-existing-ad/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/rds/rds-deployment-existing-ad/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/rds/rds-deployment-existing-ad/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/rds/rds-deployment-existing-ad/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/rds/rds-deployment-existing-ad/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Frds%2Frds-deployment-existing-ad%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Frds%2Frds-deployment-existing-ad%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Frds%2Frds-deployment-existing-ad%2Fazuredeploy.json)

This template deploys the following resources:

- RD Gateway/RD Web Access vm
- RD Connection Broker/RD Licensing Server vm
- A number of RD Session hosts (number defined by 'numberOfRdshInstances' parameter)

The template will use existing DC, join all vms to the domain and configure RDS roles in the deployment.

`Tags: Microsoft.Network/publicIPAddresses, Microsoft.Compute/availabilitySets, Microsoft.Network/loadBalancers, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines, extensions, DSC, Microsoft.Compute/virtualMachines/extensions, Microsoft.Resources/deployments`
