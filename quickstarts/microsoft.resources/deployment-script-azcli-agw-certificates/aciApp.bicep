param location string = resourceGroup().location
param appName string

@allowed([
  'mcr.microsoft.com/oss/nginx/nginx:1.9.15-alpine'
  'mcr.microsoft.com/azuredocs/aci-helloworld:latest'
])
param appImage string = 'mcr.microsoft.com/oss/nginx/nginx:1.9.15-alpine'

resource aci 'Microsoft.ContainerInstance/containerGroups@2021-10-01' = {
  name: appName
  location: location
  properties: {
    containers:  [
      {
        name: 't1'
        properties: {
          image: appImage
          resources: {
            requests: {
              cpu: json('1')
              memoryInGB: json('1.5')
            }
          }
          
          ports: [
            {
              port: 80
              protocol: 'TCP'
            }
          ]
        }
      }
    ]
    restartPolicy: 'OnFailure'
    sku: 'Standard'
    ipAddress: {
      type:  'Public'
      ports: [
        {
          port: 80
          protocol: 'TCP'
        }
      ]
      //dnsNameLabel: appName
    }
    osType: 'Linux'
  }
}
output IpAddress string  = aci.properties.ipAddress.ip
