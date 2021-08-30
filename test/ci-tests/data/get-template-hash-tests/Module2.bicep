@description('p2 description')
param p2 string

resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2021-03-01' = {
  name: 'name'
  location: resourceGroup().location
  properties: {
    containers: [
      {
        name: 'containername'
        properties: {
          image: 'mcr.microsoft.com/azuredocs/aci-helloworld:latest'
          ports: [
            {
              port: 80
            }
          ]
          resources: {
            requests: {
              cpu: 1
              memoryInGB: 4
            }
          }
        }
      }
    ]
    restartPolicy: 'OnFailure'
    osType: 'Linux'
    ipAddress: {
      type: 'Public'
      ports: [
        {
          protocol: 'TCP'
          port: 80
        }
      ]
    }
  }
}
