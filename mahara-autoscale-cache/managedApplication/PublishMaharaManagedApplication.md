# Publish a Mahara Based Managed Appliction to Service Catalog

In this document we will look at how to publish a Mahara based Managed
Application into your Service Catalog so that you can allow your
customers to deploy the application into their subscriptions. If you
are not sure why you would do this you might want to read our [Mahara
Based Managed Application Introduction](README.md) first.

## Prerequisites

In the following sections we demonstrate how to use the Azure CLI to
work with a Mahara based Managed Application. For convenience these
commands use a variety of [environment variables](Environment.md) that
should be configured first.

## Defining the Resources (mainTemplate.json)

The `mainTemplate.json` file defines the Azure resources that are
provisioned as part of the managed application. We've already done the
majority of the work here for you (see `azuredeploy.json` in the root
of this repository). The `mainTemplate.json` file is where you
customize the configuration and, optionally, add additional resources.

For the purposes of our demo we will use the ARM template from the
root of our project as the main tamplate.

This file is a regular [Azure Resource Manager template](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-overview).

## User Interface Definition (createUIDefinition.json)

The `createUIDefinition.json` file describes the user interface needed
to configure the managed application. It defines how the user provides
input for each of the parameters (specified in `mainTemplate.json`).

An initial `createUIDefinition.json` file is provided in
`managedApplication/creatueUIDefinition.json`. This files is
sufficient to get you started building your own Mahara based Managed
Applications.

See [Create UI Definition
documentation](https://docs.microsoft.com/en-us/azure/managed-applications/create-uidefinition-overview) for more information.

## Create an Azure Active Directory User Group or Application

You will need to create one ore more user group or appliction in Azure
Active Directory to allow you to manage the applications resources on
behalf of your customer. These groups or application can be given any
built-in Role-Based Access Control (RBAC) role, such as 'Owner' or
'Contributor'. By creating more than one such group or application you
can configure access to your customers resources based on the specific
needs of each role in your organization.

Azure has full documentation on [creating a group in Azure Active
Directory](https://docs.microsoft.com/en-us/azure/active-directory/active-directory-groups-create-azure-portal). The commands below will create a single 'owner' role for
use in the examples below.

If the Group already exists we don't want to create a new one, so we
will try to get the Group ID first:

``` bash
MAHARA_MANAGED_APP_AD_ID=$(az ad group list --filter="displayName eq '$MAHARA_MANAGED_APP_OWNER_GROUP_NAME'" --query [0].objectId --output tsv)
```

At this point MAHARA_MANAGED_APP_AD_ID will either be empty or it will have the ID of an existing group. If it is empty we need to create the group and grab its ID:

``` bash
if [ -z "$MAHARA_MANAGED_APP_AD_ID" ]; then az ad group create --display-name $MAHARA_MANAGED_APP_OWNER_GROUP_NAME --mail-nickname=$MAHARA_MANAGED_APP_OWNER_NICKNAME; fi
```

Let's ensure that we have the object ID even if we created a new one.

``` bash
MAHARA_MANAGED_APP_AD_ID=$(az ad group list --filter="displayName eq '$MAHARA_MANAGED_APP_OWNER_GROUP_NAME'" --query [0].objectId --output tsv)
```

You will also need the Role ID for your chosen role, here we will use
the built-in 'Owner' role:

``` bash
MAHARA_MANAGED_APP_ROLE_ID=$(az role definition list --name Owner --query [].name --output tsv)
```

The Azure documentation has more information on how to work with [Azure Active Directory](https://docs.microsoft.com/en-us/azure/active-directory/manage-access-to-azure-resources).

## Create a Resource Group for the Managed Application Service Catalog Entry

``` bash
az group create --name $MAHARA_SERVICE_CATALOG_RG_NAME --location $MAHARA_SERVICE_CATALOG_LOCATION
```

## Publish to your Service Catalog using Azure CLI

You can publish a Managed Application definition into your Service Catalog using
the Azure CLI. For convenience we'll set a few environment variables
to make it easier to work with the application. We'll need to construct
the authorization configuration from the app and role IDs retrieved
earlier.

``` bash
MAHARA_MANAGED_APP_AUTHORIZATIONS=$MAHARA_MANAGED_APP_AD_ID:$MAHARA_MANAGED_APP_ROLE_ID
```

The following command will add your managed application definition to the Service Catalog.

``` bash
az managedapp definition create --name $MAHARA_MANAGED_APP_NAME --location $MAHARA_SERVICE_CATALOG_LOCATION --resource-group $MAHARA_SERVICE_CATALOG_RG_NAME --lock-level $MAHARA_MANAGED_APP_LOCK_LEVEL --display-name $MAHARA_MANAGED_APP_DISPLAY_NAME --description "$MAHARA_MANAGED_APP_DESCRIPTION" --authorizations="$MAHARA_MANAGED_APP_AUTHORIZATIONS" --main-template=@../azuredeploy.json --create-ui-definition=@createUIDefinition.json
```

Results:

``` json
{
  "artifacts": [
    {
        "name": "ApplicationResourceTemplate",
        "type": "Template",
        "uri": "https://prdsapplianceprodsn01.blob.core.windows.net/applicationdefinitions/84205_325E7C3499FB4190AA871DF746C67705_8D748DA35A5166F6BF319C41398E89D9953014D8/applicationResourceTemplate.json?sv=2014-02-14&sr=b&sig=PyYyl6dzf0vVyrde2yJZ73h6h9fqbXHwMJuXf0lGFr8%3D&se=2118-03-15T21:33:33Z&sp=r"
    },
    {
        "name": "CreateUiDefinition",
        "type": "Custom",
        "uri": "https://management.azure.com/subscriptions/325e7c34-99fb-4190-aa87-1df746c67705/resourceGroups/MaharaManagedAppServiceCatalogRG/providers/Microsoft.Solutions/applicationDefinitions/MaharaManagedApp/applicationArtifacts/CreateUiDefinition?api-version=2017-09-01"
    }
  ],
  "authorizations": [
    {
      "principalId": "fdc3f6fb-cc24-4182-9943-b63e0ed67285",
      "roleDefinitionId": "8e3af657-a8ff-443c-a75c-2fe8c4bcb635"
    }
  ],
  "createUiDefinition": null,
  "description": "Mahara on Azure as a Managed Application",
  "displayName": "Mahara",
  "id": "/subscriptions/325e7c34-99fb-4190-aa87-1df746c67705/resourceGroups/MaharaManagedAppServiceCatalogRG/providers/Microsoft.Solutions/applicationDefinitions/MaharaManagedApp",
  "identity": null,
  "isEnabled": "True",
  "location": "southcentralus",
  "lockLevel": "ReadOnly",
  "mainTemplate": null,
  "managedBy": null,
  "name": "MaharaManagedApp",
  "packageFileUri": null,
  "resourceGroup": "MaharaManagedAppServiceCatalogRG",
  "sku": null,
  "tags": null,
  "type": "Microsoft.Solutions/applicationDefinitions"
}
```

### [OPTIONAL] Package the files

The `mainTemplate.json` and `createUIDefinition.json` files can be
packaged together in a zip file. Both files should be at the root level
of the zip. Once created the package needs to be uploaded to a location accessible
to Azure. We've published the samples to GitHub so you can experiment
with minimal effort.

To use a package file remove the `--create-ui-definition` and
`--main-tamplate` arguments from the above CLI command instead provide
a URI for the package using `--package-file-uri` argument.

## Next Steps

Now that you have published a Mahara based Managed Application on Azure you can:

  1. [Deploy Mahara into Customer Subscription](DeployMaharaManagedApp.md)
