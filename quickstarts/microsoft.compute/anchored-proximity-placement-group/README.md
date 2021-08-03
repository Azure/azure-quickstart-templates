# Anchored Proximity Placement Groups containing Availability Sets

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/anchored-proximity-placement-group/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/anchored-proximity-placement-group/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/anchored-proximity-placement-group/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/anchored-proximity-placement-group/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/anchored-proximity-placement-group/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/anchored-proximity-placement-group/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/anchored-proximity-placement-group/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fanchored-proximity-placement-group%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fanchored-proximity-placement-group%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fanchored-proximity-placement-group%2Fazuredeploy.json)

Why? Well It can be a requirement in HPC and SAP to use Proximity Groups to minimise latencies while at the same time we need to ensure the highest availability of resources within the target zone. The approach is outlined [here](https://docs.microsoft.com/en-us/azure/virtual-machines/workloads/sap/sap-proximity-placement-scenarios#combine-availability-sets-and-availability-zones-with-proximity-placement-groups) 

This exemplar uses [Bicep](https://github.com/Azure/bicep) to deploy the Azure resources in a manner that meets this requirement and has been tested with v0.2.14 (alpha).

Just edit or supply parameters to override the defaults

Deployment steps
```
bicep build *.bicep
az deployment sub create --template-file sub.json --location uksouth --confirm-with-what-if
az deployment group create --resource-group rg-bicep --template-file main.json --confirm-with-what-if
```

In this example Modules have been used to seperate out the definition of the network and virtual machine resources simplifying the main Bicep template but also enabling me to explore reusing the modules in other deployments

TODO: Clean up README

