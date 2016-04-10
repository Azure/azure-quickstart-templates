# Azure Resource Manager QuickStart Templates

This repo contains all currently available Azure Resource Manager templates contributed by the community. A searchable template index is maintained at https://azure.microsoft.com/en-us/documentation/templates/.
The following information is relevant to get started with contributing to this repository.

+ [**Contribution guide**](/1-CONTRIBUTION-GUIDE/README.md). Describes the minimal guidelines for contributing.
+ [**Best practices**](/1-CONTRIBUTION-GUIDE/best-practices.md). Best practices for improving the quality of your template design.
+ [**Git tutorial**](/1-CONTRIBUTION-GUIDE/git-tutorial.md). Step by step to get you started with Git.

You are currently reading the contribution guide.

## Contribution guide

To make sure your template is added to Azure.com index, please follow these guidelines. Any templates that are out of compliance will be added to the **blacklist** and not be indexed on Azure.com

## Files, folders and naming conventions

1. Every deployment template and its associated files must be contained in its own **folder**. Name this folder something that describes what your template does. Usually this naming pattern looks like **appName-osName** or **level-platformCapability** (e.g. 101-vm-user-image) 
 + **Required** – Numbering should start at 101. 100 is reserved for things that need to be at the top.
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
+ Description of what the template will deploy
+ Tags, that can be used for seach. Specify the tags comma seperated and enclosed between two back-ticks (e.g Tags: `cluster, ha, sql`)
+ *Optional: Prerequisites
+ *Optional: Description on how to use the application
+ *Optional: Notes

Do **not include** the **parameters or the variables** of the deployment script. We render this on Azure.com from the template. Specifying these in the README.md will result in **duplicate entries** on Azure.com.

## metadata.json

A valid metedata.json must adhere to the following structure

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

We are in the process of activating automated template validation through Travis CI. These builds can be accessed by clicking the 'Details' link at the bottom of the pull-request dialog. This process will ensure that your template conforms to all the rules mentioned above and will also deploy your template to our test azure subscription.

### Parameters File Placeholders

To ensure your template passes, special placeholder values are required when deploying a template, depending what the parameter is used for:

+ **GEN-UNIQUE** - use this placeholder for new storage account names, domain names for public ips and other fields that need a unique name. The value will always be alpha numeric value with a length of 18 characters.
+ **GEN-UNIQUE-[N]** - use this placeholder for new storage account names, domain names for public ips and other fields that need a unique name. The value will always be alpha numeric value with a length of `[N]`, where `[N]` can be any number from 3 to 32 inclusive.
+ **GEN-SSH-PUB-KEY** - use this placeholder if you need an SSH public key
+ **GEN-PASSWORD** - use this placeholder if you need an azure-compatible password for a VM

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