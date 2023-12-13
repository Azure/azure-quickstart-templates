@description('Relative DNS name for the traffic manager profile, must be globally unique.')
param uniqueDnsName string

resource ExternalEndpointExample 'Microsoft.Network/trafficmanagerprofiles@2018-08-01' = {
  name: 'ExternalEndpointExample'
  location: 'global'
  properties: {
    profileStatus: 'Enabled'
    trafficRoutingMethod: 'Performance'
    dnsConfig: {
      relativeName: uniqueDnsName
      ttl: 30
    }
    monitorConfig: {
      protocol: 'HTTPS'
      port: 443
      path: '/'
      expectedStatusCodeRanges: [
        {
          min: 200
          max: 202
        }
        {
          min: 301
          max: 302
        }
      ]
    }
    endpoints: [
      {
        type: 'Microsoft.Network/TrafficManagerProfiles/ExternalEndpoints'
        name: 'endpoint1'
        properties: {
          target: 'www.microsoft.com'
          endpointStatus: 'Enabled'
          endpointLocation: 'northeurope'
        }
      }
      {
        type: 'Microsoft.Network/TrafficManagerProfiles/ExternalEndpoints'
        name: 'endpoint2'
        properties: {
          target: 'docs.microsoft.com'
          endpointStatus: 'Enabled'
          endpointLocation: 'southcentralus'
        }
      }
    ]
  }
}
