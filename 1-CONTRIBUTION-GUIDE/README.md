# Azure Resource Manager QuickStart Templates

This repo contains all currently available Azure Resource Manager templates contributed by the community. A searchable template index is maintained at [Azure Resource Manager Templates](https://azure.microsoft.com/en-us/documentation/templates/).

The following information is relevant to get started with contributing to this repository.

+ [**Contribution guide**](/1-CONTRIBUTION-GUIDE/README.md#contribution-guide). Describes the minimal guidelines for contributing.
+ [**Best practices**](/1-CONTRIBUTION-GUIDE/best-practices.md#best-practices). Best practices for improving the quality of your template design.
+ [**Git tutorial**](/1-CONTRIBUTION-GUIDE/git-tutorial.md#git-tutorial). Step by step to get you started with Git.
+ [**Useful Tools**](/1-CONTRIBUTION-GUIDE/useful-tools.md#useful-tools). Useful resources and tools for Azure development.

## Deploying Samples

You can deploy these samples directly through the Azure Portal or by using the scripts supplied in the root of the repo.

To deploy a sample using the Azure Portal, click the **Deploy to Azure** button found in the README.md of each sample.

To deploy the sample via the command line (using [Azure PowerShell](https://docs.microsoft.com/en-us/powershell/azure/overview) or the [Azure CLI 1.0](https://docs.microsoft.com/en-us/azure/cli-install-nodejs)) you can use the scripts below.

Simply execute the script and pass in the folder name of the sample you want to deploy.

For example:

### PowerShell

```PowerShell
.\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation 'eastus' -ArtifactStagingDirectory '[foldername]'
```

### Bash

Please ensure that you have [node and npm](https://docs.npmjs.com/getting-started/installing-node), [jq](https://stedolan.github.io/jq/download/) and [azure-cli](https://docs.microsoft.com/en-us/azure/cli-install-nodejs) installed.

```bash
./azure-group-deploy.sh -a [foldername] -l eastus
```

+ If you see the following error: "syntax error near unexpected token `$'in\r''", run this command: 'dos2unix azure-group-deploy.sh'.
+ If you see the following error: "jq: command not found", run this command: "sudo apt install jq".
+ If you see the following error: "node: not found", install node and npm.
+ If you see the following error: "azure-group-deploy.sh is not a command", make sure you run "chmod +x azure-group-deploy.sh".

## Uploading Artifacts

If the sample has artifacts that need to be "staged" for deployment (Configuration Scripts, Nested Templates, DSC Packages) then set the upload switch on the command.
You can optionally specify a storage account to use, if so the storage account must already exist within the subscription.  If you don't want to specify a storage account
one will be created by the script or reused if it already exists (think of this as "temp" storage for AzureRM).

### PowerShell (explicit staging)

```PowerShell
.\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation 'eastus' -ArtifactStagingDirectory '201-vm-custom-script-windows' -UploadArtifacts
```

### Bash (explicit staging)

```bash
./azure-group-deploy.sh -a [foldername] -l eastus -u
```

## Contribution Guide

To make sure your template is added to Azure.com index, please follow these guidelines. Any templates that are out of compliance will be added to the **blocklist** and not be indexed on Azure.com

## Files, folders and naming conventions

1. Every deployment template and its associated files must be contained in its own **folder**. Name this folder something that describes what your template does. Usually this naming pattern looks like **someresource-someconfiguration** or **some-platform-Capability-to-demo** (e.g. vm-from-user-image or active-directory-new-domain)

+ **Required** - samples should be located in the appropriate subfolder, not in the root.
  + **application-workloads** - contains templates that model specific application workloads for use in Azure.  After deploying the workload users should be able to utilize the application as in a production environment.
  + **demos** - contains samples that demonstrate a particular workload or capability of the Azure platform.  After deploying the sample users should be able to exercise those capabilities described.  These samples are typically not meant to be general purpose or production workloads, though some may be suitable after modification
  + **managementgroup-deployments** - contains sample templates that must be deployed at the management group scope.
  + **modules** - contains reusable templates or modules that can be used to simplify the creation of common or standard resources.  These can also be used as prereqs for samples in this repo.
  + **quickstarts** - contains sample templates that can be used to quickly provision a single or set of resources to for the purposes of evaluating the infrastructure.
  + **subscription-deployments** - contains sample templates that must be deployed at the subscription scope.
  + **tenant-deployments** - contains sample templates that must be deployed at the tenant scope.

+ **Protip** - Try to keep the name of your template folder short so that it fits inside the Github folder name column width.

1. Github uses ASCII for ordering files and folder. For consistent ordering **create all files and folders in lowercase**. The only **exception** to this guideline is the **README.md**, that should be in the format **UPPERCASE.lowercase**.

1. Include a **README.md** file that explains how the template works.

+ Guidelines on the README.md file below.

1. The bicep deployment file (optional) must be named **main.bicep**
1. The JSON deployment template file (required) must be named **azuredeploy.json**.
1. There should be a parameters file named **azuredeploy.parameters.json**.

+ Guidelines on using Bicep [below](#bicep-support)

+ Use defaultValues in the azuredeploy.json template whenever there is a value that will work for all users.  The parameters file, should contain only [GEN*](#parameters-file-placeholders) values for generating values for a test deployment.  Do NOT use values that require changes by the user for a successful deployment (e.g. changeme).

1. The template folder must contain a **metadata.json** file to allow the template to be indexed on [Azure.com](http://azure.microsoft.com/).

+ Guidelines on the metadata.json file below.

1. The custom scripts that are needed for successful template execution must be placed in a folder called **scripts**.
1. Linked templates must be placed in a folder called **nested**.
1. Images used in the README.md must be placed in a folder called **images**.
1. Any resources that need to be setup outside the template should be named prefixed with existing (e.g. existingVNET, existingDiagnosticsStorageAccount and provision using a [prereqs](#template-pre-requisites) template.

![alt text](/1-CONTRIBUTION-GUIDE/images/namingConvention.png "Files, folders and naming conventions")

+ Pull Request Guidelines

1. A single PR should reference a single template.  There shouldn't be multiple templates being referenced in a single PR
1. For each PR created the contributor needs to acknowledge the Contribution and Best Practices Guide.
1. Each PR will run through the [arm-ttk](https://github.com/Azure/arm-ttk) and [Template Analyzer](https://github.com/Azure/template-analyzer) to ensure best practices
1. Part of the pre-merge checks will be a deployment to both the Public and USGov clouds

## Target Scopes

Samples can be deployed to resourceGroup, subscription, managementGroup and tenant scope.  The scope of deployment should match the scope of the workload.  For example, while it's possible to deploy resources to a resourceGroup from a subscription scope template, this requires elevated permissions that users may not have.  For example, resourceGroups should not be created as part of a resourceGroup workload by requiring deployment to the subscription scope.  If the workload targets a resourceGroup, the sample's targetScope should target a resourceGroup.

The target scope itself should not be created by the sample unless the creation of the scope is the sample, for example creating managementGroup hierarchies.  

## Bicep support

We encourage new samples to be written directly in [Bicep](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview) and encourage existing samples to be converted to support Bicep.

1. The bicep file must be named **main.bicep**
1. The **azuredeploy.json** file must still be included, and must be generated by the bicep compiler (use this command: `bicep build main.bicep --outfile azuredeploy.json`)
1. The [**README.md**](sample-README.md) file must include a link to the bicep badge
1. The parameter file must still be named **azuredeploy.parameters.json**

An easy way to convert an existing sample to support Bicep is to use the Bicep decompiler:

```sh
bicep decompile azuredeploy.json --outfile main.bicep
```

The decompiler is not guaranteed to produce correct Bicep code from JSON, so you will need to inspect and modify the **main.bicep** file afterwards (and then use `bicep build` to generate the matching **azuredeploy.json** file). Some general guidelines:

1. Rename (F2 in VsCode) parameters and variables to be camel-cased.
1. Rename resource symbolic names to a logical, short name, such as 'storage' or 'vmStorage' for a resource of type `Microsoft.Storage/storageAccounts`. Remove `Name` from the symbolic name if the decompiler creates it that way.
1. Remove `_var`, `_param` and `_resource` prefixes if they are present in variables, parameters and resources.
1. Use bicep concepts when possible
1. See [decompiling](https://github.com/Azure/bicep/blob/main/docs/decompiling.md) for current limitations of the Bicep decompiler.
1. The top-level elements of the file must be in this order (if they exist):
    - targetScope
    - parameters
    - variables
    - resources and modules references
    - outputs
7. Parameters should have a `@description` or `@metadata` decorator, and if other decorators are present, `@description`/`@metadata` should come first. Place a blank line before and after each parameter.
```bicep
    @description('The location into which the resources should be deployed.')
    param location string = resourceGroup().location

    @description('The name of the SKU to use when creating the Azure Storage account.')
    @allowed([
      'Standard_LRS'
      'Standard_GRS'
      'Standard_ZRS'
      'Premium_LRS'
    ])
```
8. Common resource properties, when present, should be authored consistently to provide for understandability and consumption of the code:
```bicep
    resource symbolicName 'Resource.Provider/resourceType@apiVersion' = {
      comments:
      parent:
      scope:
      name:
      location:
      zones:
      sku:
      kind:
      scale:
      plan:
      identity:
      dependsOn:
      tags:
      // Any other top-level properties should go here, before 'properties'
      properties:
    }
```

See also [Best practices for Bicep](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/best-practices)

## README.md

The README.md describes your deployment. A good description helps other community members to understand your deployment. The README.md uses [Github Flavored Markdown](https://guides.github.com/features/mastering-markdown/) for formatting text. If you want to add images to your README.md file, store the images in the **images** folder. Reference the images in the README.md with a relative path (e.g. `![alt text](images/namingConvention.png "Files, folders and naming conventions")`). This ensures the link will reference the target repository if the source repository is forked. A good README.md contains the following sections

+ Deploy to Azure button
+ Visualize button
+ Description of what the template will deploy
+ Tags, that can be used for search. Specify the tags comma separated and enclosed between two back-ticks (e.g Tags: `cluster, ha, sql`)
+ *Optional: Prerequisites
+ *Optional: Description on how to use the application
+ *Optional: Notes

Do **not include** the **parameters or the variables** of the deployment script. We render this on Azure.com from the template. Specifying these in the README.md will result in **duplicate entries** on Azure.com.

You can download a [**sample README.md**](/1-CONTRIBUTION-GUIDE/sample-README.md) for use in your deployment scenario. The **sample README.md** also contains the code for the **Deploy to Azure** and **Visualize** buttons, that you can use as a reference.

## metadata.json

A valid metadata.json must adhere to the following structure

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/...",
  "itemDisplayName": "60 char limit",
  "description": "1000 char limit",
  "summary": "200 char limit",
  "githubUsername": "<e.g. bmoore-msft>",
  "dateUpdated": "<e.g. 2015-12-20>",
  "type": "QuickStart"
}
```

### schema

+ Proper metadata schema

### itemDisplayName

+ Title of the sample

### description

+ Cannot contain HTML This is used for the template description on the Azure.com index template details page

### summary

+ This is shown for template description on the main Azure.com template index page

### githubUsername

+ This is the username of the original template author. Do not change this
+ This is used to display template author and Github profile pic in the Azure.com index

### dateUpdated

+ Must be in yyyy-mm-dd format.
+ The date must not be in the future to the date of the pull request

### type

+ Type of template; in this case, QuickStart

### environments

+ An array of the clouds supported by the sample, if omitted all clouds should be supported and will be tested.  See the schema for the allowed values.

## Cloud Support

If the sample does not support all clouds add the environments property to metadata.json indicating the clouds that are supported.  If omitted, the following is the default value of the environments property.

```json
{
  ...
  "environments": [
    "AzureCloud",
    "AzureUSGovernment"
  ]
}
```

## Validation Type

If the sample cannot be automatically tested (e.g. tenant level deployments) set the validation type to "Manual", the default is "Automatic".

### Cloud Specific Parameter Files

If the sample needs separate parameter files for each cloud you can add each to the sample:

| Cloud                     | Parameter Filename             |
| :------------------------ | :----------------------------- |
| Azure Public Cloud        | azuredeploy.parameters.json    |
| Azure US Government Cloud | azuredeploy.parameters.us.json |

If only one is provided it will be used for testing in all clouds.

## Azure DevOps CI

We have automated template validation through Azure DevOps CI. These builds can be accessed by clicking the 'Details' link at the bottom of the pull-request dialog. This process will ensure that your template conforms to all the rules mentioned above and will also deploy your template to our test subscription.

### Parameters File Placeholders

To ensure your template passes, special placeholder values are required when deploying a template, depending on how the parameter is used.  For static values you can see the actual value used in the [.config.json](../test/ci-gen-setup/.config.json) file in this repo.

+ **GEN-UNIQUE[-N]** - use this for a new globally unique resource name. The value will always be alpha numeric value with a length of `[N]`, where `[N]` can be any number from 3 to 32 inclusive.  The default length when N is not specified is 18.
+ **GEN-SSH-PUB-KEY** - use this if you need an SSH public key
+ **GEN-PASSWORD** - use this if you need an azure-compatible password for a VM
+ **GEN-GUID** - use this to generate a GUID

Quickstart CI engine provides few pre-created azure components which can be used by templates for automated validation. This includes a key vault with sample SSL certificate stored, specialized and generalized Windows Server VHD's, a custom domain and SSL cert data for Azure App Service templates and more.

**Virtual Network Related placeholders:**

+ **GEN-VNET-NAME** - the name of the virtual network
+ **GEN-VNET-RESOURCEGROUP-NAME** - the name of the resource group for the virtual network
+ **GEN-VNET-SUBNET1-NAME** - the name of subnet-1
+ **GEN-VNET-SUBNET2-NAME** - the name of subnet-2

**Key Vault Related placeholders:**

+ **GEN-KEYVAULT-NAME** - the name of the keyvault
+ **GEN-KEYVAULT-RESOURCEGROUP-NAME** - the name of the resource group for the keyvault
+ **GEN-KEYVAULT-FQDN-URI** - the FQDN URI of the keyvault
+ **GEN-KEYVAULT-RESOURCE-ID** - the resource ID of the keyvault
+ **GEN-KEYVAULT-PASSWORD-SECRET-NAME** - the secret name for a password reference
+ **GEN-KEYVAULT-PASSWORD-REFERENCE** - the reference parameter used to retrieve a KeyVault Secret (use "reference" for the property name, not "value")
+ **GEN-KEYVAULT-SSL-SECRET-NAME** - the name of the secret where the sample SSL cert is stored in the keyvault
+ **GEN-KEYVAULT-SSL-SECRET-URI** - the URI of the sample SSL cert stored in the test keyvault
+ **GEN-KEYVAULT-ENCRYPTION-KEY** - the name of the sample encryption key stored in keyvault, used for disk encryption
+ **GEN-KEYVAULT-ENCRYPTION-KEY-URI** - the URI of the sample encryption key
+ **GEN-KEYVAULT-ENCRYPTION-KEY-VERSION** - the secret version of the sample encryption key
+ **GEN-SF-CERT-URL** - the URL of the sample service fabric certificate stored in keyvault
+ **GEN-SF-CERT-THUMBPRINT** - the thumbprint of the sample service fabric certificate stored in keyvault

**Existing VHD related placeholders:**

+ **GEN-SPECIALIZED-WINVHD-URI** - URI of a specialized Windows VHD stored in an existing storage account
+ **GEN-GENERALIZED-WINVHD-URI** - URI of a generalized Windows VHD stored in an existing storage account
+ **GEN-GENERALIZED-WINVHD-FILENAME** - the filename of the existing VHD
+ **GEN-DATAVHD-URI** - URI of a sample data disk VHD stored in an existing storage account
+ **GEN-VHDSTORAGEACCOUNT-NAME** - Name of storage account in which the VHD's are stored
+ **GEN-VHDRESOURCEGROUP-NAME** - Name of resource group in which the existing storage account having VHD's resides

**Custom Domain & SSL Cert related placeholders:**

+ **GEN-CUSTOM-WEBAPP-NAME** - placeholder for the name of azure app service where you'd want to attach custom domain
+ **GEN-CUSTOM-FQDN-NAME** - sample custom domain which can be added to an App Service
+ **GEN-CUSTOM-DOMAIN-SSLCERT-THUMBPRINT** - SSL cert thumbprint for the custom domain used in the custom FQDN
+ **GEN-CUSTOM-DOMAIN-SSLCERT-PASSWORD** - Password of the sample SSL cert
+ **GEN-CUSTOM-DOMAIN-SSLCERT-PFXDATA** - PFX data for the sample SSL cert
+ **GEN-SELFSIGNED-CERT-PFXDATA** - PFX data for a sample self signed cert
+ **GEN-SELFSIGNED-CERT-CERDATA** - CER data for a sample self signed cert
+ **GEN-SELFSIGNED-CERT-PASSWORD** - password for a sample self signed cert
+ **GEN-SELFSIGNED-CERT-DNSNAME** - DNS name for a sample self signed cert

**Custom Domain & SSL Cert related placeholders:**

+ **GEN-FRONTDOOR-NAME** - placeholder for the frontdoor name reserved for CI/CD
+ **GEN-FRONTDOOR-CUSTOM-HOSTNAME** - custom hostname with CNAME record mapped for the GEN-FRONTDOOR-NAME value

**AppConfiguration Store related placeholders:**

+ **GEN-APPCONFIGSTORE-NAME** - placeholder for the Microsoft.AppConfiguration/configurationStores
+ **GEN-APPCONFIGSTORE-RESOURCEGROUP-NAME** - resource group name for the AppConfig store
+ **GEN-APPCONFIGSTORE-KEY1** - sample key/value stored in the AppConfig store, label is "template"
+ **GEN-APPCONFIGSTORE-WINDOWSOSVERSION** - sample key/value with a SKU Name for a windows server image, label is "template"
+ **GEN-APPCONFIGSTORE-DISKSIZEGB** - sample key/value with a disk size, in GB for a VM disk, label is "template"

+ **GEN-USER-ASSIGNED-IDENTITY-NAME** - name of a userAssigned MSI that has permission to the keyvault secrets
+ **GEN-USER-ASSIGNED-IDENTITY-RESOURCEGROUP-NAME** - resource group of the userAssigned identity for retrieving the resourceId

+ **GEN-MACHINE-LEARNING-SP-OBJECTID** - objectId of the Azure ML Service Principal in the tenant
+ **GEN-COSMOS-DB-SP-OBJECTID** - objectId of the Cosmos DB Service Principal in the tenant

**Static website related placeholders:**
+ **GEN-STATIC-WEBSITE-URL** - full URL of a static website
+ **GEN-STATIC-WEBSITE-HOST-NAME** - host name of a static website

Here's an example in an `azuredeploy.parameters.json` file:

```json

{
"$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
"contentVersion": "1.0.0.0",
"parameters": {
 "newStorageAccountName":{
  "value": "GEN-UNIQUE"
 },
 "adminUsername": {
  "value": "GEN-UNIQUE"
 },
 "sshKeyData": {
  "value": "GEN-SSH-PUB-KEY"
 },
 "dnsNameForPublicIP": {
  "value": "GEN-UNIQUE-13"
 }
}
```

### raw.githubusercontent.com Links

If you're making use of **raw.githubusercontent.com** links within your template contribution (within the template file itself or any scripts in your contribution) please ensure the following:

+ Ensure any raw.githubusercontent.com links which refer to content within your pull request points to `https://raw.githubusercontent.com/Azure/azure-quickstart-templates/...` and **NOT** your fork.
+ All raw.githubusercontent.com links are placed in your azuredeploy.json and you pass the link down into your scripts & linked templates via this top-level template. This ensures we re-link correctly from your pull-request repository and branch.
+ Although pull requests with links pointing to `https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/...` may not exist in the Azure repo at the time of your pull-request, at CI run-time, those links will be converted to `https://raw.githubusercontent.com/{your_user_name}/azure-quickstart-templates/{your_branch}/...`. Be sure to check the casing of `https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/...` as this is case-sensitive.

Note: You can find an **example** of relative linking in the [nested template section](/1-CONTRIBUTION-GUIDE/best-practices.md#nested-templates) of best practices document.

### Template Pre-requisites

If your template has some pre-requisite such as existing Virtual Network or storage account, you should also submit pre-requisite template which deploys the pre-requisite components. CI automated validation engine automatically validates and deploy the pre-reqsuite template first and then deploys the main template. Following guidelines would help you in understanding how to leverage this capability.

+ Create a folder named `prereqs` in root of your template folder, Store pre-requisite template file, parameters file and artifacts inside this folder.
+ Store pre-requisite template file with name `prereq.azuredeploy.json` and parameters files with name `prereq.azuredeploy.parameters.json`
+ `prereq.azuredeploy.json` should deploy all required pre-existing resources by your main template and also output the values required by main template to leverage those resources. For example, if your template needs an existing VNET to be available prior to the deployment of main template, you should develop a pre-req template which deploys a VNET and outputs the VNET ID or VNET name of the virtual network created.
+ In order to use the values generated by outputs after deployment of `prereq.azuredeploy.json`, you will need to define parameter values as `GET-PREREQ-OutputName`. For example, if you generated a output with name `vnetID` in pre-req template, in order use the value of this output in main template, enter the value of corresponding parameter in main template parameters file as `GET-PREREQ-vnetID`
+ Check out this [sample template](https://github.com/Azure/azure-quickstart-templates/tree/master/101-subnet-add-vnet-existing) to learn more
+ If the prereqs and the sample must be deployed to the same resource group add a file named `.settings.json` to the prereqs folder and put the following json snippet into the file (the comment is optional).  Do this only if required by the sample, otherwise it may block customer deployment scenarios:

```json
{
    "comment": "If prereqs need to be deployed to the same resourceGroup as the rest of the sample set the PrereqResourceGroupNameSuffix property to an empty string - otherwise you can omit this file",
    "PrereqResourceGroupNameSuffix": ""
}
```

### Portal Deployments with createUiDefinition.json

You can optionally provide a UI Definition file to customize the deployment experience in the Azure portal.  If one is provided, be sure to update the links in the readme file to include the createUiDefinition.json file in the url.  See the [sample-README.md](./sample-README.md) file for an example.

More information can be found at the links below - the documentation is tailored for the marketplace but the schema and behavior for createUiDefinition is a generic construct for the Azure portal.

[createUiDefinition Overview](https://docs.microsoft.com/en-us/azure/azure-resource-manager/managed-applications/create-uidefinition-overview)

[createUiDefinition UI elements reference](https://docs.microsoft.com/en-us/azure/azure-resource-manager/managed-applications/create-uidefinition-elements)

[testing createUiDefinition](https://docs.microsoft.com/en-us/azure/azure-resource-manager/managed-applications/test-createuidefinition)

### Diagnosing Failures

If your deployment fails, check the details link of the Travis CI build, which will take you to the CI log. If the template deployment was attempted, you will get two top-level fields. The first is `parameters` which is the rendered version of your `azuredeploy.parameters.json`. This will include any replacements for `GEN-` parameters. The second is `template` which is the contents of your `azuredeploy.json`, after any `raw.githubusercontent.com` relinking. These values are the exact values you need to reproduce the error. Keep in mind, that depending on the resources allocated, it can take a few minutes for the CI system to cleanup provisioned resources.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
