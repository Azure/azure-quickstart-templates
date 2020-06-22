# Naming Parameters to be User Friendly

In the main deployment template, conventionally named azuredeploy.json, you can define parameters that will be used to prompt the user for configuration at the beginning of the deployment.  These selections can be used to alter the number or type of resources that will be deployed.

#### Naming Parameters for top-level parameters

The text of the parameter names will be displayed as-is to the user.  You can include whole words and spaces in order to make the parameter's purpose clear:
```
"parameters": {
  "Deploy Azure Bastion Frontend": {
    "defaultValue": "Yes",
    "type": "String",
    "allowedValues": [
      "No",
      "Yes"
    ]
  }
}
```
When using parameters with complex names, the only trick is that you have to use the full string of the name when accessing the values later in the template:

```
"condition": "[equals(parameters('Deploy Azure Bastion Frontend'), 'Yes')]"
```

Similarly, you can use descriptive strings in the `allowedValues` field:

```
"allowedValues": [
  "Standard_D8s_v3 2xP10 (256MB/node)",
  "Standard_D8s_v3 1xP30 (1024MB/node)",
  "Standard_D16s_v3 4xP10 (512MB/node)",
  "Standard_D16s_v3 2xP30 (2048MB/node)",
  "Standard_D32s_v3 8xP10 (1024MB/node)",
  "Standard_D32s_v3 4xP30 (4096MB/node)",
  "Standard_D48s_v3 12xP10 (1536MB/node)",
  "Standard_D48s_v3 6xP30 (6144MB/node)",
  "Standard_D64s_v3 12xP10 (1536MB/node)",
  "Standard_D64s_v3 6xP30 (6144MB/node)"
]
```
In this example, a full text description is used to let the user know exactly what configuration their backend VMs will have.  This selection is later used as the key to lookup specific configuration elements from a variable:

```
"storageProfileAdvanced": {
  "Standard_D8s_v3 2xP10 (256MB/node)": {
      "disksize": 128,
      "vmsize": "Standard_D8s_v3",
      "diskcount": 2
  },
  "Standard_D8s_v3 1xP30 (1024MB/node)": {
      "disksize": 1024,
      "vmsize": "Standard_D8s_v3",
      "diskcount": 1
  },
  "Standard_D16s_v3 4xP10 (512MB/node)": {
      "disksize": 128,
      "vmsize": "Standard_D16s_v3",
      "diskcount": 4
  },
  "Standard_D16s_v3 2xP30 (2048MB/node)": {
      "disksize": 1024,
      "vmsize": "Standard_D16s_v3",
      "diskcount": 2
  },
  "Standard_D32s_v3 8xP10 (1024MB/node)": {
      "disksize": 128,
      "vmsize": "Standard_D32s_v3",
      "diskcount": 8
  },
  "Standard_D32s_v3 4xP30 (4096MB/node)": {
      "disksize": 1024,
      "vmsize": "Standard_D32s_v3",
      "diskcount": 4
  },
  "Standard_D48s_v3 12xP10 (1536MB/node)": {
      "disksize": 128,
      "vmsize": "Standard_D48s_v3",
      "diskcount": 12
  },
  "Standard_D48s_v3 6xP30 (6144MB/node)": {
      "disksize": 1024,
      "vmsize": "Standard_D48s_v3",
      "diskcount": 6
  },
  "Standard_D64s_v3 12xP10 (1536MB/node)": {
      "disksize": 128,
      "vmsize": "Standard_D64s_v3",
      "diskcount": 12
  },
  "Standard_D64s_v3 6xP30 (6144MB/node)": {
      "disksize": 1024,
      "vmsize": "Standard_D64s_v3",
      "diskcount": 6
  }
}
```

There are many more examples in [azuredeploy.json](../azuredeploy.json#L4-L176).


[Home](../README.md)