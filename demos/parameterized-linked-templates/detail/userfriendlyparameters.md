# Naming Parameters to be User Friendly

In the main deployment template, conventionally named azuredeploy.json, you can define parameters that will be used to prompt the user for configuration at the beginning of the deployment.  These selections can be used to alter the number or type of resources that will be deployed.

#### Naming Parameters for top-level parameters

You can include whole words and spaces in order to make the parameter's purpose clear.  Spaces are not used by convention, but if you use capitalization of words in the parameter name (PascalCase) the Azure Portal will display the parameter name with added spaces.  For example the parameter `DeployAzureBastionFrontend` will be displayed as `Deploy Azure Bastion Frontend`: [azuredeploy.json#L142-L152](../azuredeploy.json#L142-L152).

Similarly, you can use descriptive strings in the `allowedValues` field: [azuredeploy.json#L112-L123](../azuredeploy.json#L112-L123).

In this example, a full text description is used to let the user know exactly what configuration their backend VMs will have.  This selection is later used as the key to lookup specific configuration elements from a variable: [azuredeploy.json#L214-L265](../azuredeploy.json#L214-L265).

There are many more examples in [azuredeploy.json#L4-L189](../azuredeploy.json#L4-L189).

[Home](../README.md)
