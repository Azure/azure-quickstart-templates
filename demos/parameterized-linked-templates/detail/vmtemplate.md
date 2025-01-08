# Use Linked Template for Multiple Resources (IaaS)

The template [paramvm.json](../nested/paramvm.json) encapsulates some common parameters that are used for all Virtual Machines that are part of this deployment.  By limiting the parameters to things that change from VM to VM, and collecting dependent resources like Disks and the NIC into a single template, the main deployment json can focus on the parameters that need to be different.

The template is referenced three different times in [azuredeploy.json](../azuredeploy.json).

For the frontend jump VM, it is used as a single instance and many values are hardcoded: [azuredeploy.json#L805-L875](../azuredeploy.json#L805-L875).

For the midtier VM set, the linked template is used in a simple copy loop.  Note that `availabilityset_id_or_empty` is only populated if the count of VMs for this tier is greater than 1: [azuredeploy.json#L734-L804](../azuredeploy.json#L734-L804).

For the backend VM set, the linked template is inside a copy loop that is wrapped in a nested template.  This is done so that the outputs from the linked template can be gathered into an array that is used later in the deployment of the Jump VM. The expressionEvaluationOptions scope is set to "inner", so any variables or parameters that need to be visible in the inner copy loop have to be passed in as parameters: [azuredeploy.json#L542-L733](../azuredeploy.json#L542-L733).

All parameters are required.  There are some parameters that are named with the pattern `*_or_empty`: [paramvm.json#L77-L94](../nested/paramvm.json#L77-L94).  This pattern is used for parameters that require a subobject when present, but which should otherwise be not specified or empty.  It would be possible to pass these parameters as objects, but that would add complexity to the main template. Variables are used to define the objects that will be used if the parameter is not empty: [paramvm.json#L103-L113](../nested/paramvm.json#L103-L113).  You can see that the Application Gateway Backend property needs to be specified as an object with an `id` property inside of an array, since multiple values are allowed.  The Public IP and Availability Set are simple objects with an `id` parameter.

Use of Public IP parameter for the Network Interface: [paramvm.json#L221](../nested/paramvm.json#L221)

Use of App Gateway Backend parameter for the Network Interface: [paramvm.json#L218](../nested/paramvm.json#L218)

Use of Availability Set parameter for the VM: [paramvm.json#L131](../nested/paramvm.json#L131)

In order to make use of the parameter that specifies the number of data disks, a copy loop is used inside the Virtual Machine's `storageProfile`: [paramvm.json#L144-L159](../nested/paramvm.json#L144-L159)

[Home](../README.md)
