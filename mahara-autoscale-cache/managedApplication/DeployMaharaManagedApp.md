/ Deploy a Mahara Based Managed Application into a Customer's Subscription

In this tutorial we'll demonstrate how your customers will deploy an
instance of your Mahara Based Managed Application in their
subscription.

## Prerequisites

In order for the following steps to work you must first have
[published a Mahara Based Managed Application](PublishMaharaManagedApplication.md)
into your service catalog.

## Consume the Managed Application

Once the Mahara on Azure Managed Application is published to your
service catalog you can now depoloy it from within the portal or using
the CLI. In the following commands we'll see how to do this in the CLI.

### Setup a Resource Group for the Application

First we need to get the id of the application. This was returned in
the output of the command to create the service catalog entry.
However, we'll use the CLI to retrieve it and record it into a
variable:

``` bash
MAHARA_MANAGED_APP_ID=$(az managedapp definition show --name $MAHARA_MANAGED_APP_NAME --resource-group $MAHARA_SERVICE_CATALOG_RG_NAME --query id --output tsv)
```

Create the application resource group, this is the group in which the
customer will see the managed application.

``` bash
az group create --name $MAHARA_DEPLOYMENT_RG_NAME --location=$MAHARA_DEPLOYMENT_LOCATION
```

Results:

``` json
{
    "id": "/subscriptions/325e7c34-99fb-4190-aa87-1df746c67705/resourceGroups/MaharaManagedApp",
    "location": "southcentralus",
    "managedBy": null,
    "name": "MaharaManagedApp",
    "properties": {
        "provisioningState": "Succeeded"
    },
    "tags": null
}
```

### Customer Deployment

When a customer wants to deploy an application they can do so using
either the Portal or the CLI. In this section we'll look at how this
is done in the CLI.

#### Providing Parameters

If we were using the portal our `CreateUIDefinition.json` file would
be used to create a user interface to define the parameters needed in
`mainTemplate.json`. When using the CLI we need to provide parameter
values for any parameters that don't have a default. To make it easier
to manage we'll put these parameter values into environment variables.

For convenience our `mainTemplate.json` file has defaults for all
values. This means that there is no need to provide parameters in the
commandline, though you can override the defaults if you want to by
adding the `--parameters` attribute. This attribute can take either
a JSON string or a filename (preceded with an '@', e.g. '--parameters @parameters.json`) containing a JSON
definition for the paramters, e.g.

    {
        "parameterName": {
            "value": "some value"
        },
        "anotherParameterName": {
            "value": "another value"
        }
    }

The Mahara template provides sensible defaults for almost every
parameter, the one exception to this is the SSH Public Key, used to
provide secure access to the VMs. For this example we will use the
defaults for all parameters, but we still need to create a parameters
file. A template file is provided here (see
`parameters-template.json`). The following command will replace the
placeholder in the parameters template file with an SSH key used for
testing puporses (this is created as part of the envrionment setup in
the prerequisites):

``` bash
ssh_pub_key=`cat $MAHARA_SSH_KEY_FILENAME.pub`
echo $ssh_pub_key
sed "s|GEN-SSH-PUB-KEY|$ssh_pub_key|g" parameters-template.json > $MAHARA_MANAGED_APP_WORKSPACE/$MAHARA_DEPLOYMENT_NAME/parameters.json
```

If you want to have more control over the deployment configuration
simply add parameters to the template file and use that to create
parameter files for specific deployments.

### Deploying the application

Deploy the managed application and corresponding infrastructure.

``` bash
az managedapp create --name $MAHARA_DEPLOYMENT_NAME --location $MAHARA_DEPLOYMENT_LOCATION --kind ServiceCatalog --resource-group $MAHARA_DEPLOYMENT_RG_NAME --managedapp-definition-id $MAHARA_MANAGED_APP_ID --managed-rg-id $MAHARA_MANAGED_RG_ID --parameters @$MAHARA_MANAGED_APP_WORKSPACE/$MAHARA_DEPLOYMENT_NAME/parameters.json
```
