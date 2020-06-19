# Use Linked Template for Multiple Resources (IaaS)

The template [paramvm.json](../nested/paramvm.json) encapsulates some common parameters that are used for all Virtual Machines that are part of this deployment.  By limiting the parameters to things that change from VM to VM, and collecting dependent resources like Disks and the NIC into a single template, the main deployment json can focus on the parameters that need to be different.

The template is referenced three different times in [azuredeploy.json](../azuredeploy.json).

For the frontend jump VM, it is used as a single instance and many values are hardcoded ([azuredeploy.json](../azuredeploy.json#L782)):

```
{
  "type": "Microsoft.Resources/deployments",
  "apiVersion": "2019-10-01",
  "name": "ParameterizedJumpVM",
  "condition": "[equals(parameters('Deploy Jump Box Frontend'), 'Yes')]",
  ...
  "properties": {
    "mode": "Incremental",
    "templateLink": {
      "uri": "[uri(deployment().properties.templateLink.uri, 'nested/paramvm.json')]"
    },
```

For the midtier VM set, the linked template is used in a simple copy loop.  Note that `availabilityset_id_or_empty` is only populated if the count of VMs for this tier is greater than 1 ([azuredeploy.json](../azuredeploy.json#L712)):

```
{
  "type": "Microsoft.Resources/deployments",
  "apiVersion": "2019-10-01",
  "name": "[concat('ParameterizedMidtierVM-', copyIndex())]",
  ...
  "properties": {
    "mode": "Incremental",
    "templateLink": {
      "uri": "[uri(deployment().properties.templateLink.uri, 'nested/paramvm.json')]"
    },
    "parameters": {
      "location": {
        "value": "[resourceGroup().location]"
      },
      "vm_name": {
        "value": "[concat(parameters('Midtier VM Name Base'),'-', copyIndex())]"
      },
      "vm_size": {
        "value": "[parameters('Midtier VM Size')]"
      },
      ...
      "availabilityset_id_or_empty": {
        "value": "[if(greater(parameters('Midtier VM Count'),1),concat(parameters('Midtier VM Name Base'),'-AS'),'')]"
      }
    }
  },
  "copy": {
    "name": "ParameterizedMidtierVM-Copy",
    "count": "[parameters('Midtier VM Count')]"
  }
},
```

For the backend VM set, the linked template is inside a copy loop that is wrapped in a nested template.  This is done so that the outputs from the linked template can be gathered into an array that is used later in the deployment of the Jump VM. The expressionEvaluationOptions scope is set to "inner", so any variables or parameters that need to be visible in the inner copy loop have to be passed in as parameters. ([azuredeploy.json](../azuredeploy.json#L527)):

```
{
  "type": "Microsoft.Resources/deployments",
  "apiVersion": "2019-10-01",
  "name": "ParameterizedBackendVM-Loop",
  ...
  "properties": {
    "mode": "Incremental",
    "expressionEvaluationOptions": {
        "scope": "inner"
    },
    "parameters": {
      "templateUri": {
        "value": "[uri(deployment().properties.templateLink.uri, 'nested/paramvm.json')]"
      },
      "Backend VM Template": {
        "value": "[parameters('Backend VM Template')]"
      },
      ...
      "postInstallActions": {
        "value": "[variables('postInstallActions')]"
      },
      "availabilityset_id_or_empty": {
        "value": "[if(greater(parameters('Backend VM Count'),1),concat(parameters('Backend VM Name Base'),'-AS'),'')]"
      },
      "loadbalancer_id_or_empty": {
        "value": "[if(equals(parameters('Deploy App Gateway Frontend'),'Yes'),concat(resourceId('Microsoft.Network/applicationGateways','frontend-loadbalancer'),'/backendAddressPools/default-backend'),'')]"
      }
    },
    "template": {
      "$schema": "https://schema.management.azure.com/schemas/2019-08-01/deploymentTemplate.json#",
      "contentVersion": "1.0.0.0",
      "parameters": {
        "templateUri": {
          "type": "string"
        },
        "Backend VM Template": {
          "type": "string"
        },
        "Backend VM Name Base": {
          "type": "string"
        },
        ...
        "postInstallActions": {
          "type": "object"
        },
        "availabilityset_id_or_empty": {
          "type": "string"
        },
        "loadbalancer_id_or_empty": {
          "type": "string"
        }
      },
      "resources": [
        {
          "type": "Microsoft.Resources/deployments",
          "apiVersion": "2019-10-01",
          "name": "[concat('ParameterizedBackendVM-', copyIndex())]",
          "properties": {
            "mode": "Incremental",
            "templateLink": {
              "uri": "[parameters('templateUri')]"
            },
            "parameters": {
              ...
              "vm_size": {
                "value": "[parameters('storageProfileAdvanced')[parameters('Backend VM Template')]['vmsize']]"
              },
              "datadisk_size": {
                "value": "[parameters('storageProfileAdvanced')[parameters('Backend VM Template')]['disksize']]"
              },
              "datadisk_count": {
                "value": "[parameters('storageProfileAdvanced')[parameters('Backend VM Template')]['diskcount']]"
              },
              ...
              "post_install_actions": {
                "value": "[parameters('postInstallActions')['backend']]"
              },
              "enable_enhanced_networking": {
                "value": true
              },
              ...
              "loadbalancer_id_or_empty": {
                "value": "[parameters('loadbalancer_id_or_empty')]"
              },
              "availabilityset_id_or_empty": {
                "value": "[parameters('availabilityset_id_or_empty')]"
              }
            }
          },
          "copy": {
            "name": "ParameterizedBackendVM-Copy",
            "count": "[parameters('Backend VM Count')]"
          }
        }
      ],
      "outputs": {
        "backendIp": {
          "type": "array",
          "copy": {
            "count": "[parameters('Backend VM Count')]",
            "input": "[reference(concat('ParameterizedBackendVM-', copyIndex())).outputs.privateIp.value]"
          }
        }
      }
    }
  }
},
```

Most parameters are required.  There are some parameters that are named with the pattern `*_or_empty`:

```
"public_ip_or_empty": {
  "type": "string",
  "defaultValue": ""
},
"loadbalancer_id_or_empty": {
  "type": "string",
  "defaultValue": ""
},
"availabilityset_id_or_empty": {
  "type": "string",
  "defaultValue": ""
},
```

This pattern is used for parameters that require a subobject when present, but which should otherwise be not specified or empty.  It would be possible to pass these parameters as objects, but that would add complexity to the main template.

Variables are used to define the objects that will be used if the parameter is not empty:

```
"public_ip_if_not_empty": {
  "id": "[parameters('public_ip_or_empty')]"
},
"loadbalancer_if_not_empty": [
  {
    "id": "[parameters('loadbalancer_id_or_empty')]"
  }
],
"availabilityset_if_not_empty": {
  "id": "[resourceId('Microsoft.Compute/availabilitySets',parameters('availabilityset_id_or_empty'))]"
}
```

You can see above that the loadbalancer needs to be specified as an object with an `id` property inside of an array, since multiple values are allowed.  The Public IP and Availability Set are simple objects with an `id` parameter.

Use of Public IP parameter for the Network Interface:
```
"publicIPAddress": "[if(empty(parameters('public_ip_or_empty')),json('null'),variables('public_ip_if_not_empty'))]"
```

Use of Loadbalancer parameter for the Network Interface:
```
"applicationGatewayBackendAddressPools": "[if(empty(parameters('loadbalancer_id_or_empty')),json('[]'),variables('loadbalancer_if_not_empty'))]",
```

Use of Availability Set parameter for the VM:
```
"availabilitySet": "[if(empty(parameters('availabilityset_id_or_empty')), json('null'), variables('availabilityset_if_not_empty'))]",
```

In order to make use of the parameter that specifies the number of data disks, a copy loop is used inside the Virtual Machine's `storageProfile`:

```
"copy": [
  {
    "name": "datadisks",
    "count": "[parameters('datadisk_count')]",
    "input": {
      "lun": "[copyIndex('datadisks')]",
      "name": "[concat(parameters('vm_name'), '_data_', copyIndex('datadisks'))]",
      "managedDisk": {
        "storageAccountType": "Premium_LRS"
      },
      "diskSizeGB": "[parameters('datadisk_size')]",
      "caching": "None",
      "createOption": "Empty"
    }
  }
]
```

[Home](../README.md)