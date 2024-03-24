@description('this will be the location for artifacts')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('this will be the sas key to access artifacts')
@secure()
param _artifactsLocationSasToken string = ''

@description('your resources will be created in this location')
param location string = resourceGroup().location

@description('this will be you SKU for OMS')
@allowed([
  'Free'
  'Standalone'
  'PerNode'
])
param omsSku string = 'PerNode'

@description('this will be the type of public IP address used for the application gateway name')
@allowed([
  'dynamic'
  'static'
])
param pipAddressType string = 'dynamic'

@description('this will be the admin user for sql server')
param sqlAdministratorName string

@description('this wiil be th password for the admin user for sql server')
@secure()
param sqlServerPassword string

@description('URI for bacpac')
param bacpacUri string

var omsWorkspaceName = 'xss-attack-oms-${substring(uniqueString(resourceGroup().id), 0, 5)}'
var omsSolutions = [
  'Security'
  'AzureActivity'
  'AzureWebAppsAnalytics'
  'AzureSQLAnalytics'
]
var tags = {
  scenario: 'XSS-Attack-Prevention'
}
var vNetName = 'xss-appgw-vnet'
var vNetAddressSpace = '10.1.0.0/16'
var subnets = [
  {
    name: 'appgw-subnet'
    properties: {
      addressPrefix: '10.1.0.0/24'
    }
  }
]
var applicationGateways = [
  {
    name: 'appgw-detection'
    wafMode: 'Detection'
  }
  {
    name: 'appgw-prevention'
    wafMode: 'Prevention'
  }
]
var databases = [
  {
    name: 'contosoclinic'
    edition: 'Standard'
  }
]
var webAppName = 'xss-attack-webapp-${substring(uniqueString(resourceGroup().id), 0, 5)}'
var httpProbeName = 'aseProbeHTTP'
var httpsProbeName = 'aseProbeHTTPS'
var aspName = 'xss-attack-asp-${substring(uniqueString(resourceGroup().id), 0, 5)}'
var diagStorageAccName = 'xssattackstg${substring(uniqueString(resourceGroup().id), 0, 5)}'
var appServiceConnectionType = 'SQLAzure'
var sqlServerName = 'xssattackserver${substring(uniqueString(resourceGroup().id), 0, 5)}'
var webPackageUri = format('{0}{1}', uri(_artifactsLocation, 'artifacts/ContosoClinic.zip'), _artifactsLocationSasToken)

module deploy_xss_attack_oms_resource 'nested/microsoft.loganalytics/workspaces.bicep' = {
  name: 'deploy-xss-attack-oms-resource'
  params: {
    omsWorkspaceName: omsWorkspaceName
    omsSolutionsName: omsSolutions
    sku: omsSku
    location: location
    tags: tags
  }
}

module vnetName_resource 'nested/microsoft.network/virtualnetworks.bicep' = {
  name: '${vNetName}-resource'
  params: {
    vnetName: vNetName
    addressPrefix: vNetAddressSpace
    subnets: subnets
    location: location
    tags: tags
  }
}

module applicationGateways_name_pip_resource 'nested/microsoft.network/publicipaddress.bicep' = [for i in range(0, 2): {
  name: '${applicationGateways[i].name}-pip-resource'
  params: {
    publicIPAddressName: '${applicationGateways[i].name}-pip'
    publicIPAddressType: pipAddressType
    dnsNameForPublicIP: '${applicationGateways[i].name}-${uniqueString(resourceGroup().id, 'pip')}-pip'
    location: location
    tags: tags
  }
}]

