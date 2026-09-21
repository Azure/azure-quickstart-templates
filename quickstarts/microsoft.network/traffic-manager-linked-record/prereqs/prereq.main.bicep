@description('Location for the validation endpoint resources.')
param location string = resourceGroup().location

@description('Name of the primary validation container group.')
param endpoint1Name string = 'tm-primary-${uniqueString(resourceGroup().id)}'

@description('Name of the secondary validation container group.')
param endpoint2Name string = 'tm-secondary-${uniqueString(resourceGroup().id)}'

@description('Public container image that answers HTTP requests on port 80.')
param image string = 'mcr.microsoft.com/azuredocs/aci-helloworld'

resource endpoint1 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: endpoint1Name
  location: location
  properties: {
    containers: [
      {
        name: endpoint1Name
        properties: {
          image: image
          ports: [
            {
              port: 80
              protocol: 'TCP'
            }
          ]
          resources: {
            requests: {
              cpu: 1
              memoryInGB: 1
            }
          }
        }
      }
    ]
    osType: 'Linux'
    restartPolicy: 'Always'
    ipAddress: {
      type: 'Public'
      ports: [
        {
          port: 80
          protocol: 'TCP'
        }
      ]
    }
  }
}

resource endpoint2 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: endpoint2Name
  location: location
  properties: {
    containers: [
      {
        name: endpoint2Name
        properties: {
          image: image
          ports: [
            {
              port: 80
              protocol: 'TCP'
            }
          ]
          resources: {
            requests: {
              cpu: 1
              memoryInGB: 1
            }
          }
        }
      }
    ]
    osType: 'Linux'
    restartPolicy: 'Always'
    ipAddress: {
      type: 'Public'
      ports: [
        {
          port: 80
          protocol: 'TCP'
        }
      ]
    }
  }
}

output endpoint1IpAddress string = endpoint1.properties.ipAddress.ip
output endpoint2IpAddress string = endpoint2.properties.ipAddress.ip
