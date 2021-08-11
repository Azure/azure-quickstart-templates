@description('Required. Name of the Network Security Group.')
@minLength(1)
param networkSecurityGroupName string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Required. Array of Security Rules to deploy to the Network Security Group.')
param networkSecurityGroupSecurityRules array

//var emptyArray = []

resource networkSecurityGroupName_resource 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [for item in networkSecurityGroupSecurityRules: {
      name: item.name
      properties: {
        description: item.properties.description
        access: item.properties.access
        destinationAddressPrefix: ((item.properties.destinationAddressPrefix == '') ? json('null') : item.properties.destinationAddressPrefix)
        destinationAddressPrefixes: ((length(item.properties.destinationAddressPrefixes) == 0) ? json('null') : item.properties.destinationAddressPrefixes)
        //destinationApplicationSecurityGroups: ((length(item.properties.destinationApplicationSecurityGroups) == 0) ? json('null') : concat(emptyArray, array(json('{{"id": "${resourceId('Microsoft.Network/applicationSecurityGroups', item.properties.destinationApplicationSecurityGroups[0].name)}","location": "${location}"}}'))))
        destinationPortRanges: ((length(item.properties.destinationPortRanges) == 0) ? json('null') : item.properties.destinationPortRanges)
        destinationPortRange: ((item.properties.destinationPortRange == '') ? json('null') : item.properties.destinationPortRange)
        direction: item.properties.direction
        priority: int(item.properties.priority)
        protocol: item.properties.protocol
        sourceAddressPrefix: ((item.properties.sourceAddressPrefix == '') ? json('null') : item.properties.sourceAddressPrefix)
        //sourceApplicationSecurityGroups: ((length(item.properties.sourceApplicationSecurityGroups) == 0) ? json('null') : concat(emptyArray, array(json('{{"id": "${resourceId('Microsoft.Network/applicationSecurityGroups', item.properties.sourceApplicationSecurityGroups[0].name)}","location": "${location}"}}'))))
        sourcePortRanges: ((length(item.properties.sourcePortRanges) == 0) ? json('null') : item.properties.sourcePortRanges)
        sourcePortRange: item.properties.sourcePortRange
      }
    }]
  }
}
