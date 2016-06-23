# Important Note

For the most up to date version of this template, please do not use this repo. Instead go [here](https://github.com/DSPN/azure-resource-manager-dse).

# azure-resource-manager-dse

These are Azure Resource Manager (ARM) templates for deploying DataStax Enterprise (DSE).  The [DataStax Enterprise Deployment Guide for Azure](https://academy.datastax.com/resources/deployment-guide-azure) is a good place to start learning about these templates.

Directory | Description
--- | ---
[extensions](./extensions) | Common scripts that are used by all the templates.  In ARM terminology these are referred to as Linux extensions.
[marketplace](./marketplace) | Used by the DataStax Azure Marketplace offer.  This is not intended for deployment outside of the Azure Marketplace.
[multidc](./multidc) | Python to generate an ARM template across multiple data centers and then deploy that.
[singledc](./singledc) | Bare bones template that deploys 1-40 nodes in a single datacenter.
