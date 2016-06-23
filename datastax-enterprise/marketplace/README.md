This is a Create UI Definition file and a mainTemplate.json that is a slight variation on the singledc template for Azure Marketplace Deployments.

It is not intended to be used alone, but rather zipped with the contents of the singledc and extensions folders and submitted to the Azure Publish Portal.  The Azure Marketplace does not allow directories, so these files must all be zipped together in one directory.

The UI definition can be tested by following this [link](https://portal.azure.com/?clientOptimizations=false#blade/Microsoft_Azure_Compute/CreateMultiVmWizardBlade/internal_bladeCallId/anything/internal_bladeCallerParams/{"initialData":{},"providerConfig":{"createUiDefinition":"https%3A%2F%2Fraw.githubusercontent.com%2FDSPN%2Fazure-resource-manager-dse%2Fmaster%2Fmarketplace%2FcreateUiDefinition.json"}}).
