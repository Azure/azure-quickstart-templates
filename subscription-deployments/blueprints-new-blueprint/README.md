# Azure Blueprints - Create a new blueprint definition

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/subscription-deployments/blueprints-new-blueprint/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/subscription-deployments/blueprints-new-blueprint/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/subscription-deployments/blueprints-new-blueprint/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/subscription-deployments/blueprints-new-blueprint/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/subscription-deployments/blueprints-new-blueprint/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/subscription-deployments/blueprints-new-blueprint/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsubscription-deployments%2Fblueprints-new-blueprint%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsubscription-deployments%2Fblueprints-new-blueprint%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsubscription-deployments%2Fblueprints-new-blueprint%2Fazuredeploy.json)

This template is a subscription level template that creates a blueprint definition.

This template deploys a **blueprint definition**.

## Overview

This template deploys an Azure Blueprints blueprint definition. The blueprint definition includes a
single artifact, a policy assignment. The
[Azure Policy](https://docs.microsoft.com/azure/governance/policy) built-in policy definition **Not
allowed resource types**. View the policy definition in
[Azure portal](https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyDetailBlade/definitionId/%2Fproviders%2FMicrosoft.Authorization%2FpolicyDefinitions%2F6c112d4e-5bc7-47ae-a041-ea2d9dccd749)
or the source in
[GitHub](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/General/InvalidResourceTypes_Deny.json).

### Microsoft.Blueprint

The _Microsoft.Blueprint_ resource provider is used by Azure Blueprints for blueprint definitions,
artifacts, versions, and assignments.

- **blueprints**: This is the core resource and defines the blueprint definition itself.
- **artifacts**: These are child types of a blueprint definition. These can be role assignments,
  policy assignments, resource groups, and Azure Resource Manager templates.
- **versions**: The version object reflects a blueprint definition moving from _draft_ to
  _published_. For more information, see
  [Azure Blueprint lifecycle](https://docs.microsoft.com/azure/governance/blueprints/concepts/lifecycle).
- **blueprintAssignments**: This is the resource object that assigns a blueprint definition and
  deploys it to a target scope.

### A note about blueprint-level parameters

This example sets the parameters on the blueprint definition itself. These are blueprint-level
parameters and can then be used on any included artifact. The alternative would be to set the
parameters on each artifact.

The **artifact** definition makes use of one of these blueprint-level parameters, specifically
**listOfResourceTypesNotAllowed**. Azure Blueprints uses the same Azure Resource Manager function,
`parameters()`, to fetch and re-use a parameter value in the object. The ARM template would normally
process the block `[parameters('listOfResourceTypesNotAllowed')]` as an ARM function, but since this
is inteded to be handed by Azure Blueprints instead, an extra `[` is placed in front the function.
This bypasses the function being executed in ARM during template deployment, but still enabled Azure
Blueprints to use the function as part of its **artifact** object.

## Deployment steps

You can click the "Deploy to Azure" button at the beginning of this document or follow the
instructions for command line deployment using the scripts in the root of this repo.

Once the blueprint definition has been deployed, it must be _Published_ to deploy to a management
group or subscription. With the definitions from this template, the assignment would specify the
following:

- sampleRG Resource Group: Name and Location
- Blocked Resource Types policy definition: Resource types to pass to the policy assignment artifact.

## Notes

If you are new to Azure Blueprints, see:

- [Azure Blueprints documentation](https://docs.microsoft.com/azure/governance/blueprints)
- [Azure Blueprints - Lifecycle](https://docs.microsoft.com/azure/governance/blueprints/concepts/lifecycle)
- [Azure Blueprints - Stages of deployment](https://docs.microsoft.com/azure/governance/blueprints/concepts/deployment-stages)
- [Azure Blueprints - Resource locking](https://docs.microsoft.com/azure/governance/blueprints/concepts/resource-locking)
- [Azure Blueprints - Dynamic parameters](https://docs.microsoft.com/azure/governance/blueprints/concepts/parameters)

If you are new to template deployment, see:

- [Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)

`Tags: Blueprints, blueprint definition, artifacts, policy assignment, blueprint-level parameters`