module deploy_applicationGateways_name_applicationgateway_resource 'nested/microsoft.network/applicationgateway.bicep' = [for i in range(0, 2): {
  name: 'deploy-${applicationGateways[i].name}-applicationgateway-resource'
  params: {
    applicationGatewayName: applicationGateways[i].name
    location: location
    publicIPRef: reference(resourceId('Microsoft.Resources/deployments', '${applicationGateways[i].name}-pip-resource')).outputs.publicIPRef.value
    frontendPorts: [
      {
        name: 'appGatewayFrontendPort'
        properties: {
          Port: 80
        }
      }
    ]
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vNetName, subnets[0].name)
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'appGatewayBackendPool'
        properties: {
          BackendAddresses: [
            {
              fqdn: webAppName_resource.outputs.endpoint
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'appGatewayBackendHttpSettings'
        properties: {
          Port: 80
          Protocol: 'Http'
          CookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: 'true'
          Probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGateways[i].name, httpProbeName)
          }
        }
      }
    ]
    httpListeners: [
      {
        name: 'appGatewayHttpListener'
        properties: {
          FrontendIPConfiguration: {
            Id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGateways[i].name, 'appGatewayFrontendIP')
          }
          FrontendPort: {
            Id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGateways[i].name, 'appGatewayFrontendPort')
          }
          Protocol: 'Http'
        }
      }
    ]
    requestRoutingRules: [
      {
        Name: 'rule1'
        properties: {
          RuleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGateways[i].name, 'appGatewayHttpListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGateways[i].name, 'appGatewayBackendPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGateways[i].name, 'appGatewayBackendHttpSettings')
          }
        }
      }
    ]
    probes: [
      {
        name: httpProbeName
        properties: {
          protocol: 'Http'
          host: webAppName_resource.outputs.endpoint
          path: '/'
          interval: 30
          timeout: 30
          unhealthyThreshold: 8
        }
      }
      {
        name: httpsProbeName
        properties: {
          protocol: 'Https'
          host: webAppName_resource.outputs.endpoint
          path: '/'
          interval: 30
          timeout: 30
          unhealthyThreshold: 8
        }
      }
    ]
    wafMode: applicationGateways[i].wafMode
    omsWorkspaceResourceId: deploy_xss_attack_oms_resource.outputs.workspaceId
  }
  dependsOn: [
    applicationGateways_name_pip_resource
    vnetName_resource
  ]
}]

module diagStorageAccName_resource 'nested/microsoft.storage/storageaccounts.bicep' = {
  name: '${diagStorageAccName}-resource'
  params: {
    storageAccountName: diagStorageAccName
    location: location
    tags: tags
  }
}

module aspName_resource 'nested/microsoft.web/serverfarms.bicep' = {
  name: '${aspName}-resource'
  params: {
    name: aspName
    location: location
    tags: tags
  }
}

module webAppName_resource 'nested/microsoft.web/sites.bicep' = {
  name: '${webAppName}-resource'
  params: {
    name: webAppName
    hostingPlanName: aspName
    location: location
    tags: tags
  }
  dependsOn: [
    aspName_resource
  ]
}

module webAppName_connectionStrings_resource 'nested/microsoft.web/sites.config.connectionstrings.bicep' = {
  name: '${webAppName}-connectionStrings-resource'
  params: {
    webAppName: webAppName
    connectionType: appServiceConnectionType
    connectionString: '${databases_0_name_database_resource.outputs.dbConnetcionString};User Id=${sqlAdministratorName};Password=${sqlServerPassword};Connection Timeout=300;'
  }
  dependsOn: [
    webAppName_resource

  ]
}

module webAppName_msdeploy_resource 'nested/microsoft.web/sites.extensions.msdeploy.bicep' = {
  name: '${webAppName}-msdeploy-resource'
  params: {
    webAppName: webAppName
    packageUri: webPackageUri
  }
  dependsOn: [
    webAppName_connectionStrings_resource
  ]
}

module sqlServerName_resource 'nested/microsoft.sql/servers.v12.0.bicep' = {
  name: '${sqlServerName}-resource'
  params: {
    sqlServerName: sqlServerName
    location: location
    administratorLogin: sqlAdministratorName
    administratorLoginPassword: sqlServerPassword
    tags: tags
  }
}

module sqlServerName_auditingSettings_resource 'nested/microsoft.sql/servers.auditingsettings.bicep' = {
  name: '${sqlServerName}-auditingSettings-resource'
  params: {
    sqlServerName: sqlServerName
    storageAccountName: diagStorageAccName
  }
  dependsOn: [
    sqlServerName_resource
    diagStorageAccName_resource
  ]
}

module databases_0_name_database_resource 'nested/microsoft.sql/servers.databases.bicep' = {
  name: '${databases[0].name}-database-resource'
  params: {
    sqlServerName: sqlServerName
    location: location
    databaseName: databases[0].name
    omsWorkspaceResourceId: deploy_xss_attack_oms_resource.outputs.workspaceId
    tags: tags
    administratorLogin: sqlAdministratorName
    administratorLoginPassword: sqlServerPassword
    bacpacuri: bacpacUri
    edition: databases[0].edition
  }
  dependsOn: [
    sqlServerName_resource
  ]
}
