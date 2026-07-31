# Azure Resource Manager QuickStart Templates

This repo contains all currently available Azure Resource Manager templates contributed by the community. A searchable template index is maintained at [Azure Resource Manager Templates](https://azure.microsoft.com/documentation/templates/).

The following information is relevant to get started with contributing to this repository.

+ [**Contribution guide**](/1-CONTRIBUTION-GUIDE/README.md#contribution-guide). Describes the minimal guidelines for contributing.
+ [**Best practices**](/1-CONTRIBUTION-GUIDE/best-practices.md#best-practices). Best practices for improving the quality of your template design.
+ [**Git tutorial**](/1-CONTRIBUTION-GUIDE/git-tutorial.md#git-tutorial). Step by step to get you started with Git.
+ [**Useful Tools**](/1-CONTRIBUTION-GUIDE/useful-tools.md#useful-tools). Useful resources and tools for Azure development.

## Deploying Samples

You can deploy these samples directly through the Azure Portal or by using the scripts supplied in the root of the repo.

To deploy a sample using the Azure Portal, click the **Deploy to Azure** button found in the README.md of each sample.

To deploy the sample via the command line (using [Azure PowerShell](https://docs.microsoft.com/powershell/azure/overview) or the [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)) you can use the scripts below.

Simply execute the script and pass in the folder name of the sample you want to deploy.

For example:

### PowerShell

```PowerShell
.\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation 'eastus' -ArtifactStagingDirectory '[foldername]'
```

### Bash

Please ensure that you have [node and npm](https://docs.npmjs.com/getting-started/installing-node), [jq](https://stedolan.github.io/jq/download/) and [azure-cli](https://docs.microsoft.com/cli/azure/install-azure-cli) installed.

```bash
./az-group-deploy.sh -a [foldername] -l eastus
```

+ If you see the following error: "syntax error near unexpected token `$'in\r''", run this command: 'dos2unix az-group-deploy.sh'.
+ If you see the following error: "jq: command not found", run this command: "sudo apt install jq".
+ If you see the following error: "node: not found", install node and npm.
+ If you see the following error: "az-group-deploy.sh is not a command", make sure you run "chmod +x az-group-deploy.sh".

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
./az-group-deploy.sh -a [foldername] -l eastus -u
```

Note, that for samples that follow the best practices for artifacts in the repo, the `-UploadArtifacts` switch is not needed.

## Contribution Guide

To make sure your template is added to Azure.com index, please follow these guidelines.  PRs that do not follow these guidelines will not be merged.

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

+ **Protip** - Try to keep the name of your template folder short so that it fits inside the GitHub folder name column width.

1. GitHub uses ASCII for ordering files and folder. For consistent ordering **create all files and folders in lowercase**. The only **exception** to this guideline is the **README.md** file, that should be in the format **UPPERCASE.lowercase**.

1. Include a **README.md** file that explains how the template works.

+ Guidelines on the README.md file below.

1. The bicep deployment file (optional) must be named **main.bicep**
1. The JSON deployment template file (required only when bicep is not included) must be named **azuredeploy.json**.
1. There should be a parameters file named **azuredeploy.parameters.json**.

+ Guidelines on using Bicep [below](#bicep-support)

+ Use defaultValues in the template whenever there is a value that will work for all users.  The parameters file, should contain only [GEN*](#parameters-file-placeholders) values for generating values for a test deployment.  Do NOT use values that require changes by the user for a successful deployment (e.g. changeme).

1. The template folder must contain a **metadata.json** file, the information in this file is used to create a searchable index at [https://learn.microsoft.com/samples](https://aka.ms/azqst).

+ Pull Request Guidelines

1. A single PR should reference a single template.  There shouldn't be multiple templates/samples being updated in a single PR.  Testing will block samples that update more than one sample.
1. For each PR created the contributor needs to acknowledge the Contribution and Best Practices Guide.
1. **Contributors must deploy their template(s) to Azure before submitting a PR.** After a successful deployment, capture the deployment results (correlationId, deploymentName) and add them to the `testResult` section of **metadata.json**.  See the [metadata.json](#metadatajson) section below for the required format.
1. Each PR will be validated by GitHub Actions workflows that check structural correctness ([validate-samples.yml](../.github/workflows/validate-samples.yml)) and verify the deployment results against Azure logs ([ValidateSampleDeployments.yml](../.github/workflows/ValidateSampleDeployments.yml)).
1. If you change any `.bicep` or `.json` template file, you **must** re-deploy and update `testResult` in metadata.json — the validation workflow will fail otherwise.

## Target Scopes

Samples can be deployed to resourceGroup, subscription, managementGroup and tenant scope.  The scope of deployment should match the scope of the workload.  For example, while it's possible to deploy resources to a resourceGroup from a subscription scope template, this requires elevated permissions that users may not have.  For example, resourceGroups should not be created as part of a resourceGroup workload by requiring deployment to the subscription scope.  If the workload targets a resourceGroup, the sample's targetScope should target a resourceGroup.

The target scope itself should not be created by the sample unless the creation of the scope is the sample, for example creating managementGroup hierarchies.

## Bicep support

We encourage new samples to be written directly in [Bicep](https://docs.microsoft.com/azure/azure-resource-manager/bicep/overview) and encourage existing samples to be converted to support Bicep.

1. The bicep file must be named **main.bicep**
1. The **azuredeploy.json** must **not** be included in the PR as it will be built automatically when the sample is merged.
1. The [**README.md**](sample-README.md) file must include a link to the bicep badge
1. The parameter file must still be named **azuredeploy.parameters.json**

An easy way to convert an existing sample to support Bicep is to use the Bicep decompiler:

```sh
bicep decompile azuredeploy.json --outfile main.bicep
```

The decompiler is not guaranteed to produce correct Bicep code from JSON, so you will need to inspect and modify the **main.bicep** file afterwards. Some general guidelines:

1. Rename (F2 in VsCode) parameters and variables to be camel-cased.
1. Rename resource symbolic names to a logical, short name, such as 'storage' or 'vmStorage' for a resource of type `Microsoft.Storage/storageAccounts`. Remove `Name` from the symbolic name if the decompiler creates it that way.
1. Remove `_var`, `_param` and `_resource` prefixes if they are present in variables, parameters and resources.
1. Use bicep concepts when possible
1. See [decompiling](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/decompile?tabs=azure-cli) for current limitations of the Bicep decompiler.
1. The top-level elements of the file must be in this order (if they exist):
    + targetScope
    + parameters
    + variables
    + resources and modules references
    + outputs

1. Parameters should have a `@description` or `@metadata` decorator, and if other decorators are present, `@description`/`@metadata` should come first. Place a blank line before and after each parameter.

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

See also [Best practices for Bicep](https://docs.microsoft.com/azure/azure-resource-manager/bicep/best-practices)

## README.md

The README.md describes your deployment. A good description helps other community members to understand your deployment. The README.md uses [GitHub Flavored Markdown](https://guides.github.com/features/mastering-markdown/) for formatting text. If you want to add images to your README.md file, store the images in the **images** folder. Reference the images in the README.md with a relative path (e.g. `![alt text](images/namingConvention.png "Files, folders and naming conventions")`). This ensures the link will reference the target repository if the source repository is forked. A good README.md contains the following sections:

+ Deploy to Azure/AzureGov button
+ Visualize button
+ Description of what the template will deploy
+ Tags, that can be used for search. Specify the tags comma separated and enclosed between two back-ticks (e.g Tags: `cluster, ha, sql`)
+ *Optional: Prerequisites
+ *Optional: Description on how to use the application
+ *Optional: Notes

You can download a [**sample README.md**](/1-CONTRIBUTION-GUIDE/sample-README.md) for use in your deployment scenario. The **sample README.md** also contains the code for the **Deploy to Azure** and **Visualize** buttons, that you can use as a reference.

## metadata.json

A valid metadata.json must adhere to the following structure

```json
{
  "$schema": "https://aka.ms/azure-quickstart-templates-metadata-schema#",
  "itemDisplayName": "60 char limit",
  "description": "1000 char limit",
  "summary": "200 char limit",
  "githubUsername": "<e.g. bmoore-msft>",
  "dateUpdated": "<e.g. 2015-12-20>",
  "type": "QuickStart",
  "testResult": {
    "deployments": {
      "templateFileName": "main.bicep",
      "correlationId": "<deployment-correlation-id>",
      "deploymentName": "<deployment-name>"
    }
  }
}
```

Guidelines on the metadata.json:

+ The schema for the metadata.json file can be found [here](https://github.com/Azure/azure-quickstart-templates/blob/master/test/metadata.schema.json)
+ **itemDisplayName:** short description of the sample
+ **summary:** short summary of what the sample does or is meant to illustrate, 200 chars in length
+ **description:** long description for the sample, can be up to 1000 chars
+ **githubUsername:** user that owns the sample, don't change this unless you want to assume ownership
+ **docOwner:** used to identify the owner of any documentation that references this sample - the doc owner is notified of changes via PRs
+ **validationType:** if the sample requires manual validation, set this to `Manual` otherwise omit the property
+ **type:** type of sample, see the schema for possible value
+ **environments:** list of supported clouds, if omitted, all clouds will be tested and listed as supported
+ **dateUpdated:** the date the sample was last updated, this will be automatically updated when the PR is merged
+ **testResult:** deployment test results — see [testResult](#testresult) below

### testResult

The `testResult` field is **required** for all samples and must contain a `deployments` property with the results of your deployment(s).  Contributors are expected to deploy their template(s) to Azure and capture the deployment results before submitting a PR.

**Required fields** per deployment entry:

| Field              | Description                                                         |
| :----------------- | :------------------------------------------------------------------ |
| `templateFileName` | The template file name: `azuredeploy.json` or `main.bicep`         |
| `correlationId`    | The Azure deployment correlation ID (a GUID)                        |
| `deploymentName`   | The Azure deployment name                                           |

**Optional fields:**

| Field           | Description                                                                        |
| :-------------- | :--------------------------------------------------------------------------------- |
| `TIMESTAMP`     | Deployment timestamp (informational only)                                          |
| `templateHash`  | Template hash (optional — computed automatically from the template file by the CI)  |

#### How to obtain deployment results

After deploying your template using Azure CLI, PowerShell or the portal, you can retrieve the `correlationId` and `deploymentName`:

**Azure CLI:**

```bash
# Deploy the template
az deployment group create \
  --resource-group <resource-group> \
  --template-file main.bicep \
  --name <deployment-name> \
  --parameters @azuredeploy.parameters.json

# Get the correlationId
az deployment group show \
  --resource-group <resource-group> \
  --name <deployment-name> \
  --query properties.correlationId -o tsv
```

**Azure PowerShell:**

```powershell
# Deploy the template
New-AzResourceGroupDeployment `
  -ResourceGroupName <resource-group> `
  -TemplateFile main.bicep `
  -Name <deployment-name>

# Get the correlationId
(Get-AzResourceGroupDeployment -ResourceGroupName <resource-group> -Name <deployment-name>).CorrelationId
```

**Azure Portal:** Navigate to the resource group → Deployments → select the deployment → Overview. The correlation ID and deployment name are displayed in the deployment details.

#### Single deployment (no prereqs)

For samples without a `prereqs/` folder, `deployments` can be a single object:

```json
"testResult": {
  "deployments": {
    "templateFileName": "main.bicep",
    "correlationId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "deploymentName": "my-deployment-name"
  }
}
```

#### Samples with prereqs

When your sample has a `prereqs/` folder, `deployments` **must** be an array with one entry per deployed template (prereqs and main):

```json
"testResult": {
  "deployments": [
    {
      "templateFileName": "prereqs/prereq.main.bicep",
      "correlationId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
      "deploymentName": "prereqs-deployment-name"
    },
    {
      "templateFileName": "main.bicep",
      "correlationId": "yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy",
      "deploymentName": "main-deployment-name"
    }
  ]
}
```

### Cloud Specific Parameter Files

If the sample needs separate parameter files for each cloud you can add each to the sample:

| Cloud                     | Parameter Filename             |
| :------------------------ | :----------------------------- |
| Azure Public Cloud        | azuredeploy.parameters.json    |
| Azure US Government Cloud | azuredeploy.parameters.us.json |

If only one is provided it will be used for testing in all clouds.

## GitHub Actions CI

We have automated template validation through GitHub Actions.  Three workflows run as part of the PR process:

### 1. Validate Sample Contributions (`validate-samples.yml`)

This workflow runs automatically on every PR to `master`. It validates:

+ **Structural checks:** metadata.json exists, is valid JSON, and contains all required fields (including `testResult`)
+ **Duplicate folder names:** ensures your sample folder name is unique across the repo
+ **README.md checks:** verifies deploy buttons, portal links and Bicep references are present
+ **Template-metadata consistency:** if any `.bicep` or `.json` template file is modified, metadata.json must also be updated with fresh `testResult` data
+ **Prereqs validation:** if a `prereqs/` folder exists, validates that `testResult.deployments` is an array with matching entries

### 2. Validate ARM Deployments (`ValidateSampleDeployments.yml`)

This workflow is triggered by a repo maintainer posting a `/validate` comment on your PR.  It validates the deployment results you provided in `testResult`:

+ Verifies that the `correlationId` and `deploymentName` exist in the Azure deployment logs
+ Confirms the deployment `executionStatus` is `Succeeded`
+ Computes a `templateHash` from the template file in the PR and verifies it matches the hash recorded in the deployment logs — this ensures the template you deployed is the same one in the PR. When the PR ships only a `.bicep` source (no committed `azuredeploy.json`), CI re-compiles using the **same Bicep version you used at deployment time** (read from the deployment log) so toolchain version skew does not cause spurious mismatches.

The `/validate` command can only be run after `validate-samples.yml` passes.

### 3. Summarize PR (`summarize-pr.yml`)

Triggered by a `/summarize` comment on a PR, this workflow generates an AI-powered summary of the sample changes to help reviewers.

### Contributor Workflow Summary

1. **Create or update** your sample template (main.bicep or azuredeploy.json)
2. **Deploy** the template to Azure using the CLI, PowerShell or the portal
3. **Capture** the deployment results: `correlationId`, `deploymentName`, and `templateFileName`
4. **Update** `metadata.json` with the `testResult` section containing the deployment results
5. **Submit** your PR — `validate-samples.yml` runs automatically
6. A **maintainer** runs `/validate` to validate your deployment results against Azure logs
7. Optionally, a reviewer runs `/summarize` for an AI-generated PR summary

### Artifacts Required for Deployment and raw.githubusercontent.com Links

In general, when following the best practices for the repo, you should never have any absolute URLs in a sample.  Any files needed for the sample must be hosted in the **Azure/azure-quickstart-templates** repo and the samples must reference those samples using the pattern described in the [best practices document](./best-practices.md).

### Template Pre-requisites

If your sample requires pre-existing resources (for example an existing Virtual Network or Storage Account) that a customer would not normally create as part of the sample itself, place the templates that provision those resources in a `prereqs` folder inside your sample folder. When you record deployment results in `metadata.json`, use the `prereqs/` path in `templateFileName` so `validate-samples.yml` and `ValidateSampleDeployments.yml` can locate and compile the correct file.

+ Create a folder named `prereqs` in the root of your sample folder and store the prereq template, parameters file, and any artifacts inside it.
+ Name the prereq template `prereq.azuredeploy.json` or `prereq.main.bicep`, and the parameters file `prereq.azuredeploy.parameters.json`.
+ The prereq template should deploy every pre-existing resource that your main template expects, and expose their identifiers (resource IDs, names, etc.) as `outputs` so you can pass them into your main deployment.
+ Search other samples with a `prereqs` folder for concrete examples.

### Portal Deployments with createUiDefinition.json

You can optionally provide a UI Definition file to customize the deployment experience in the Azure portal.  If one is provided, be sure to update the links in the readme file to include the createUiDefinition.json file in the url.  See the [sample-README.md](./sample-README.md) file for an example.

More information can be found at the links below - the documentation is tailored for the marketplace but the schema and behavior for createUiDefinition is a generic construct for the Azure portal.

[createUiDefinition Overview](https://docs.microsoft.com/azure/azure-resource-manager/managed-applications/create-uidefinition-overview)

[createUiDefinition UI elements reference](https://docs.microsoft.com/azure/azure-resource-manager/managed-applications/create-uidefinition-elements)

[testing createUiDefinition](https://docs.microsoft.com/azure/azure-resource-manager/managed-applications/test-createuidefinition)

### Diagnosing Failures

If your PR checks fail, click the **Details** link next to the failed check in the pull-request dialog to view the GitHub Actions workflow log. The log will show which validation step failed and provide specific error messages.

Common failure reasons:

+ **metadata.json missing `testResult`:** You must deploy your template and add the deployment results to metadata.json before submitting the PR.  See [testResult](#testresult) for the required format.
+ **Template changed but metadata.json not updated:** If you modify any `.bicep` or `.json` file, you must re-deploy and update the `testResult` section with fresh deployment results.
+ **`/validate` fails with "No ADX record found":** The `correlationId` or `deploymentName` in your metadata.json does not match any Azure deployment log.  Double-check the values are correct.
+ **`/validate` fails with templateHash mismatch:** The template you deployed differs substantively from the template in your PR. CI pins to the Bicep version recorded in your deployment log, so this is no longer caused by `az bicep upgrade` between deployments and PR open — it indicates real source drift. Re-deploy the exact template from your PR branch and update the deployment results.
+ **`/validate` fails with executionStatus not Succeeded:** Your deployment did not succeed.  Fix the template, re-deploy, and update the deployment results.

Keep in mind that depending on the resources allocated, it can take a few minutes for the CI system to cleanup provisioned resources.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
