# Azure Resource Manager QuickStart Templates

# Template index
A searchable template index is maintained at https://azure.microsoft.com/en-us/documentation/templates/

# Contribution guide

This is a repo that contains all the currently available Azure Resource Manager templates contributed by the community. These templates are indexed on Azure.com and available to view here http://azure.microsoft.com/en-us/documentation/templates/

## Adding Your Template

### GitHub Workflow

We're following basic GitHub Flow. If you have ever contributed to an open source project on GitHub, you probably know it already - if you have no idea what we're talking about, check out [GitHub's official guide](https://guides.github.com/introduction/flow/). Here's a quick summary:

 * Fork the repository and clone to your local machine
 * You should already be on the default branch `master` - if not, check it out (`git checkout master`)
 * Create a new branch for your template `git checkout -b my-new-template`)
 * Write your template
 * Stage the changed files for a commit (`git add .`)
 * Commit your files with a *useful* commit message ([example](https://github.com/Azure/azure-quickstart-templates/commit/53699fed9983d4adead63d9182566dec4b8430d4)) (`git commit`)
 * Push your new branch to your GitHub Fork (`git push origin my-new-template`)
 * Visit this repository in GitHub and create a Pull Request.

**For a detailed tutorial, [please check out our tutorial](tutorial/git-tutorial.md)!**

### Azure.com

To make sure your template is added to Azure.com index, please follow these guidelines. Any templates that are out of compliance will be added to the **blacklist** and not be indexed on Azure.com

1. Every template must be contained in its own **folder**. Name this folder something that describes what your template does. Usually this naming pattern looks like **appName-osName** or **level-platformCapability** (e.g. 101-vm-user-image)
  * **Protip** - Try to keep the name of your template folder short so that it fits inside the Github folder name column width.
2. The template file must be named **azuredeploy.json**
3. There should be be a parameters file name **azuredeploy.parameters.json**.
  * Please fill out the values for the parameters according to rules defined in the template (allowed values etc.), For parameters without rules, a simple "changeme" will do as the acomghbot only checks for sytactic correctness using the ARM Validate Template [API](https://msdn.microsoft.com/en-us/library/azure/dn790547.aspx)
4. The template folder must host the **scripts** that are needed for successful template execution
5. The template folder must contain a **metadata.json** file to allow the template to be indexed on [Azure.com](http://azure.microsoft.com)
  *	Guidelines on the metadata file below
6. Include a **Readme.md** file that explains how the template works. No need to include the parameters that the template needs. We can render this on Azure.com from the template.
7. Template parameters should follow **camelCasing**
8. Try to reduce the **number of parameters** a user has to enter to deploy your template. Make things that do not need to be globally unique such as VNETs, NICs, PublicIPs, Subnets, NSGs as variables.
  * If you must include a parameter, please include a default value as well. See the next rule for naming convention for the default values.
9. Name **variables** using this scheme **templateScenarioResourceName** (e.g. simpleLinuxVMVNET, userRoutesNSG, elasticsearchPublicIP etc.) that describe the scenario rather. This ensures when a user browses all the resources in the Portal there aren't a bunch of resources with the same name (e.g. myVNET, myPublicIP, myNSG)
10. **Storage account names** need to be lower case and can't contain hyphens (-) in addition to other domain name restrictions. These also need to be globally unique.
11. Every parameter in the template must have the **lower-case description** tag specified using the metadata property. This looks like below

  ```json
  "newStorageAccountName": {
        "type": "string",
        "metadata": {
            "description": "The name of the new storage account created to store the VMs disks"
        }
  }
  ```


See the starter template [here](https://github.com/Azure/azure-quickstart-templates/tree/master/100-STARTER-TEMPLATE-with-VALIDATION) for more information on passing validation

## Best practices

* It is a good practice to pass your template through a JSON linter to remove extraneous commas, paranthesis, brackets that may break the "Deploy to Azure" experience. Try http://jsonlint.com/ or a linter package for your favorite editing environment (Atom, Sublime Text, Visual Studio etc.)
* It's also a good idea to format your JSON for better readability. You can use a JSON formatter package for your local editor or [format online using this link](https://www.bing.com/search?q=json+formatter).

## metadata.json file

Here are the required parameters for a valid metadata.json file

To be more consistent with the Visual Studio and Gallery experience we're updating the metadata.json file structure. The new structure looks like below

    {
      "itemDisplayName": "",
      "description": "",
      "summary": "",
      "githubUsername": "",
      "dateUpdated": "<e.g. 2015-12-20>"
    }

The metadata.json file will be validated using these rules

**itemDisplayName**
*	Cannot be more than 60 characters

**description**
*	Cannot be more than 1000 characters
*	Cannot contain HTML
* This is used for the template description on the Azure.com index template details page

**summary**
*	Cannot be more than 200 characters
* This is shown for template description on the main Azure.com template index page

**githubUsername**
*	Username must be the same as the username of the author submitting the Pull Request
* This is used to display template author and Github profile pic in the Azure.com index

**dateUpdated**
*	Must be in yyyy-mm-dd format.
*	The date must not be in the future to the date of the pull request

## Starter template

A starter template is provided [here](https://github.com/Azure/azure-quickstart-templates/tree/master/100-starter-template-with-validation) for you to follow

## Common errors from acomghbot

acomghbot is a bot designed to enforce the above rules and check the syntactic correctness of the template using the ARM Validate Template [API](https://msdn.microsoft.com/en-us/library/azure/dn790547.aspx). Below are some of the more cryptic error messages you might receive from the bot and how to solve these issues.

* This error is received when the parameters file contains a parameter that is not defined in the template.

      The file azuredeploy.json is not valid. Response from ARM API: BadRequest - {"error":{"code":"InvalidTemplate","message":"Deployment template validation failed: 'The template parameters 'vmDnsName' are not valid; they are not present in the original template and can therefore not be provided at deployment time. The only supported parameters for this template are 'newStorageAccountName, adminUsername, adminPassword, dnsNameForPublicIP, windowsOSVersion, sizeOfDiskInGB'.'."}}

* This error is received when a parameter in the parameter file has an empty value.

      The file azuredeploy.json is not valid. Response from ARM API: BadRequest - {"error":{"code":"InvalidTemplate","message":"Deployment template validation failed: 'The template resource '' at line '66' and column '6' is not valid. The name property cannot be null or empty'."}}

* This error message is received when a value entered in the parameters file is different from the allowed values defined for the parameter in the tempalte file.

      The file azuredeploy.json is not valid. Response from ARM API: BadRequest - {"error":{"code":"InvalidTemplate","message":"Deployment template validation failed: 'The provided value for the template parameter 'publicIPAddressType' at line '40' and column '29' is not valid.'."}}

## Travis CI

We are in the process of activating automated template validation through Travis CI. These builds can be accessed by clicking the 'Details' link at the bottom of the pull-request dialog. This process will ensure that your template conforms to all the rules mentioned above and will also deploy your template to our test azure subscription.

### Parameters File Placeholders

To ensure your template passes, special placeholder values are required when deploying a template, depending what the parameter is used for:

- **GEN_UNIQUE** - use this placeholder for new storage account names, domain names for public ips and other fields that need a unique name
- **GEN_SSH_PUB_KEY** - use this placeholder if you need an SSH public key
- **GEN_PASSWORD** - use this placeholder if you need an azure-compatible password for a VM
```

Here's an exmaple in an `azuredeploy.parameters.json` file:

```
{
  "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "newStorageAccountName":{
      "value": "GEN_UNIQUE"
    },
    "location": {
      "value": "West US"
    },
    "adminUsername": {
      "value": "sedouard"
    },
    "sshKeyData": {
      "value": "GEN_SSH_PUB_KEY"
    },
    "dnsNameForPublicIP": {
      "value": "GEN_UNIQUE"
    }
  }
}
```

## raw.githubusercontent.com Links

If you're making use of `raw.githubusercontent.com` links within your template contribution (within the template file itself or any scripts in your contribution) please ensure the following:

- Ensure any raw.githubusercontent.com links which refer to content within your pull request points to `https://raw.githubusercontent.com/Azure/azure-quickstart-templates/...' and **NOT** your fork.

- All raw.githubusercontent.com links are placed in your `azuredeploy.json` and you pass the link down into your scripts & linked templates via this top-level template. This ensures we re-link correctly from your pull-request repository and branch.

## Template Pre-requisites

If your template has some pre-requisite such as an Azure Active Directory application or service principal, we don't support this yet. To bypass the CI workflow include a  file called `.ci_skip` in the root of your template folder.

## Failures

If your deployment fails, check the details link of the Travis CI build, scroll to the bottom and the template and template parameters json used will be available for you to debug on your subscription.