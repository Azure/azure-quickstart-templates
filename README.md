# Azure Resource Manager QuickStart Templates

# Template index
A searchable template index is maintained at https://azure.microsoft.com/en-us/documentation/templates/

# Contribution guide

This is a repo that contains all the currently available Azure Resource Manager templates contributed by the community. These templates are indexed on Azure.com and available to view here http://azure.microsoft.com/en-us/documentation/templates/

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
