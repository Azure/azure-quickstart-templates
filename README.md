# Azure Resource Manager QuickStart Templates

This repo contains all currently available Azure Resource Manager templates contributed by the community. A searchable template index is maintained at https://azure.microsoft.com/en-us/documentation/templates/.
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

- If you see the following error: "syntax error near unexpected token `$'in\r''", run this command: 'dos2unix azure-group-deploy.sh'.
- If you see the following error: "jq: command not found", run this command: "sudo apt install jq".
- If you see the following error: "node: not found", install node and npm.
- If you see the following error: "azure-group-deploy.sh is not a command", make sure you run "chmod +x azure-group-deploy.sh".

## Uploading Artifacts

If the sample has artifacts that need to be "staged" for deployment (Configuration Scripts, Nested Templates, DSC Packages) then set the upload switch on the command.
You can optionally specify a storage account to use, if so the storage account must already exist within the subscription.  If you don't want to specify a storage account
one will be created by the script or reused if it already exists (think of this as "temp" storage for AzureRM).

### PowerShell

```PowerShell
.\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation 'eastus' -ArtifactStagingDirectory '201-vm-custom-script-windows' -UploadArtifacts 
```

### Bash
```bash
./azure-group-deploy.sh -a [foldername] -l eastus -u
```

## Contribution guide

To make sure your template is added to Azure.com index, please follow these guidelines. Any templates that are out of compliance will be added to the **blacklist** and not be indexed on Azure.com

## Files, folders and naming conventions

1. Every deployment template and its associated files must be contained in its own **folder**. Name this folder something that describes what your template does. Usually this naming pattern looks like **appName-osName** or **level-platformCapability** (e.g. 101-vm-user-image) 
 + **Required** - Numbering should start at 101. 100 is reserved for things that need to be at the top.
 + **Protip** - Try to keep the name of your template folder short so that it fits inside the Github folder name column width.
2. Github uses ASCII for ordering files and folder. For consistent ordering **create all files and folders in lowercase**. The only **exception** to this guideline is the **README.md**, that should be in the format **UPPERCASE.lowercase**.
3. Include a **README.md** file that explains how the template works. 
 + Guidelines on the README.md file below.
