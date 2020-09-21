# TFS - Single VM in existing environment

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/tfs-standard-existingsql/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/tfs-standard-existingsql/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/tfs-standard-existingsql/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/tfs-standard-existingsql/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/tfs-standard-existingsql/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/tfs-standard-existingsql/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Ftfs-standard-existingsql%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Ftfs-standard-existingsql%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Ftfs-standard-existingsql%2Fazuredeploy.json)

This template creates a new TFS deployment in an existing domain, configured against an existing SQL instance. This template can be used as the starting point for a production deployment of TFS.

## Before Deployment

This template has several pre-requisites. Before deployment, you will need:

1. An existing virtual network and subnet into which the TFS VM will be deployed.
2. An existing Domain to which the TFS VM will be joined.
3. A Domain user with permissions to join the TFS VM to the Domain.
4. An existing SQL instance against which the TFS deployment will be configured

## After Deployment

This template does not configure RDP access for the TFS VM. If you wish to access the TFS VM via RDP you will need to modify the template to allow this or access the TFS VM through a jump box. TFS will be available on port 8080 (e.g. http://vmname:8080/tfs).


