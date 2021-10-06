# Subscription Setup

Use these steps to configure a subscription to run the Azure DevOps pipelines supplied in the repo.

## Service Principals

You will need 2 service principals for the pipelines one each with the following permissions:

- Owner for the subscriptions, this principal will create resource groups and assign permissions to those resource groups to the other service principal
  - Additionally, this service principal will need to be assigned the "Directory Readers" role for the AD tenant.  In the Azure Portal you can find this under "Active Directory > Roles and Administrators"
- Reader for the subscription, this principal will be used to deploy templates to the assigned resource group but also access "existing" resources in other resource groups.  If you don't use that scenario this permission can be remove and the pipeline will assign permissions as needed.

## KeyVault Scenarios for the Service Principal

If using KeyVault scenarios in deployment the principal used for deploying must have the following roles assigned - these will be assigned by the Create-GEN-Artifacts.ps1 script if the objectId is passed to the script

- Microsoft.KeyVault/vaults/deploy/action for deploying secrets from the vault
- Contributor Role in order to be able to add secrets during deployment

**NOTE: If you allow PRs to automatically trigger on a PR, then any one who can submit a PR can retrieve secrets from this vault.  This process gives users who can create PRs access to a service principal that can retrieve secrets during deployment.**

## Running Create-GEN-Artifacts.ps1

This script will create the resources required for a subscription - there are default values for the parameters, but check each param to make sure the value is correct for your subscription.  The KeyVault name and StorageAccount name must be globally unique.

The output of the script will be a JSON blob on the console, you can take that output and copy pasted in into your copy of the .config.json file - these values will go into and replace **Section 2** of the file.  The other properties must be updated manually as you set the values for your scenario.

### Manually Creating the Remaining Artifacts

For everything not in **Section 2** of the .config.json, you have two options:

1. Leave all of these urls "as is" - the artifacts from the public QuickStart repo are generic and you should be able to use them in any generic test
1. Create your own set of artifacts - you can to this by copying the public ones or simply creating your own as appropriate.

### Creating a Service Principal for AKS

If you need to test AKS a service principal needs to be created - until AKS supports Managed Identity.  For most tests, this Service Principal needs no permission but the secret needs to be passed to the deployment from the config.  See the [docs](https://docs.microsoft.com/en-us/azure/aks/kubernetes-service-principal) for details on how to create the principal and then add the tokens of your choosing to the .config.json

## Using Your Configuration

Make sure your pipeline variable for the .config.json file, is updated to reference your config.  The file must be publicly accessible or you need to update the task the downloads it.

## Front Door CNAME Protection

Azure Front Door quickstarts deploy a temporary Front Door instance for validation. Front Door's dangling CNAME prevention policy prevents the deletion of the Front Door instance after it's created.

To work around this, contact the Front Door team and ask them to enable the "bypass dangling CNAME protection" feature flag for your Azure subscription's ID.
