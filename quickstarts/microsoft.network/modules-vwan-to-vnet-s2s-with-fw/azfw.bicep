param location string = resourceGroup().location
param fwname string

@allowed([
  'VNet'
  'vWAN'
])
@description('Specify if the Azure Firewall should be deployed to VNet or Virtual WAN Hub')
param fwtype string

@description('Resoruce ID to the Firewall Policy to associate with the Azure Firewall')
param fwpolicyid string

@description('Virtual Hub Resource ID, used when deploying Azure Firewall to Virtual WAN')
param hubid string = ''

@description('Specifies the number of public IPs to allocate to the firewall when deploying Azure Firewall to Virtual WAN')
param hubpublicipcount int = 1

@description('AzureFirewallSubnet ID, used when deploying Azure Firewall to Virtual Network')
param subnetid string = ''

@description('Azure Firewall Public IP ID, used when deploying Azure Firewall to Virtual Network')
param publicipid string = ''

var hubfwproperties = {
  properties: {
    sku: {
      name: 'AZFW_Hub'
      tier: 'Standard'
    }
    virtualHub: {
      id: hubid
    }
    hubIPAddresses: {
      publicIPs: {
        count: hubpublicipcount
      }
    }
    firewallPolicy: {
      id: fwpolicyid
    }
  }
}

var vnetfwproperties = {
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Standard'
    }
    ipConfigurations: [
      {
        name: '${fwname}-vnetIPConf'
        properties: {
          subnet: {
            id: subnetid
          }
          publicIPAddress: {
            id: publicipid
          }
        }
      }
    ]
    firewallPolicy: {
      id: fwpolicyid
    }
  }
}

resource firewall 'Microsoft.Network/azureFirewalls@2020-06-01' = {
  name: fwname
  location: location
  properties: fwtype == 'VNet' ? vnetfwproperties.properties : fwtype == 'vWAN' ? hubfwproperties.properties : any(null)
}
