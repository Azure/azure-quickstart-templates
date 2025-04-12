@description('Region where the Mobile Network will be deployed (must match the resource group region)')
param location string

@description('Name of the Mobile Network to add a SIM policy to')
param existingMobileNetworkName string

@description('Name of the existing slice to use for the SIM policy')
param existingSliceName string

@description('Name of the existing data network to use for the SIM policy')
param existingDataNetworkName string

@description('The name of the service')
param serviceName string = 'Allow_all_traffic'

@description('The maximum bit rate (MBR) for uploads across all service data flows that match data flow policy rules configured on the generic service')
param serviceMaximumBitRateUplink string = '2 Gbps'

@description('The maximum bit rate (MBR) for downloads across all service data flows that match data flow policy rules configured on the generic service')
param serviceMaximumBitRateDownlink string = '2 Gbps'

@description('The precedence value for the service being deployed.')
@maxValue(255)
@minValue(0)
param servicePrecedence int = 253

@description('The name of the data flow policy rule that will be created for this service.')
param dataFlowPolicyRuleName string = 'All_traffic'

@description('The precedence value for the data flow policy rule being created.')
@maxValue(255)
@minValue(0)
param dataFlowPolicyRulePrecedence int = 253

@description('Whether flows matching this data flow policy rule are permitted or blocked.')
@allowed([
  'Enabled'
  'Blocked'
])
param dataFlowPolicyRuleTrafficControl string = 'Enabled'

@description('Which protocols match this data flow policy rule. This should be either a list of IANA protocol numbers or the special value "ip"')
param dataFlowTemplateProtocols array = [
  'ip'
]

@description('The name of the data flow template that will be created for this service.')
param dataFlowTemplateName string = 'ip_traffic'

@description('The direction of the flow to match with this data flow policy rule.')
@allowed([
  'Uplink'
  'Downlink'
  'Bidirectional'
])
param dataFlowTemplateDirection string = 'Bidirectional'

@description('The remote IP addresses that UEs will connect to for this flow. This should be either a list of IP addresses or the special value "any"')
param dataFlowTemplateRemoteIps array = [
  'any'
]

@description('The name of the SIM policy')
param simPolicyName string = 'Default-policy'

@description('The UE aggregated maximum bit rate (UE-AMBR) for uploads across all non-GBR QoS flows for a particular UE')
param totalBandwidthAllowedUplink string = '2 Gbps'

@description('The UE aggregated maximum bit rate (UE-AMBR) for downloads across all non-GBR QoS flows for a particular UE')
param totalBandwidthAllowedDownlink string = '2 Gbps'

@description('The session aggregated maximum bit rate (Session-AMBR) for uploads across all non-GBR QoS flows of an individual PDU session involving a particular UE')
param sessionAggregateMaximumBitRateUplink string = '2 Gbps'

@description('The session aggregated maximum bit rate (Session-AMBR) for downloads across all non-GBR QoS flows of an individual PDU session involving a particular UE')
param sessionAggregateMaximumBitRateDownlink string = '2 Gbps'

#disable-next-line BCP081
resource existingMobileNetwork 'Microsoft.MobileNetwork/mobileNetworks@2024-04-01' existing = {
  name: existingMobileNetworkName

  #disable-next-line BCP081
  resource existingDataNetwork 'dataNetworks@2024-04-01' existing = {
    name: existingDataNetworkName
  }

  #disable-next-line BCP081
  resource existingSlice 'slices@2024-04-01' existing = {
    name: existingSliceName
  }

  #disable-next-line BCP081
  resource exampleService 'services@2024-04-01' = {
    name: serviceName
    location: location
    properties: {
      servicePrecedence: servicePrecedence
      serviceQosPolicy: {
        maximumBitRate: {
          uplink: serviceMaximumBitRateUplink
          downlink: serviceMaximumBitRateDownlink
        }
      }
      pccRules: [
        {
          ruleName: dataFlowPolicyRuleName
          rulePrecedence: dataFlowPolicyRulePrecedence
          trafficControl: dataFlowPolicyRuleTrafficControl
          serviceDataFlowTemplates: [
            {
              templateName: dataFlowTemplateName
              protocol: dataFlowTemplateProtocols
              direction: dataFlowTemplateDirection
              remoteIpList: dataFlowTemplateRemoteIps
            }
          ]
        }
      ]
    }
  }

  #disable-next-line BCP081
  resource exampleSimPolicy 'simPolicies@2024-04-01' = {
    name: simPolicyName
    location: location
    properties: {
      ueAmbr: {
        uplink: totalBandwidthAllowedUplink
        downlink: totalBandwidthAllowedDownlink
      }
      defaultSlice: {
        id: existingSlice.id
      }
      sliceConfigurations: [
        {
          slice: {
            id: existingSlice.id
          }
          defaultDataNetwork: {
            id: existingDataNetwork.id
          }
          dataNetworkConfigurations: [
            {
              dataNetwork: {
                id: existingDataNetwork.id
              }
              sessionAmbr: {
                uplink: sessionAggregateMaximumBitRateUplink
                downlink: sessionAggregateMaximumBitRateDownlink
              }
              allowedServices: [
                {
                  id: exampleService.id
                }
              ]
            }
          ]
        }
      ]
    }
  }
}
