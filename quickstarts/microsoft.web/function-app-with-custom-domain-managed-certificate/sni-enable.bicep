param functionAppName string
param functionAppHostname string
param certificateThumbprint string

resource functionAppCustomHostEnable 'Microsoft.Web/sites/hostNameBindings@2020-06-01' = {
  name: '${functionAppName}/${functionAppHostname}'
  properties: {
    sslState: 'SniEnabled'
    thumbprint: certificateThumbprint
  }
}
