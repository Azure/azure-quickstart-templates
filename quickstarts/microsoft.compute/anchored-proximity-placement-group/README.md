# Anchored Proximity Placement Groups containing Availability Sets
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
