param availabilitySetName string
param vmLocation string
param availabilitySetTags object
param availabilitySetUpdateDomainCount int
param availabilitySetFaultDomainCount int
param avSetSKU string

resource availabilitySet 'Microsoft.Compute/availabilitySets@2018-10-01' = {
  name: availabilitySetName
  location: vmLocation
  tags: availabilitySetTags
  properties: {
    platformUpdateDomainCount: availabilitySetUpdateDomainCount
    platformFaultDomainCount: availabilitySetFaultDomainCount
  }
  sku: {
    name: avSetSKU
  }
}