4. The deployment template file must be named **azuredeploy.json**.
5. There should be a parameters file named **azuredeploy.parameters.json**. 
 + Please fill out the values for the parameters according to rules defined in the template (allowed values etc.), For parameters without rules, a simple "changeme" will do as the acomghbot only checks for syntactic correctness using the ARM Validate Template [API](https://msdn.microsoft.com/en-us/library/azure/dn790547.aspx).
6. The template folder must contain a **metadata.json** file to allow the template to be indexed on [Azure.com](http://azure.microsoft.com/). 
 + Guidelines on the metadata.json file below.
7. The custom scripts that are needed for successful template execution must be placed in a folder called **scripts**.
8. Linked templates must be placed in a folder called **nested**.
9. Images used in the README.md must be placed in a folder called **images**. 
10. Any resources that need to be setup outside the template should be named prefixed with existing (e.g. existingVNET, existingDiagnosticsStorageAccount).

![alt text](/1-CONTRIBUTION-GUIDE/images/namingConvention.png "Files, folders and naming conventions")
 
## README.md

The README.md describes your deployment. A good description helps other community members to understand your deployment. The README.md uses [Github Flavored Markdown](https://guides.github.com/features/mastering-markdown/) for formatting text. If you want to add images to your README.md file, store the images in the **images** folder. Reference the images in the README.md with a relative path (e.g. `![alt text](images/namingConvention.png "Files, folders and naming conventions")`). This ensures the link will reference the target repository if the source repository is forked. A good README.md contains the following sections

+ Deploy to Azure button
+ Visualize button
+ Description of what the template will deploy
+ Tags, that can be used for search. Specify the tags comma seperated and enclosed between two back-ticks (e.g Tags: `cluster, ha, sql`)
+ *Optional: Prerequisites
+ *Optional: Description on how to use the application
+ *Optional: Notes

Do **not include** the **parameters or the variables** of the deployment script. We render this on Azure.com from the template. Specifying these in the README.md will result in **duplicate entries** on Azure.com.

You can download a [**sample README.md**](/1-CONTRIBUTION-GUIDE/sample-README.md) for use in your deployment scenario. The **sample README.md** also contains the code for the **Deploy to Azure** and **Visualize** buttons, that you can use as a reference.

## metadata.json

A valid metadata.json must adhere to the following structure

```
{
  "itemDisplayName": "",
  "description": "",
  "summary": "",
  "githubUsername": "",
  "dateUpdated": "<e.g. 2015-12-20>"
}
```

The metadata.json file will be validated using these rules

**itemDisplayName**

+ Cannot be more than 60 characters

**description**

+ Cannot be more than 1000 characters
+ Cannot contain HTML This is used for the template description on the Azure.com index template details page

**summary**

+ Cannot be more than 200 characters
+ This is shown for template description on the main Azure.com template index page

**githubUsername**

+ This is the username of the original template author. Do not change this
+ This is used to display template author and Github profile pic in the Azure.com index

**dateUpdated**

+ Must be in yyyy-mm-dd format.
+ The date must not be in the future to the date of the pull request

## Common errors from acomghbot

acomghbot is a bot designed to enforce the above rules and check the syntactic correctness of the template using the ARM Validate Template [API](https://msdn.microsoft.com/en-us/library/azure/dn790547.aspx). Below are some of the more cryptic error messages you might receive from the bot and how to solve these issues.

+ This error is received when the parameters file contains a parameter that is not defined in the template.

 The file azuredeploy.json is not valid. Response from ARM API: BadRequest - {"error":{"code":"InvalidTemplate","message":"Deployment template validation failed: 'The template parameters 'vmDnsName' are not valid; they are not present in the original template and can therefore not be provided at deployment time. The only supported parameters for this template are 'newStorageAccountName, adminUsername, adminPassword, dnsNameForPublicIP, windowsOSVersion, sizeOfDiskInGB'.'."}}

+ This error is received when a parameter in the parameter file has an empty value.

 The file azuredeploy.json is not valid. Response from ARM API: BadRequest - {"error":{"code":"InvalidTemplate","message":"Deployment template validation failed: 'The template resource '' at line '66' and column '6' is not valid. The name property cannot be null or empty'."}}

+ This error message is received when a value entered in the parameters file is different from the allowed values defined for the parameter in the template file.

 The file azuredeploy.json is not valid. Response from ARM API: BadRequest - {"error":{"code":"InvalidTemplate","message":"Deployment template validation failed: 'The provided value for the template parameter 'publicIPAddressType' at line '40' and column '29' is not valid.'."}}

## Travis CI

We have automated template validation through Travis CI. These builds can be accessed by clicking the 'Details' link at the bottom of the pull-request dialog. This process will ensure that your template conforms to all the rules mentioned above and will also deploy your template to our test azure subscription.

### Parameters File Placeholders

To ensure your template passes, special placeholder values are required when deploying a template, depending what the parameter is used for:

+ **GEN-UNIQUE** - use this placeholder for new storage account names, domain names for public ips and other fields that need a unique name. The value will always be alpha numeric value with a length of 18 characters.
+ **GEN-UNIQUE-[N]** - use this placeholder for new storage account names, domain names for public ips and other fields that need a unique name. The value will always be alpha numeric value with a length of `[N]`, where `[N]` can be any number from 3 to 32 inclusive.
+ **GEN-SSH-PUB-KEY** - use this placeholder if you need an SSH public key
+ **GEN-PASSWORD** - use this placeholder if you need an azure-compatible password for a VM

Quickstart CI engine provides few pre-created azure components which can be used by templates for automated validation. This includes a key vault with sample SSL certificate stored, specialized and generalized Windows Server VHD's, a custom domain and SSL cert data for Azure App Service templates.

**Key Vault Related placeholders:**
+ **GEN-KEYVAULT-NAME** - use this placeholder to leverage an existing test keyvault in your templates
+ **GEN-KEYVAULT-FQDN-URI** - use this placeholder to get FQDN URI of existing test keyvault.
+ **GEN-KEYVAULT-RESOURCE-ID** - use this placeholder to get Resource ID of existing test keyvault.
+ **GEN-KEYVAULT-SSL-SECRET-NAME** - use this placeholder to use the sample SSL cert stored in the test keyvault
+ **GEN-KEYVAULT-SSL-SECRET-URI** - use this placeholder to use the sample SSL cert stored in the test keyvault

** Existing VHD related placeholders:**
+ **GEN-SPECIALIZED-WINVHD-URI** - URI of a specialized Windows VHD stored in an existing storage account.
+ **GEN-GENERALIZED-WINVHD-URI** - URI of a generalized Windows VHD stored in an existing storage account.
+ **GEN-DATAVHD-URI** - URI of a sample data disk VHD stored in an existing storage account.
+ **GEN-VHDSTORAGEACCOUNT-NAME** - Name of storage account in which the VHD's are stored.
+ **GEN-VHDRESOURCEGROUP-NAME** - Name of resource group in which the existing storage account having VHD's resides.

** Custom Domain & SSL Cert related placeholders:**
+ **GEN-CUSTOMFQDN-WEBAPP-NAME** - Placeholder for the name of azure app service where you'd want to attach custom domain.
+ **GEN-CUSTOM-FQDN-NAME** - Sample Custom domain which can be added to App Service created above.
+ **GEN-CUSTOM-DOMAIN-SSLCERT-THUMBPRINT** - SSL cert thumbpring for the custom domain used in above placeholder
+ **GEN-CUSTOM-DOMAIN-SSLCERT-PASSWORD** - Password of the SSL certificate used in above placeholder.


Here's an example in an `azuredeploy.parameters.json` file:

```
{
"$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
"contentVersion": "1.0.0.0",
"parameters": {
 "newStorageAccountName":{
  "value": "GEN-UNIQUE"
 },
 "adminUsername": {
  "value": "sedouard"
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

+ Create a folder named  `prereqs ` in root of your template folder, Store  pre-requisite template file, parameters file and  artifacts inside this folder.
+ Store pre-requisite template file with name  `prereqs.azuredeploy.json ` and parameters files with name  `prereqs.azuredeploy.json.parameters`
+  `prereqs.azuredeploy.json` should deploy all required pre-existing resources by your main template and also output the values required by main template to leverage those resources. For example, if your template needs an existing VNET to be available prior to the deployment of main template, you should develop a pre-req template which deployes a VNET and outputs the VNET ID or VNET name of the virtual network created. 
+ In order to use the values generated by outputs after deployment of `prereqs.azuredeploy.json`, you will need to define parameter values as `GET-PREREQ-OutputName`. For exmaple, if you generated a output with name  `vnetID` in pre-req template, in order use the value of this output in main template, enter the value of corresponding parameter in main template parameters file as `GET-PREREQ-vnetID`
+ Check out this [sample template](https://github.com/Azure/azure-quickstart-templates/tree/master/101-subnet-add-vnet-existing) to learn more 

If your template has some pre-requisite such as an Azure Active Directory application or service principal, we don't support this yet. To bypass the CI workflow include a file called .ci_skip in the root of your template folder.

### Diagnosing Failures

If your deployment fails, check the details link of the Travis CI build, which will take you to the CI log. If the template deployment was attempted, you will get two top-level fields. The first is `parameters` which is the rendered version of your `azuredeploy.parameters.json`. This will include any replacements for `GEN-` parameters. The second is `template` which is the contents of your `azuredeploy.json`, after any `raw.githubusercontent.com` relinking. These values are the exact values you need to reproduce the error. Keep in mind, that depending on the resources allocated, it can take a few minutes for the CI system to cleanup provisioned resources.

Here is an example failure log:

```
Server Error:{
    "error": "Deployment provisioning state was not successful\n",
    "_rgName": "qstci-26dd2ec4-bae9-12fb-fd46-fd4ce455a035",
    "command": "azure group deployment create --resource-group (your_group_name) --template-file azuredeploy.json --parameters-file azuredeploy.parameters.json",
    "parameters": {
        "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
        "contentVersion": "1.0.0.0",
        "parameters": {
            "clusterName": {
                "value": "ci4391bcd700f86e84"
            },
            "clusterType": {
                "value": "hadoop"
            },
            "clusterStorageAccountName": {
                "value": "cifb07cf059735afba"
            },
            "clusterLoginUserName": {
                "value": "admin"
            },
            "clusterLoginPassword": {
                "value": "ciP$ss2e6a28784055eda8"
            }
        }
    },
    "template": {
        "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
        "contentVersion": "1.0.0.0",
        "parameters": {
            "clusterType": {
                "type": "string",
                "allowedValues": [
                    "hadoop",
                    "hbase",
                    "storm",
                    "spark"
                ],
                "metadata": {
                    "description": "The type of the HDInsight cluster to create."
                }
            }
            // more parameters here...
        },
        "variables": {
            "defaultApiVersion": "2015-06-15",
            "clusterApiVersion": "2015-03-01-preview",
            "adlsApiVersion": "2015-10-01-preview"
        },
        "resources": [
            {
                "name": "[parameters('adlStoreName')]",
                "type": "Microsoft.DataLakeStore/accounts",
                "location": "East US 2",
                "apiVersion": "[variables('adlsApiVersion')]",
                "dependsOn": [],
                "tags": {},
                "properties": {
                    "initialUser": "[parameters('servicePrincipalObjectId')]"
                }
            },
            // more resources here...
        ],
        "outputs": {
            "adlStoreAccount": {
                "type": "object",
                "value": "[reference(resourceId('Microsoft.DataLakeStore/accounts',parameters('adlStoreName')))]"
            }
            // more outputs here...
        }
    }
}
```

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
