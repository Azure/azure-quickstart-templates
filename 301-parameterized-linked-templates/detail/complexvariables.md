# Using Variables to Centralize Configurable Elements

The variables section in this sample's [azuredeploy.json](../azuredeploy.json#L192-L341) is used mostly to create lookup tables that are used to alter the deployment configuration based on the user's selections.  Several examples are described below.

The variable `AvailabilitySetFaultDomain` is used to allow selection of the number of fault domains for Availability Sets based on the maximum number for the deployment region:
```
"AvailabilitySetFaultDomain": {
  "eastus": 3,
  "eastus2": 3,
  ...
  "GermanyNorth": 2,
  "NorwayWest": 2
},
"maxFaultDomainsforLocation": "[if(contains(variables('AvailabilitySetFaultDomain'),parameters('location')),variables('AvailabilitySetFaultDomain')[parameters('location')],2)]",
```
```
"properties": {
  "platformFaultDomainCount": "[variables('maxFaultDomainsforLocation')]",
  "platformUpdateDomainCount": 6
},
```

The variable `storageProfile` provides a simple lookup table to match the number of data disks to attach to a given VM size:

``` 
"storageProfile": {
  "Standard_D2s_v3": 1,
  "Standard_D4s_v3": 1,
  "Standard_D8s_v3": 2,
  "Standard_D16s_v3": 4,
  "Standard_D32s_v3": 8
},
```

The parameter `Midtier VM Size` is used as a key to select a value from the variable:

```
"datadisk_count": {
    "value": "[variables('storageProfile')[parameters('Midtier VM Size')]]"
},
```

In the example below, you can see that there are entire objects defined under `postInstallActions` in order to be able to pass them as a chunk to linked templates.

```
"postInstallActions": {
  "backend": {
    "commandToExecute": "[concat('sh ',variables('osProfile')[variables('ostag')]['diskscript'],'; sh examplepostinstall1.sh; sh examplepostinstall2.sh')]",
    "fileUris": [
      "[uri(parameters('_artifactsLocation'), concat(variables('osProfile')[variables('ostag')]['diskscript'], parameters('_artifactsLocationSasToken')))]",
      "[uri(parameters('_artifactsLocation'), concat('scripts/examplepostinstall1.sh', parameters('_artifactsLocationSasToken')))]",
      "[uri(parameters('_artifactsLocation'), concat('scripts/examplepostinstall2.sh', parameters('_artifactsLocationSasToken')))]"
    ]
  },
  "midtier": {
    "commandToExecute": "[concat('sh ',variables('osProfile')[variables('ostag')]['diskscript'],'; sh examplepostinstall1.sh')]",
    "fileUris": [
      "[uri(parameters('_artifactsLocation'), concat(variables('osProfile')[variables('ostag')]['diskscript'], parameters('_artifactsLocationSasToken')))]",
      "[uri(parameters('_artifactsLocation'), concat('scripts/examplepostinstall1.sh', parameters('_artifactsLocationSasToken')))]"
    ]
  },
  "jump": {
    "commandToExecute": "[concat('sh ',variables('osProfile')[variables('ostag')]['diskscript'],'; sh examplepostinstall3.sh')]",
    "fileUris": [
      "[uri(parameters('_artifactsLocation'), concat(variables('osProfile')[variables('ostag')]['diskscript'], parameters('_artifactsLocationSasToken')))]",
      "[uri(parameters('_artifactsLocation'), concat('scripts/examplepostinstall3.sh', parameters('_artifactsLocationSasToken')))]"
    ]
  }
}
```

This allows us to pass a set of properties to the linked template based on the type of node that we are provisioning:

```
"post_install_actions": {
  "value": "[variables('postInstallActions')['midtier']]"
},
```

In another instance we end up needing to append a value based on the output of a preceding nested deployment.  You can see here that we are able to use the subelements of the `jump` node, and reconstruct the object with the appended value:

```
"post_install_actions": {
  "value": {
    "commandToExecute": "[concat(variables('postInstallActions')['jump'].commandToExecute,' ', string(reference('ParameterizedBackendVM-Loop').outputs.backendIp.value))]",
    "fileUris": "[variables('postInstallActions')['jump'].fileUris]"
  }
},
```

[Home](../README.md)