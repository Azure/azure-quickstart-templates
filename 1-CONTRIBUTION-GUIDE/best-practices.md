# Azure Resource Manager Templates - Best Practices Guide

This document describes the best practices for reviewing and troubleshooting Azure Resource Manager (ARM) Templates, including Azure Applications for the Azure Marketplaces. This document is intended to help you design effective templates or troubleshoot existing templates for getting applications certified for the Azure Marketplace and Azure QuickStart templates.  

This repository contains all currently available Azure Resource Manager templates contributed by the community. A searchable template index is maintained at <https://azure.microsoft.com/en-us/documentation/templates/>.

To contribute a sample to this repo, you must read and follow these best practices as well as the guidelines listed in the [**Contribution guide**](/1-CONTRIBUTION-GUIDE/README.md#contribution-guide).  

This guide is divided into the following sections:

* General guidelines for ARM Templates
* Parameters
* Variables
* Resources
* Outputs  
* Nested Templates  
* Objects

## General Guidelines for ARM Templates  

This section describes guidelines and best practices for clear and accurate ARM Templates. Some of these guidelines are suggestions for consistency and accuracy, however, others are required for publishing your templates on Azure. These requirements are called out when applicable.  

### JSON Authoring

* Ensure that your JSON is properly formatted.  You can use any number of JSON linters available on the internet or simply use a code editor that works with JSON files.  For working with Azure Resource Manager Templates, Visual Studio Code is a free editor that has an [extension](https://marketplace.visualstudio.com/items?itemName=msazurermtools.azurerm-vscode-tools) designed to help author templates.

### Sample Application Files

An Azure Application or QuickStart sample must contain, at a minimum, the following files:

| Artifact       | Azure Marketplace file         | Azure QuickStarts file |
|:---------------------------------------- |:----------------------------------------------------- |:---------------------------------------- |
| UI Definition File    | createUiDefinition.json | n/a |  
| Template File | mainTemplate.json | azuredeploy.json |  
| Parameters File (Public) | n/a | azuredeploy.parameters.json  |  
| Parameters File (US Gov) | n/a | azuredeploy.parameters.us.json |
| Read Me File | Not required | README.md |  
| [SECURITY.md file](https://help.github.com/en/articles/adding-a-security-policy-to-your-repository) | Not required | SECURITY.md |
| QuickStart Description | n/a | metadata.json |
| Nested templates | In a **nestedtemplates** subfolder | In a **nestedtemplates** subfolder |  
| Configuration Scripts | In a **scripts** subfolder | In a **scripts** subfolder |  

For submissions to the Azure Marketplace, all of the above artifacts must be included in the zip file submitted for publishing.  

Azure QuickStarts or Managed Applications can create any type of resource. For Azure Marketplace applications that create resources for which there is no createUIDefinition element, the application must not prompt for input of any names or properties of these resources that cannot be validated.  For example, SQL Server names must be generated to guarantee uniqueness, but SKUs may be provided as a list of `allowedValues` in a dropdown control.  

A Solution Template should only create or update the following types of resources:

* Compute (Availability Set, Virtual Machines, Extensions, Scale Sets)
* Network (NIC, NSG, Load Balancer, Virtual Networks, Route Tables)
* Storage (Storage Accounts – Premium/Standard, Storage Account Locks)

Other resource types are supported but will require support from the on-boarding team.

## Variables

* Use variables for values that are used multiple times throughout a template or for creating complex expressions.
* Variables must not be used for apiVersions.  The apiVersion affects the shape of the resource and often cannot be updated without updating all the resources that use a particular version.
* Use a copy loop for creating repeating patterns of JSON in variables.
* Remove all unused variables from all templates.
* Avoid concatenating variable names for conditional scenarios – use template language expressions. For more information, see [https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-functions](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-functions)

## Parameters

Parameters should be used for collecting input to customize the deployment.  Values such as username and password (secrets) must always be parameterized.  Other values, such as public endpoints (accessed by humans) or SKUs (that affect the cost of the workload) should be parameterized, but also allow for defaultValues to simplify deployment and provide suggestions to the user appropriate for a given application or workload.

* All parameters should have a description (see sample below)
* Use defaultValues whenever possible – this creates a simpler and flexible deployment experience.  Default values are not required on nested templates.
* Any `defaultValue` supplied for a parameter must be valid for all users in the default deployment configuration.
  * Do not provide default values for user names, passwords (or anything that requires a secureString) or anything that will increase the attack surface area of the application
  * Do not use empty strings as default values (use language expressions to facilitate the scenario)
  * Template expressions can be used to create default values, as shown in the following example:

```json
    "storageAccountName": {
      "type": "string",
      "defaultValue": "[concat('storage', uniqueString(resourceGroup().id))]",
      "metadata": {
        "description": "Name of the storage account"
      }
    }
```

* Templates must have a parameter named `location` for the primary location of resources.
  * The default value of this parameter must be `[resourceGroup().location]`
  * The location parameter must not contain `allowedValues`, as these will not be applicable to all clouds
* For resources that are not available in all locations, use a separate parameter for the location of these resources.
* Use additional location parameters for applications that are multi-region and selected by the user.
* Do NOT use allowedValues for list of things that are meant to be inclusive (e.g. all VM SKUs) only for exclusive scenarios.  Over using allowedValues will block deployment in some scenarios.
  
## Resources  

All resources share a common set of properties and as such these guidelines will apply to all resources in an application.  

### Sort Order of Properties  

Top-level template properties must be in the following order:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/...",
  "contentVersion": "1.0.0.0",
  "apiProfile": "...",
  "parameters": {},
  "functions": {},
  "variables": {},
  "resources": [],
  "outputs": {},
}
```

The common properties should be authored consistently to provide for understandability and consumption of the code.  
**Note:** Any other properties not listed here should be placed before the properties object for the resource.

```json
    "resources": [
        {
            "comments": "if any",
            "condition": true,
            "scope": "% parent scope %",
            "type": "Microsoft.Compute/virtualMachines",
            "apiVersion": "2017-12-01",
            "name": "[concat(parameters('virtualMachineName'), copyIndex(1))]",
            "location": "[parameters('location')]",
            "zones": [],
            "sku": {},
            "kind": "",
            "scale": "",
            "plan": {},
            "identity": {},
            "copy": {
                "name": "vmLoop",
                "count": "[parameters('numberOfVMs')]"
            },
            "dependsOn": [
                "nicLoop"
            ],
            "tags": {},
            "properties": {}
```

### Empty and Null Properties

All empty or null properties that are not required must be excluded from the template samples.  This includes empty objects {}, arrays [], strings "", and any property that has a null value.  The execptions to this rule are the top-level template properties: parameters, variables, functions, resources and outputs.

### dependsOn  

Deployment sequence dependencies can be specified by using the dependsOn property.  Dependencies are only allowed for resources that are deployed within the same template. They are not needed for existing resources, and for nested deployments, the dependency is created on the deployment resource itself.
The value of a dependency is simply the name of a resource or copy loop.

```json
        "dependsOn": [
        "nicLoop",
        "[parameters('sqlServerName')]"
      ],
```  

A full `resourceId` can also be used for the dependency but is only necessary when two or more resources share the same name (which should be avoided).  

Conditional resources are automatically removed from the dependency graph when not deployed.  Authoring these dependencies can be done as if the resource will always be deployed.  

### resourceIds

Resource IDs must be constructed using the `resourceId()` function.  The following code shows an example:  

```json
            "properties": {
                "ipConfigurations": [
                    {
                        "name": "ipconfig1",
                        "properties": {
                            "subnet": {
                                "id": "[resourceId(parameters('virtualNetworkResourceGroupName'), 'Microsoft.Network/virtualNetworks/subnets/', parameters('virtualNetworkName'), parameters('subnetName'))]"
                            },
```  

### Referencing Resource Properties

Any reference to a property of a resource must be done using the `reference()` function.  Hard-coding values will cause failures when templates are used in other clouds, or when changes are made in the original cloud.  

For example:

* Endpoints or URIs for an Azure resource (storage, web, publicIp)
* Virtual Network IP address information for subnets, load balancers, or gateways
* Account keys
* Public endpoints, such as a blob storage public endpoint, should use `reference()` to retrieve the namespace dynamically.
* Disks used for virtual machines (VMs) should use managed disks for the OS and data disks.  For boot diagnostics, the `storageUri` must use the `reference` function to retrieve the URI.  
The following example shows how to use the reference function for the `storageUri`.

```json
"diagnosticsProfile": {
  "bootDiagnostics": {
    "enabled": true,
      "storageUri": "[reference(variables('diagStorageAccountName'), '2017-10-01').primaryEndpoints['blob']]"
      }
}
```

* To reference an existing resource (or one not defined in the same template), a full `resourceId` must be supplied to the `reference()` function:

```json
"diagnosticsProfile": {
  "bootDiagnostics": {
    "enabled": true,
      "storageUri": "[reference(resourceId(parameters('storageAccountResourceGroup'), 'Microsoft.Storage/storageAccounts', variables('diagStorageAccountName')), '2017-10-01').primaryEndpoints['blob']]"
      }
}
```

* Other values in a template configured with a public endpoint, must use the reference function.  

* All resources should use the `parameters('location')` expression for the `location` property for all resources.  Other expressions may be used for resources that need to be placed in alternate locations, for example a geo-redundant application.  Location values must never be hard-coded or use `resourceGroup().location` directly for the location property.  Required parameter definition:

```json
    "location": {
      "type": "string",
      "defaultValue": "[resourceGroup().location]",
      "metadata": {
        "description": "Location for all resources."
      }
    }
```  

* A literal value must not be used for all or part of an endpoint, for example, the following is **never** allowed:

```json
        "hostName": [
          "[concat(parameters('webjobName'),'.azurewebsites.net')]"
        ],
```

### API Versions

* The `apiVersion` specified for a resource type must be the latest version or no more than 12 months old.  A preview `apiVersion` must not be used if a later version (preview or non-preview) is available.
* The `apiVersion` property must be a literal value, expressions are not allowed.  The following code shows an example.

```json
  "resources": [
    {
      "type": "Microsoft.Storage/storageAccounts",
      "name": "[concat(parameters('newStorageAccountPrefix'),'0')]",
      "apiVersion": "2017-10-01",
      "location": "[parameters('location')]",
      "properties": {
        "accountType": "Standard_LRS"
      }
    }
  ]
```

* All `apiVersion` references for each specific resource type must use the same apiVersion.

  To verify the API versions that are supported by a particular `Provider.Namespace/resourceType`, see the [Supported API versions](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-manager-supported-services#supported-api-versions) topic.  

### VM Extensions

* Each VM extension resource must have the autoUpgradeMinorVersion property set to true. The following code shows an example.

```json
"properties": {
      "publisher": "Microsoft.Compute",
      "type": "CustomScriptExtension",
      "typeHandlerVersion": "1.8",
      "autoUpgradeMinorVersion": true,
      "settings": {
      "fileUris": [
          "[uri(parameters('_artifactsLocation'), concat(variables('ScriptFileName'), parameters('_artifactsLocationSasToken')))]"
        ],
      "commandToExecute": "[concat('powershell -ExecutionPolicy Unrestricted -File ', variables('ScriptFolder'), '/', variables('ScriptFileName'))]"
        }
  }
```  

* Passwords must be passed to CustomScript Extensions using the commandToExecute property in protectedSettings. The following code shows an example.

```json
"properties": {
   "publisher": "Microsoft.Azure.Extensions",
   "type": "CustomScript",
   "version": "2.0",
   "autoUpgradeMinorVersion": true,
  "settings": {
    "fileUris": [
      "[concat(variables('template').assets, '/lamp-app/install_lamp.sh')]"
      ]
  },
  "protectedSettings": {
      "commandToExecute": "[concat('sh install_lamp.sh ', parameters('mySqlPassword'))]"
  }
}
```

## Deployment Artifacts (Nested Templates, Scripts)

Deployment artifacts are any files, in addition to the mainTemplate.json/azuredeploy.json and createUIDefinition.json files that are needed to complete a deployment.  For example, nested deployment templates or configuration scripts.  The following guidelines should be used when creating a solution with deployment artifacts:

* **mainTemplate.json** and **createUIDefinition.json** must be in the root of the folder. 
* Additional artifacts should also be stored in subfolders.  
  * Additional templates should be stored in the **nestedtemplates** folder.
  * Scripts should be stored in the **scripts** folder.  
* You do not have to use the folder names prescribed above, if a more appropriate or descriptive name is appropriate.  Just don't put everything in the root.

NOTE: if your application uses the CustomScript extension for Windows – place configuration scripts and other artifacts in the **/** (root) folder rather than the **/scripts** subfolder.  

When samples contain scripts, templates or other artifacts that need to be made available during deployment, you will need to stage those artifacts to enable a consistent deployment experience throughout the development and test lifecycle, including command line deployment with the scripts provided at the root of the repository.  
To do this you must define two standard parameters:

* **_artifactsLocation** - The base URI where all artifacts for the deployment will be staged.  The `defaultValue` must be specified as shown and include a trailing slash when provided during deployment.
* **_artifactsLocationSasToken** - The sasToken required to access _artifactsLocation. The default value should be an empty string "" for scenarios where the `_artifactsLocation` is not secured, such as the raw GitHub URI for a public repo. The following code shows an example:

```json
  "parameters": {
      "_artifactsLocation": {
          "type": "string",
          "metadata": {
              "description": "The base URI where artifacts required by this template are located including a trailing '/'"
          },
          "defaultValue": "[deployment().properties.templateLink.uri]"
      },
      "_artifactsLocationSasToken": {
          "type": "securestring",
          "metadata": {
              "description": "The sasToken required to access _artifactsLocation.  When the template is deployed using the accompanying scripts, a sasToken will be automatically generated. Use the defaultValue if the staging location is not secured."
          },
          "defaultValue": ""
      }
  },
```

### Creating URIs

After the parameters are added to the template all URIs can be created using the `uri()` function.

```json
"variables": {
        "scriptFileUri": "[uri(parameters('_artifactsLocation'), concat('scripts/configuration.sh', parameters('_artifactsLocationSasToken')))]",
        "nestedtemplateUri": "[uri(parameters('_artifactsLocation'), concat('nestedtemplates/jumpbox.json', parameters('_artifactsLocationSasToken')))]"
    },
```

## VM Image References & Disks

* All `imageReference` objects for virtual machines or virtual machine scale sets must use images that are available in the Azure Marketplace, or core platform images. Custom images cannot be used.  

The following code shows an example of using a core Microsoft Windows Server Datacenter 2012 R2 image:

```json
{
  "apiVersion": "2017-12-01",
  "type": "Microsoft.Compute/virtualMachines",
  "name": "[parameters('vmName')]",
  "location": "[parameters('location')]",
  "properties": {
    "hardwareProfile": {
      "vmSize": "[parameters('vmSize')]"
    },
    "osProfile": {
      "computername": "[parameters('vmName')]",
      "adminUsername": "[parameters('adminUsername')]",
      "adminPassword": "[parameters('adminPassword')]"
    },
    "storageProfile": {
      "imageReference": {
        "publisher": "MicrosoftWindowsServer",
        "offer": "WindowsServer",
        "sku": "2012-R2-Datacenter",
        "version": "latest"
      }
      ...
    }
    ...
  }
}
```

* An imageReference using an image from the Azure Marketplace cannot be a preview or staged version of the image in production deployments.  
* An imageReference using an image from the Azure Marketplace must also include information about the image in the plan properties of the virtual machine object.  

The following code provides an example:

```json
{
  "apiVersion": "2017-12-01",
  "type": "Microsoft.Compute/virtualMachines",
  "name": "[parameters('vmName')]",
  "location": "[parameters('location')]",
  "plan": {
    "name": "ContosoSKU",
    "publisher":"Contoso",
    "product":"ContosoProduct"
  },
  "properties": {
    "hardwareProfile": {
      "vmSize": "[parameters('vmSize')]"
    },
    "osProfile": {
      "computername": "[parameters('vmName')]",
      "adminUsername": "[parameters('adminUsername')]",
      "adminPassword": "[parameters('adminPassword')]"
    },
    "storageProfile": {
      "imageReference": {
      "publisher": "Contoso",
        "offer": "ContosoProduct",
        "sku": "ContosoSKU",
        "version": "latest"
      }
      ...
    }
    ...  
  }
}
```

* If a template contains an `imageReference` using an platform image, the `version` property must be `latest`.  The following code shows an example.

```json
"imageReference": {
  "publisher": "MicrosoftWindowsServer",
  "offer": "WindowsServer",
  "sku": "2016-Datacenter",
  "version": "latest"
}
```

### VM Disks

* OS Disks and Data Disks must use implicit managed disks except for QuickStart samples showing the use of explicit disks.  An explicit disk is a disk where the resource is explicitly defined in the template.

```json
    "osDisk": {
        "caching": "ReadWrite",
        "createOption": "FromImage"
    },
    "dataDisks": [
        {
            "name": "datadisk1",
            "diskSizeGB": "[variables('sizeOfDiskInGB')]",
            "lun": 0,
            "createOption": "Empty"
        }
   ]
```  

## Outputs

## Samples That Require Existing Resources (Pre-reqs)

## Deploying, Testing and Debugging Templates

TODO:

* scripts
* sideload
