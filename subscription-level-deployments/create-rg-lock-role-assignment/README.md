# Create a Resource Group, Lock it and give permissions to it

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/subscription-level-deployments/create-rg-lock-role-assignment/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/subscription-level-deployments/create-rg-lock-role-assignment/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/subscription-level-deployments/create-rg-lock-role-assignment/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/subscription-level-deployments/create-rg-lock-role-assignment/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/subscription-level-deployments/create-rg-lock-role-assignment/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/subscription-level-deployments/create-rg-lock-role-assignment/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsubscription-level-deployments%2Fcreate-rg-lock-role-assignment%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsubscription-level-deployments%2Fcreate-rg-lock-role-assignment%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsubscription-level-deployments%2Fcreate-rg-lock-role-assignment%2Fazuredeploy.json)

This template is a subscription level template that creates a resource group, applies a DoNotDelete lock to that group, and assigns the contributor role to a principal specified in a template parameters.

Currently the only supported methods for deploying subscription level templates are the REST APIs, some SDKs, Azure PowerShell, and Azure CLI.  For the latest check [here](https://docs.microsoft.com/azure/azure-resource-manager/templates/deploy-to-subscription).

For deploying this template from the CLI you can run the following command from the folder where the sample is located.

<i>NOTE: Role Assigments use a GUID for the name, this must be unique for every role assignment on the group.  The roleAssignmentName parameter is used to seed the guid() function with this value, change it for each deployment.  You can supply a guid or any string, as long as it has not been used before when assigning the role to the resourceGroup.
</i>

```bash
az deployment create -l southcentralus --template-file ./azuredeploy.json --parameters roleAssignmentName={random seed}
```

