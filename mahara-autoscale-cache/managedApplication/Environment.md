# Setup Environment

For convenience most of the configuration values we need to create and
manage our Mahara Managed Application we'll create a numer of
Environment Variables. In order to store any generated files and
configurations we will also create a workspace.

NOTE: If you are running these scripts through SimDem you can
customize these values by copying and editing `env.json` into
`env.local.json`.

## Setup for Publishing the Mahara Managed Application

``` bash
MAHARA_MANAGED_APP_OWNER_GROUP_NAME=MaharaOwner
MAHARA_MANAGED_APP_OWNER_NICKNAME=MaharaOwner
MAHARA_SERVICE_CATALOG_LOCATION=southcentralus
MAHARA_SERVICE_CATALOG_RG_NAME=MaharaManagedAppServiceCatalogRG
MAHARA_MANAGED_APP_NAME=MaharaManagedApp
MAHARA_MANAGED_APP_LOCK_LEVEL=ReadOnly
MAHARA_MANAGED_APP_DISPLAY_NAME=Mahara
MAHARA_MANAGED_APP_DESCRIPTION="Mahara on Azure as a Managed Application"
```

## Setup for Consuming the Mahara Managed Application

Create an id for the resource group that will be managed by the
managed application provider. This is the resource group that
infrastructure will be deployed into. The end user does not,
generally, manage this group.

``` bash
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
MAHARA_MANAGED_RG_ID=/subscriptions/$SUBSCRIPTION_ID/resourceGroups/MaharaInfrastructure
```

We'll also need a resource group for the application deployment. This is the
resource group into which the application is deployed. This is the resource group that
the provider of the managed application will have access to.

``` bash
MAHARA_DEPLOYMENT_RG_NAME=MaharaManagedAppRG
MAHARA_DEPLOYMENT_LOCATION=southcentralus
MAHARA_DEPLOYMENT_NAME=MaharaManagedApp
```

## Workspace

We need a workspace for storing configuration files and other
per-deployment artifacts:

``` shell
MAHARA_MANAGED_APP_WORKSPACE=~/.mahara
mkdir -p $MAHARA_MANAGED_APP_WORKSPACE/$MAHARA_DEPLOYMENT_NAME
```

## SSH Key

We use SSH for secure communication with our hosts. The following line
will check there is a valid SSH key available and, if not, create one.

```
MAHARA_SSH_KEY_FILENAME=~/.ssh/mahara_managedapp_id_rsa
if [ ! -f "$MAHARA_SSH_KEY_FILENAME" ]; then ssh-keygen -t rsa -N "" -f $MAHARA_SSH_KEY_FILENAME; fi
```
