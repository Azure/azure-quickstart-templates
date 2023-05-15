# Using Variables to Centralize Configurable Elements

The variables section in this sample's [azuredeploy.json#L190-L311](../azuredeploy.json#L190-L311) is used mostly to create lookup tables that are used to alter the deployment configuration based on the user's selections.  Several examples are described below.

The variables `AvailabilitySetFaultDomain` and `maxFaultDomainsforLocation` are used to allow selection of the number of fault domains for Availability Sets based on the maximum number for the deployment region: [azuredeploy.json#L191-L206](../azuredeploy.json#L191-L206).  The variable `maxFaultDomainsforLocation` is used later in creation of the Availability Sets: [azuredeploy.json#L334](../azuredeploy.json#L334), [azuredeploy.json#L354](../azuredeploy.json#L354).

The variable `storageProfileSimple` provides a simple lookup table to match the number of data disks to attach to a given VM size: [azuredeploy.json#L207-L213](../azuredeploy.json#L207-L213).

The parameter `MidtierVMSize` is used as a key to select a value from the variable: [azuredeploy.json#L765-L767](../azuredeploy.json#L765-L767)

There are entire objects defined under `postInstallActions` in order to be able to pass them as a chunk to linked templates: [azuredeploy.json#L287-L310](../azuredeploy.json#L287-L310). This allows us to pass a set of properties to the linked template based on the type of node that we are provisioning: [azuredeploy.json#L786-L788](../azuredeploy.json#L786-L788).

In another instance we end up needing to append a value based on the output of a preceding nested deployment.  You can see here that we are able to use the subelements of the `jump` node, and reconstruct the object with the appended value: [azuredeploy.json#L855-L860](../azuredeploy.json#L855-L860).

[Home](../README.md)
