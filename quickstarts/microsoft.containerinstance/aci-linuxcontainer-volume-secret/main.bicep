@description('Name for the container group')
param name string

@description('Name for the container')
param containerName string = 'container1'

@description('Name for the image')
param imageName string = 'containerinstance/helloworld:ssl'

@description('Name for the secret volume')
param volumeName string = 'volume1'

@description('The DSN name label')
param dnsNameLabel string

@description('Base-64 encoded authentication PFX certificate.')
@secure()
param sslCertificateData string

@description('Base-64 encoded password of authentication PFX certificate.')
@secure()
param sslCertificatePwd string

@description('Port to open on the container and the public IP address.')
param port int = 443

@description('The number of CPU cores to allocate to the container.')
param cpuCores int = 1

@description('The amount of memory to allocate to the container in gigabytes.')
param memoryInGb int = 2

@description('Location for all resources.')
param location string = resourceGroup().location

resource containergroup 'Microsoft.ContainerInstance/containerGroups@2020-11-01' = {
  name: name
  location: location
  properties: {
    containers: [
      {
        name: containerName
        properties: {
          image: imageName
          ports: [
            {
              port: port
            }
          ]
          resources: {
            requests: {
              cpu: cpuCores
              memoryInGB: memoryInGb
            }
          }
          volumeMounts: [
            {
              name: volumeName
              mountPath: '/mnt/secrets'
              readOnly: false
            }
          ]
        }
      }
    ]
    osType: 'Linux'
    ipAddress: {
      type: 'Public'
      dnsNameLabel: dnsNameLabel
      ports: [
        {
          protocol: 'TCP'
          port: port
        }
      ]
    }
    volumes: [
      {
        name: volumeName
        secret: {
          sslCertificateData: sslCertificateData
          sslCertificatePwd: base64(sslCertificatePwd)
        }
      }
    ]
  }
}

output containerIPAddressFqdn string = containergroup.properties.ipAddress.fqdn
