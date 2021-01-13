# Create App Service Environment with Azure SQL backend and associated private resources
This template creates an App Service Environment with an App Service within its assigned Subnet which can connect to a backend Azure SQL Server via a private endpoint. Both the App Service and Azure SQL Server are configured with a private endpoints and discoverable via Azure Private DNS. There is a P2S VPN Gateway so that you can connect privately to the VNET and access resources such as Azure SQL or App Service. In fact, a samll Virtual Machine is configured so you can remote desktop into this VM and leverage the Private DNS to access those resources. Within the App Service Configuration, you can create an Key Vault reference to the DB Connection string, so no secrets will ever be exposed. We will notice that the publicNetworkAccess setting is set to Enabled even though public network access should be disabled. The reason for this is we need this to be turned on to manage database level firewall rules.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-asev2-appservice-sql-vpngw%2Fazuredeploy.json)

## More on the Parameters

The idea behind stackName so we can name all resources with similar name which is useful for identifying your resources. Feel free to pass in any name you like but it is recommanded to keep it short i.e. less than 10 characters. 

The aadUserObjectId parameter is your user object Id and allows you to have access to Azure SQL and Azure Key Vault with your AAD user credentials. You can use Azure CLI to get that with the following command.

```
$objectId = ((az ad user list --upn (az account list | ConvertFrom-Json).user[1].name) | ConvertFrom-Json).objectId
```

Follow the instructions on https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-certificates-point-to-site to create your own cert and pass it in. Here's an example code snippet.

```
$cert = New-SelfSignedCertificate -Type Custom -KeySpec Signature `
    -Subject "CN=P2SRootCert" -KeyExportPolicy Exportable `
    -HashAlgorithm sha256 -KeyLength 2048 `
    -CertStoreLocation "Cert:\CurrentUser\My" -KeyUsageProperty Sign -KeyUsage CertSign

New-SelfSignedCertificate -Type Custom -DnsName P2SChildCert -KeySpec Signature `
    -Subject "CN=P2SChildCert" -KeyExportPolicy Exportable `
    -HashAlgorithm sha256 -KeyLength 2048 `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -Signer $cert -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2")


$RawRootCertFilePath = "<Replace with your own path>\P2SRootCertRaw.cer"
Export-Certificate -Cert $cert -FilePath $RawRootCertFilePath -Force

certutil -encode $RawRootCertFilePath $RootCertFilePath 
```