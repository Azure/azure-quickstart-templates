param location string = resourceGroup().location
param keyVaultName string = 'kv-${uniqueString(resourceGroup().id)}'
param nspName string = 'networkSecurityPerimeter'
param profileName string = 'profile1'
param inboundIpv4AccessRuleName string = 'inboundRule'
param outboundFqdnAccessRuleName string = 'outboundRule'
param associationName string = 'networkSecurityPerimeterAssociation'

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
    name: keyVaultName
    location: location
    properties: {
        sku: {
            family: 'A'
            name: 'standard'
        }
        tenantId: subscription().tenantId
        accessPolicies: []
        enabledForDeployment: false
        enabledForDiskEncryption: false
        enabledForTemplateDeployment: false
        enableSoftDelete: true
        softDeleteRetentionInDays: 90
        enableRbacAuthorization: false
    }
}

resource networkSecurityPerimeter 'Microsoft.Network/networkSecurityPerimeters@2023-07-01-preview' = {
    name: nspName
    location: location
    properties: {}
}

resource profile 'Microsoft.Network/networkSecurityPerimeters/profiles@2023-07-01-preview' = {
    parent: networkSecurityPerimeter
    name: profileName
    location: location
    properties: {}
}

resource inboundAccessRule 'Microsoft.Network/networkSecurityPerimeters/profiles/accessRules@2023-07-01-preview' = {
    parent: profile
    name: inboundIpv4AccessRuleName
    location: location
    properties: {
        direction: 'Inbound'
        addressPrefixes: [
            '100.10.0.0/16'
        ]
        fullyQualifiedDomainNames: []
        subscriptions: []
        emailAddresses: []
        phoneNumbers: []
    }
}

resource outboundAccessRule 'Microsoft.Network/networkSecurityPerimeters/profiles/accessRules@2023-07-01-preview' = {
    parent: profile
    name: outboundFqdnAccessRuleName
    location: location
    properties: {
        direction: 'Outbound'
        addressPrefixes: []
        fullyQualifiedDomainNames: [
            'contoso.com'
        ]
        subscriptions: []
        emailAddresses: []
        phoneNumbers: []
    }
}

resource resourceAssociation 'Microsoft.Network/networkSecurityPerimeters/resourceAssociations@2023-07-01-preview' = {
    parent: networkSecurityPerimeter
    name: associationName
    location: location
    properties: {
        privateLinkResource: {
            id: keyVault.id
        }
        profile: {
            id: profile.id
        }
        accessMode: 'Enforced'
    }
}
