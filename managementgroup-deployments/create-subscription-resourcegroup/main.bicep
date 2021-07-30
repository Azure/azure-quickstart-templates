targetScope =  'managementGroup'

@description('EnrollmentAccount used for subscription billing')
param enrollmentAccount string

@description('BillingAccount used for subscription billing')
param billingAccount string

@description('Alias to assign to the subscription')
param subscriptionAlias string

@description('Display name for the subscription')
param subscriptionDisplayName string

@description('Workload type for the subscription')
@allowed([
    'Production'
    'DevTest'
])
param subscriptionWorkload string

@description('Name of the resourceGroup, will be created in the same location as the deployment.')
param resourceGroupName string = 'demo'

@description('Location for the deployments and the resources')
param location string = deployment().location

// Create the subscription and output the GUID
module subAlias './modules/.microsoft.subscription.alias.bicep' = {
    name: 'create-${subscriptionAlias}'
    params: {
        billingAccount: billingAccount
        enrollmentAccount: enrollmentAccount
        subscriptionAlias: subscriptionAlias
        subscriptionDisplayName: subscriptionDisplayName
        subscriptionWorkload: subscriptionWorkload
    }
}

// creating resources in the subscription requires an extra level of "nesting" to reference the subscriptionId as a module output and use for a scope
// The module outputs cannot be used for the scope property so needs to be passed down as a parameter one level
module createResourceGroupStorage './modules/.create.resources.wrapper.bicep' = {
    name: 'nested-createResourceGroup-${resourceGroupName}'
    params: {
        resourceGroupName: resourceGroupName
        location: location
        subscriptionId: subAlias.outputs.subscriptionId  // this cannot be referenced directly on the scope property of a module so needs to be wrapped in another module

    }
}

output subscriptionId string = subAlias.outputs.subscriptionId
output storageAccountId string = createResourceGroupStorage.outputs.storageAccountId
