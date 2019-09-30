# Create a Role Definition

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/create-role-def/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/create-role-def/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/create-role-def/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/create-role-def/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/create-role-def/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/create-role-def/CredScanResult.svg" />&nbsp;

This template is a subscription level template that will create a new a role definition.  The actions include reading resource groups and will be assignable at the subscription scope.  You can add/modify/delete as needed.  You can read more about role definitions [here](https://docs.microsoft.com/en-us/azure/role-based-access-control/role-definitions).

Currently the only supported methods for deploying subscription level templates are the REST apis, some SDKS and the Azure CLI.  For the latest check [here](https://docs.microsoft.com/en-us/azure/azure-resource-manager/create-resource-group-in-template#create-empty-resource-group).

For deploying this template from the CLI you can run the following command from the folder where the sample is located.

<i>NOTE: Role Definitions use a GUID for the name, this must be unique for every role assignment on the group.  The roleDefName parameter is used to seed the guid() function with this value, change it for each deployment.  You can supply a guid or any string, as long as it has not been used before when assigning the role to the resourceGroup.
</i>

```bash
az deployment create -l southcentralus --template-file ./azuredeploy.json --parameters roleDef={random seed}
```

