# Azure Resource Manager Templates - Best Practices Guide

This document describes the best practices for reviewing and troubleshooting Azure Resource Manager (ARM) Templates, both bicep and JSON, including Azure Applications for the Azure Marketplace. This document is intended to help you design effective templates or troubleshoot existing templates for getting applications certified for the Azure Marketplace and Azure QuickStart templates.  

This repository contains all currently available Azure Resource Manager templates contributed by the community. A searchable template index is maintained at <https://azure.microsoft.com/documentation/templates/>.

To contribute a sample to this repo, you must read and follow these best practices as well as the guidelines listed in the [**Contribution guide**](/1-CONTRIBUTION-GUIDE/README.md#contribution-guide).  

## General Guidelines for ARM Templates  

This section describes guidelines and best practices for clear and accurate templates. Some of these guidelines are suggestions for consistency and accuracy, however, others are required for publishing your templates on Azure. These requirements are called out when applicable.  

### Code Authoring

Ensure that your code is properly formatted.  For working with Azure Resource Manager Templates, Visual Studio Code is a free editor that has an extension for [bicep](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep) and [JSON](https://marketplace.visualstudio.com/items?itemName=msazurermtools.azurerm-vscode-tools) designed to help author templates.

### Sample Application Files

An Azure Application or QuickStart sample must contain, at a minimum, the following files:

| Artifact       | Azure Marketplace file         | Azure QuickStarts file |
|:---------------------------------------- |:----------------------------------------------------- |:---------------------------------------- |
| UI Definition File    | **createUiDefinition.json** | [optional] |  
| Template File | **mainTemplate.json** | **main.bicep** or **azuredeploy.json** |  
| Parameters File (Public) | n/a | **azuredeploy.parameters.json**  |  
| Parameters File (US Gov) | n/a | **azuredeploy.parameters.us.json** |
| Read Me File | Not required | **README.md** |  
| QuickStart Metadata | n/a | **metadata.json** |
| Nested templates | In a **nestedtemplates** subfolder | In a **nestedtemplates** subfolder for **JSON** or a **modules** folder for **bicep** |  
| Configuration Scripts | In a **scripts** subfolder | In a **scripts** subfolder |  

## Parameters

Parameters should be used for collecting input to customize the deployment.  Avoid adding too many parameters to a template as each parameter creates more opportunity for errors.  Additionally, many properties values can be intuitively assigned by using relationships between resources or understanding the nature of the workload.  For example the name of a `virtualMachine` may be determined by it's role in a workload.  The `networkInterfaces` assigned to the VM can be prefixed with the name of the VM.

Some examples of property values that should be parameterized, unless otherwise noted defaultValues may be used to recommend or simplify the deployment.

* credentials - **usernames, passwords, secrets** should always be parameterized and never use defaultValues
* **endpoints** or **prefixes**, particularly any endpoint consumed by humans (as opposed to automation)
* **SKUs** or **sizes** that affect availability in a cloud or region and the cost and performance of a workload
* resource **locations** except for samples that contain resources that do not require a location - multiple location parameters may be used where appropriate

Other requirements for parameters:

* All parameters should have a description (see sample below)
* Use constraints where possible, allowed values, min/max
* Templates must have a parameter named `location` for the primary location of resources.
  * The default value of this parameter must be `[resourceGroup().location]`
  * The location parameter must not contain `allowedValues`, as these will not be applicable to all clouds
* For resources that are not available in all locations, use a separate parameter for the location of these resources.
* Use additional location parameters for applications that are multi-region and selected by the user.
* Do NOT use allowedValues for list of things that are meant to be inclusive (e.g. all VM SKUs) only for exclusive scenarios.  Over using allowedValues will block deployment in some scenarios and create a maintenance issue when the inclusion list changes.
* Use defaultValues whenever possible – this creates a simpler and flexible deployment experience.  Default values are not required for modules or nested templates.
* Any `defaultValue` supplied for a parameter must be valid for all users in the default deployment configuration.
  * Do not provide default values for user names, passwords (or any secure parameter) or anything that will increase the attack surface area of the application
  * Template expressions can be used to create default values, as shown in the following example:

```bicep
@description('Name of the storageAccount')
param storageAccountName string = 'storage${uniqueString(resourceGroup().id)}'

@description('Number of VMs')
@min(2)
@max(8)
param vmCount int = 2
```

```json
    "storageAccountName": {
      "type": "string",
      "defaultValue": "[concat('storage', uniqueString(resourceGroup().id))]",
      "metadata": {
        "description": "Name of the storage account"
      }
    },
    "vmCount": {
      "type": "int",
      "defaultValue": 2,
      "minValue": 2,
      "maxValue": 8,
      "metadata": {
        "description": "Name of the storage account"
      }
    }
```

## Variables

* Use variables for values that are used multiple times throughout a template or for creating **complex** expressions.
* Variables must not be used for apiVersions.  The apiVersion affects the shape of the resource and often cannot be updated without updating all the resources that use a particular version.
* Use a loop for creating repeating patterns in variables.
* Remove all unused variables from all templates.
* Avoid concatenating variable names for conditional scenarios – use template language expressions and dictionary objects. For more information, see [https://docs.microsoft.com/azure/azure-resource-manager/resource-group-template-functions](https://docs.microsoft.com/azure/azure-resource-manager/resource-group-template-functions)

## Naming Parameters & Variables

Parameters and variables should be named according to their use on specific properties where applicable.  For example a parameter used for the name property on a storageAccount would be named `storageAccountName` rather than simple `name` or `storageAccount`.  A parameter used for the size of a VM should be `vmSize` rather than `size`.  As well, parameters, variables and outputs that related to a specific resource should use the resource's symbolic name a a prefix.

camelCase should be used for naming of symbols (parameters, variables, resources, outputs, etc.).

## Resources  

All resources share a common set of properties and as such these guidelines will apply to all resources in an application.  

### Sort Order of Properties  

 Although, not required by the platform, a consistent sort order of properties and elements in a template creates the ideal experience for reasoning over templates in the Azure ecosystem.   For example, parameters define the input contract for a deployment and should be at the top of the template.  Outputs are the outgoing contract and should be collected at the end of a file.  Additionally, it is easier to find an element when templates are authored using a consistent pattern.

Top-level template properties must be in the following order:

```bicep
targetScope '...'
metadata '...'
param '...'
var '...'
resource // (existing resources collected together)
resource/module // (new resources)
output '...'
```

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

It is recommended that the resources be sorted by deployment order (as applicable) to convey the intent of the orchestration.

Within resources, the common properties should be authored consistently to provide for understandability and consumption of the code.  
**Note:** Any other properties not listed here should be placed before the properties object for the resource.

```bicep
@description
@batchSize
resource foo
  parent
  scope
  name
  location/extendedLocation
  zones
  sku
  kind
  scale
  plan
  identity
  dependsOn
  tags
  properties
```

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
    }
]
```

### Empty and Null Properties

All empty or null properties that are not required should be excluded from the template samples.  This includes empty objects {}, arrays [], strings "", and any property that has a null value.  The exceptions to this rule are the top-level JSON template properties: parameters, variables, functions, resources and outputs.

### dependsOn  

Deployment sequence dependencies can be specified by using the dependsOn property.  Dependencies are only allowed for resources that are deployed within the same template. They are not needed for existing resources, and for nested deployments or modules, the dependency is created on the deployment resource or module itself.
The value of a dependency in JSON is simply the name of a resource or copy loop.  In bicep it is the symbolic reference to the resource.

```bicep
    dependsOn: [
        storageAccount
    ]
```

```json
        "dependsOn": [
        "nicLoop",
        "[parameters('sqlServerName')]"
      ],
```  

A full `resourceId` can also be used for the dependency in JSON but is only necessary when two or more resources share the same name (which should be avoided).  

Conditional resources are automatically removed from the dependency graph when not deployed.  Authoring these dependencies can be done as if the resource will always be deployed.  

### resourceIds

Resource IDs must use the symbolic reference e.g. `storageAccount.id` when possible otherwise the `resourceId()` must be used.  The following code shows an example:  

```bicep
  properties: {
    subnet: {
      id: subnet.id
    }
  }      
```

```json
"properties": {
    "subnet": {
        "id": "[resourceId(parameters('virtualNetworkResourceGroupName'), 'Microsoft.Network/virtualNetworks/subnets/', parameters('virtualNetworkName'), parameters('subnetName'))]"
    }
}
```  

### Referencing Resource and Environment Properties

Any reference to a property of a resource must be done using the `reference()` function in JSON.  In bicep, resource properties may be referenced using the property name on the symbolic name of the resource, e.g. `managedIdentity.properties.principalId`.  Hard-coding values may cause failures when templates are used in other subscriptions, tenants or clouds, or when changes are made in the original cloud.  Environment properties, such as service endpoints can be retrieved using the `environment()` function.  

Some examples:

* Endpoints or URIs for an Azure resource (storage, web, publicIp)
* Virtual Network IP address information for subnets, load balancers, or gateways
* Account keys
* Public endpoints, such as a blob storage public endpoint, should use `reference()` or a symbolic reference to retrieve the namespace dynamically.
* Disks used for virtual machines (VMs) should use managed disks for the OS and data disks.  For boot diagnostics, the `storageUri` must be retrieved using a reference. The following example shows how to use the reference function for the `storageUri`.

```bicep
diagnosticsProfile: {
  bootDiagnostics: {
    enabled: true,
      storageUri: diagStorageAccount.properties.primaryEndpoints['blob']
      }
}

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

* All resources should use the `parameters('location')` expression for the `location` property for all resources.  Other expressions may be used for resources that need to be placed in alternate locations, for example a geo-redundant application.  Location values should not be hard-coded or use `resourceGroup().location` directly for the location property.  Required parameter definition:

```bicep
@description('Location for all resources')
param location string = resourceGroup().location
```

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

```bicep
hostNames: [
  '${webJobName}.azurewebsites.net'
]
```

```json
"hostNames": [
  "[concat(parameters('webjobName'),'.azurewebsites.net')]"
],
```

Rather. the `environment()` function should be used to retrieve the endpoint information.  If the endpoint information is not provided in the `environment()` function, a parameter should be used to provide the value.

## Deployment Artifacts (Nested Templates, Scripts)

Deployment artifacts are any files, in addition to the mainTemplate.json/azuredeploy.json/main.bicep and createUIDefinition.json files that are needed to complete a deployment.  For example, JSON nested templates, configuration scripts or zip files.  The following guidelines should be used when creating a solution with deployment artifacts:

* **mainTemplate.json/azuredeploy.json/main.bicep** and **createUIDefinition.json** must be in the root of the folder.
* Additional artifacts should also be stored in subfolders.  
  * Additional templates should be stored in the **nestedtemplates** folder for JSON or the **modules** folder for bicep.
  * Scripts should be stored in the **scripts** folder.  
* You do not have to use the folder names prescribed above, if a more appropriate or descriptive name is appropriate.  Just don't put everything in the root.

NOTE: if your application uses the CustomScript extension for Windows – place configuration scripts and other artifacts in the **/** (root) folder rather than the **/scripts** subfolder.  

When samples contain scripts, templates or other artifacts that need to be made available during deployment, you will need to stage those artifacts to enable a consistent deployment experience throughout the development and test lifecycle, including command line deployment with the scripts provided at the root of the repository.  
To do this you must define two standard parameters:

* **_artifactsLocation** - The base URI where all artifacts for the deployment will be staged.  The `defaultValue` must be specified as shown below and include a trailing slash when providing a value for the parameter.
* **_artifactsLocationSasToken** - The sasToken required to access _artifactsLocation. The default value should be an empty string "" for scenarios where the `_artifactsLocation` is not secured, such as the raw GitHub URI for a public repo. The following code shows an example:

```bicep
@description('The base URI where artifacts required by this template are located including a trailing \'/\'')
param _artifactsLocation string = deployment().properties.templateLink.uri

@secure()
@description('The sasToken required to access _artifactsLocation.  When the template is deployed using the accompanying scripts, a sasToken will be automatically generated. Use the defaultValue if the staging location is not secured.')
param _artifactsLocationSasToken string = ''
```

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

After the parameters are added to the template all URIs must be created using the `uri()` function.

```bicep
var scriptFileUri = uri(_artifactsLocation, 'scripts/configuration.sh${_artifactsLocationSasToken}')
```

```json
"variables": {
        "scriptFileUri": "[uri(parameters('_artifactsLocation'), concat('scripts/configuration.sh', parameters('_artifactsLocationSasToken')))]",
        "nestedtemplateUri": "[uri(parameters('_artifactsLocation'), concat('nestedtemplates/jumpbox.json', parameters('_artifactsLocationSasToken')))]"
    },
```

## VM Image References & Disks

* All `imageReference` objects for virtual machines or virtual machine scale sets must use images that are available in the Azure Marketplace, or core platform images. Custom images cannot be used.  
* An imageReference using an image from the Azure Marketplace cannot be a preview or staged version of the image in production deployments.  
* An imageReference using an image from the Azure Marketplace must also include information about the image in the plan properties of the virtual machine object.  

The following code provides an example:

```bicep
resource windowsVM 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: 'name'
  location: location
  plan: {
    name: 'ContosoSKU'
    publisher: 'Contoso'
    product: 'ContosoProduct'
  }
  properties: {
    storageProfile: {
      imageReference: {
        publisher: 'Contoso'
        offer: 'ContosoProduct'
        sku: 'ContosoSKU'
        version: 'latest'
      }
    }
  ...
}

```

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

### VM Disks

* OS Disks and Data Disks must use implicit managed disks except for QuickStart samples showing the use of explicit disks.  An explicit disk is a disk where the resource is explicitly defined in the template.

```bicep
osDisk: {
  name: 'nameIsOptional'
  caching: 'ReadWrite'
  createOption: 'FromImage'
}
dataDisks: [
  {
    name: 'optional'
    diskSizeGB: sizeOfDiskInGB
    lun: 0
    createOption: 'Empty'
  }
]
```

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

Outputs are recommended for any information that will enable easy use of a sample, for example endpoints, ip addresses, etc.  Secrets (passwords, account keys) should never be used in an output as the outputs from a deployment may available to users with read-only access.
