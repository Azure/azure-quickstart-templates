#Requires -module AzureRM
#Requires -module pki 

<#
Use this script to create the GEN artifacts needed by the pipeline to test templates.  

########################################################################################
The Crypto module (PKI) is not supported on PS Core so this is using older AzureRM modules.
########################################################################################

Be sure to set the appropriate Context before running the script

#>

param(
    [string] $ResourceGroupName = 'ttk-gen-artifacts',
    [string] [Parameter(mandatory = $true)] $Location, #The location where resources will be deployed in the pipeline, in many cases they need to be in the same region.
    [string] $KeyVaultName = 'azbotvault', # This must be gloablly unique
    [string] $CertPass = $("cI#" + (New-Guid).ToString().Replace("-", "").Substring(0, 17)),
    [string] $CertDNSName = 'azbot-cert-dns',
    [string] $KeyVaultSelfSignedCertName = 'azbot-sscert',
    [string] $KeyVaultNotSecretName = 'notSecretPassword',
    [string] $ServicePrincipalObjectId, #if not provided assigning perms to the Vault must be done manually
    [string] $appConfigStoreName = 'azbotappconfigstore', # This must be gloablly unique
    [string] $msiName = 'azbot-msi',
    #
    # You must generate a public/private key pair and pass to the script use the following command with no passphrase:
    #   ssh-keygen -t rsa -b 4096 -f scratch
    # 
    [string] $sshPublicKeyValue = $(Get-Content -Path scratch.pub -Raw),
    [string] $sshPrivateKeyValue = $(Get-Content -Path scratch -Raw)

)

#Create the Resource Group only if it doesn't exist
if ((Get-AzureRMResourceGroup -Name $ResourceGroupName -Location $Location -Verbose -ErrorAction SilentlyContinue) -eq $null) {
    New-AzureRMResourceGroup -Name $ResourceGroupName -Location $Location -Verbose -Force
}

# Create the storage account for staging and assign perms
$StorageAccountName = 'stage' + ((Get-AzureRmContext).Subscription.Id).Replace('-', '').substring(0, 19)
$StorageAccount = (Get-AzureRmStorageAccount | Where-Object { $_.StorageAccountName -eq $StorageAccountName })
# Create the storage account if it doesn't already exist
if ($StorageAccount -eq $null) {
    $StorageResourceGroupName = 'ARM_Deploy_Staging'
    New-AzureRmResourceGroup -Location "$Location" -Name $StorageResourceGroupName -Force
    $StorageAccount = New-AzureRmStorageAccount -StorageAccountName $StorageAccountName -Type 'Standard_LRS' -ResourceGroupName $StorageResourceGroupName -Location "$Location"
}

#create a userAssigned MSI that can have access to the vault where test keys/certs are stored
$msi = (az identity create -g "$ResourceGroupName" -n "$msiName" --verbose) | ConvertFrom-Json

$json.Add("USER-ASSIGNED-IDENTITY-NAME", $msiName)
$json.Add("USER-ASSIGNED-IDENTITY-RESOURCEGROUP-NAME", $ResourceGroupName)

# Assign perms
if ($ServicePrincipalObjectId) {
    # to be able to write to the staging storage account (deployment script stages artifacts)
    $roleDef = Get-AzureRmRoleDefinition -Name 'Contributor'
    New-AzureRMRoleAssignment -RoleDefinitionId $roleDef.id -ObjectId $ServicePrincipalObjectId -Scope $StorageAccount.Id -Verbose
    # to use the MSI on a resource (the msi should have very limited permissions)
    $roleDef = Get-AzureRmRoleDefinition -Name 'Managed Identity Operator'
    $msiId = "/subscriptions/$((Get-AzureRMContext).Subscription.Id)/resourceGroups/$ResourceGroupName/providers/Microsoft.ManagedIdentity/userAssignedIdentities/$msiName"
    New-AzureRMRoleAssignment -RoleDefinitionId $roleDef.id -ObjectId $ServicePrincipalObjectId -Scope $msiId -Verbose
}


#Create the VNET
$subnet1 = New-AzureRMVirtualNetworkSubnetConfig -Name 'azbot-subnet-1' -AddressPrefix '10.0.1.0/24'
$subnet2 = New-AzureRMVirtualNetworkSubnetConfig -Name 'azbot-subnet-2' -AddressPrefix '10.0.2.0/24'
$vNet = New-AzureRMVirtualNetwork -ResourceGroupName $ResourceGroupName -Name 'azbot-vnet' -AddressPrefix '10.0.0.0/16' -Location $location -Subnet $subnet1, $subnet2 -Verbose -Force

$json = New-Object System.Collections.Specialized.OrderedDictionary #This keeps things in the order we entered them, instead of: New-Object -TypeName Hashtable
$json.Add("VNET-RESOURCEGROUP-NAME", $vNet.ResourceGroupName)
$json.Add("VNET-NAME", $vNet.Name)
$json.Add("VNET-SUBNET1-NAME", $vNet.Subnets[0].Name)
$json.Add("VNET-SUBNET2-NAME", $vNet.Subnets[1].Name)

<#
Creat a KeyVault and add:
    0) The principal deploying templates will need access to the vault (if needed for vm deployments)
    1) Sample Password
    2) Service Fabric Cert
    3) Disk Encryption Key
    4) SSL Cert Secret
    5) Self-Signed Cert

#>
# Create the Vault
$vault = Get-AzureRMKeyVault -VaultName $KeyVaultName -verbose -ErrorAction SilentlyContinue
if ($vault -eq $null) {
    $vault = New-AzureRMKeyVault -VaultName $KeyVaultName `
                                 -ResourceGroupName $ResourceGroupName `
                                 -Location $Location `
                                 -EnabledForTemplateDeployment `
                                 -EnabledForDiskEncryption `
                                 -EnabledForDeployment `
                                 -EnableSoftDelete `
                                 -Verbose
}

# 0) Give the svc principal that will be deploying templates RBAC and Access Policy Access to the Vault

# Create the Microsoft.appConfiguration/configurationStores
# There are no PS cmdlets for app config store yet - use context must be set with "az account set ..."
# Also, not available in Fairfax
$appConfigStore = $(az appconfig create -g appconfig -n bjmappconf1 -l westus -o json --verbose) | ConvertFrom-Json

if ($ServicePrincipalObjectId) {

    # See if the roleDef already exists
    $role = Get-AzureRmRoleDefinition -Name "KeyVault Deployment Action"

    if ($role -eq $null) {
        $roleDef = New-Object -TypeName "Microsoft.Azure.Commands.Resources.Models.Authorization.PSRoleDefinition"

        $roleDef.Id = $null
        $roleDef.Name = "KeyVault Deployment Action"
        $roleDef.Description = "KeyVault Deploy Action for Template Reference Parameter Use"
        $roleDef.Actions = @("Microsoft.KeyVault/vaults/deploy/action")
        $roleDef.AssignableScopes = @("/subscriptions/$((Get-AzureRMContext).Subscription.Id)")

        $roleDef | Out-String

        $role = New-AzureRMRoleDefinition -Role $roleDef -Verbose
    }

    New-AzureRMRoleAssignment -RoleDefinitionId $role.Id -ObjectId $ServicePrincipalObjectId -Scope $vault.ResourceId -Verbose

    # SP needs perms to join the existing vnet

    # See if the roleDef already exists
    $role = Get-AzureRmRoleDefinition -Name "Join Subnets"

    if ($role -eq $null) {
        $roleDef.Id = $null
        $roleDef.Name = "Join Subnets"
        $roleDef.Description = "Join a VM to a subnet"
        $roleDef.Actions = @("Microsoft.Network/virtualNetworks/subnets/join/action")
        $roleDef.AssignableScopes = @("/subscriptions/$((Get-AzureRMContext).Subscription.Id)")

        $roleDef | Out-String

        $role = New-AzureRMRoleDefinition -Role $roleDef -Verbose
    }
    
    $scope = "/subscriptions/$((Get-AzureRMContext).Subscription.Id)/resourceGroups/$ResourceGroupName"
    New-AzureRMRoleAssignment -RoleDefinitionId $role.Id -ObjectId $ServicePrincipalObjectId -Scope $scope -Verbose


    # Need contributor access to be able to add secrets during a template deployment
    $roleDef = Get-AzureRmRoleDefinition -Name 'Contributor'

    # Need contributor rights on vault to run pull reference params - some samples also add secrets
    New-AzureRMRoleAssignment -RoleDefinitionId $roleDef.id -ObjectId $ServicePrincipalObjectId -Scope $vault.ResourceId -Verbose

    # Need contributor rights on config store to run list*() actions
    New-AzureRMRoleAssignment -RoleDefinitionId $roleDef.id -ObjectId $ServicePrincipalObjectId -Scope $appConfigStore.id -Verbose

    # Set the Data Plane Access Policy for the Principal to retrieve secrets via reference parameters
    Set-AzureRMKeyVaultAccessPolicy -VaultName $KeyVaultName 
                                    -ObjectId $ServicePrincipalObjectId `
                                    -PermissionsToKeys get, restore `
                                    -PermissionsToSecrets get, set `
                                    -PermissionsToCertificates get

    # Set the Data Plane Access Policy for the UserAssigned MSI to retrieve secrets via reference parameters
    Set-AzureRMKeyVaultAccessPolicy -VaultName $KeyVaultName
                                    -ObjectId $msi.principalId `
                                    -PermissionsToKeys get `
                                    -PermissionsToSecrets get `
                                    -PermissionsToCertificates get

    # Assign the SP perms to the NetworkWatcherRG for deploying flowlogs
    New-AzureRMRoleAssignment -RoleDefinitionId 'b24988ac-6180-42a0-ab88-20f7382dd24c' `
                              -ObjectId $ServicePrincipalObjectId `
                              -Scope $(Get-AzureRmResourceGroup -Name 'NetworkWatcherRG').ResourceId `
                              -Verbose

}

# These perms are for Azure ML Encryption via Cosmos https://docs.microsoft.com/en-us/azure/cosmos-db/how-to-setup-cmk
# Assign the Azure ML SP perms to the subscription - this needs contributor at the moment, hopefully the fix that later
# Display Name = "Azure Machine Learning" (this substring is not unique)
# Service Principal Name = 0736f41a-0425-4b46-bdb5-1563eff02385
$mlsp = Get-AzureRmADServicePrincipal -ServicePrincipalName '0736f41a-0425-4b46-bdb5-1563eff02385' #-DisplayName "Azure Machine Learning"
$roleDef = Get-AzureRmRoleDefinition -Name 'Contributor'
New-AzureRMRoleAssignment -RoleDefinitionId $roleDef.id -ObjectId $mlsp.id -Scope "/subscriptions/$((Get-AzureRMContext).Subscription.Id)" -Verbose
$json.Add("MACHINE-LEARNING-SP-OBJECTID", $mlsp.id)

$cosmossp = Get-AzureRmADServicePrincipal -ServicePrincipalName "a232010e-820c-4083-83bb-3ace5fc29d0b" # -DisplayName "Azure Cosmos DB"
Set-AzureRMKeyVaultAccessPolicy -VaultName $KeyVaultName -ObjectId $cosmossp.id -PermissionsToKeys get, unwrapKey, wrapKey 
$json.Add("COSMOS-DB-SP-OBJECTID", $cosmossp.id)

$webapp = Get-AzureRmADServicePrincipal -ServicePrincipalName "abfa0a7c-a6b6-4736-8310-5855508787cd" # Web App SP for certificate scenarios - not available in Fairfax?
Set-AzureRMKeyVaultAccessPolicy -VaultName $KeyVaultName -ObjectId $webapp.id -PermissionsToSecrets get 

# for the Microsoft.Azure.CDN service principal - it first must be registered in the sub
$cdn = New-AzureRmADServicePrincipal -ApplicationId 205478c0-bd83-4e1b-a9d6-db63a3e1e1c8
# if the RP autoregisters at some point in the future the above call will fail and will need to simply GET the SP
# $cdn = Get-AzureRmADServicePrincipal -ServicePrincipalName "abfa0a7c-a6b6-4736-8310-5855508787cd" 
Set-AzureRMKeyVaultAccessPolicy -VaultName $KeyVaultName -ObjectId $cdn.id -PermissionsToSecrets get 

# Assign Front Door access to the vault to work with custom domain certificates.
# See https://docs.microsoft.com/azure/frontdoor/front-door-custom-domain-https#option-2-use-your-own-certificate
$frontDoor = New-AzureRmADServicePrincipal -ApplicationId 'ad0e1c7e-6d38-4ba4-9efd-0bc77ba9f037'
# $frontDoor = Get-AzureRmADServicePrincipal -ServicePrincipalName "ad0e1c7e-6d38-4ba4-9efd-0bc77ba9f037"
Set-AzureRMKeyVaultAccessPolicy -VaultName $KeyVaultName -ObjectId $frontDoor.id -PermissionsToSecrets get -PermissionsToCertificates get

# 1) Create a sample password for the vault
$SecretValue = ConvertTo-SecureString -String $CertPass -AsPlainText -Force
Set-AzureKeyVaultSecret -VaultName $KeyVaultName -Name $KeyVaultNotSecretName -SecretValue $SecretValue -Verbose

$json.Add("KEYVAULT-NAME", $vault.VaultName)
$json.Add("KEYVAULT-RESOURCEGROUP-NAME", $vault.ResourceGroupName)
$json.Add("KEYVAULT-PASSWORD-SECRET-NAME", $KeyVaultNotSecretName)
$json.Add("KEYVAULT-SUBSCRIPTION-ID", $vault.ResourceId.Split('/')[2])
$json.Add("KEYVAULT-RESOURCE-ID", $vault.ResourceId)

$refParam = @"
{
    "reference": {
        "keyVault": {
        "id": "$($vault.ResourceId)"
        },
        "secretName": "$KeyVaultNotSecretName"
    }
}
"@

$json.Add("KEYVAULT-PASSWORD-REFERENCE", (ConvertFrom-Json $refParam))

# 2) Create a sample cert for Service Fabric
$SecurePassword = ConvertTo-SecureString -String $CertPass -AsPlainText -Force
$CertFileFullPath = $(Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Definition) "\$CertDNSName.pfx")

if ($(Get-Module 'PKI') -eq $null) { Import-Module "PKI" -SkipEditionCheck -Verbose }
$NewCert = New-SelfSignedCertificate -CertStoreLocation Cert:\CurrentUser\My -DnsName $CertDNSName -NotAfter (Get-Date).AddYears(10)
Export-PfxCertificate -FilePath $CertFileFullPath -Password $SecurePassword -Cert $NewCert

$Bytes = [System.IO.File]::ReadAllBytes($CertFileFullPath)
$Base64 = [System.Convert]::ToBase64String($Bytes)

$JSONBlob = @{
    data = $Base64
    dataType = 'pfx'
    password = $CertPass
} | ConvertTo-Json

$ContentBytes = [System.Text.Encoding]::UTF8.GetBytes($JSONBlob)
$Content = [System.Convert]::ToBase64String($ContentBytes)

$SFSecretValue = ConvertTo-SecureString -String $Content -AsPlainText -Force
$NewSecret = Set-AzureKeyVaultSecret -VaultName $KeyVaultName -Name "azbot-sf-cert" -SecretValue $SFSecretValue -Verbose

$json.Add("SF-CERT-URL", $NewSecret.Id) #need to verify this one, it should be the secret uri
$json.Add("SF-CERT-THUMBPRINT", $NewCert.Thumbprint)

# 3) Create a disk encryption key
$key = Add-AzureKeyVaultKey -VaultName $keyVaultName -Name "azbot-diskkey" -Destination "Software"

$json.Add("KEYVAULT-ENCRYPTION-KEY", $key.Name)
$json.Add("KEYVAULT-ENCRYPTION-KEY-URI", $key.id)
$json.Add("KEYVAULT-ENCRYPTION-KEY-VERSION", $key.Version)

# 4) Create a Public/Private Key Pair
$sshPublicKeySecretName = "sshPublicKey"
$sshPrivateKeySecretName = "sshPrivateKey"

# add the generic pub key value (just use the same one)
$json.Add("SSH-PUB-KEY", $sshPublicKeyValue)

$sshPublicKeyValue = ConvertTo-SecureString -String (Get-Content -Path scratch.pub -Raw) -AsPlainText -Force
Set-AzureKeyVaultSecret -VaultName $KeyVaultName -Name $sshPublicKeySecretName -SecretValue $sshPublicKeyValue -Verbose

$sshPrivateKeyValue = ConvertTo-SecureString -String (Get-Content -Path scratch -Raw) -AsPlainText -Force
Set-AzureKeyVaultSecret -VaultName $KeyVaultName -Name $sshPrivateKeySecretName -SecretValue $sshPrivateKeyValue -Verbose

$json.Add("KEYVAULT-SSH-PRIVATE-KEY-NAME", $sshPrivateKeySecretName)
$json.Add("KEYVAULT-SSH-PUBLIC-KEY-NAME", $sshPublicKeySecretName)

$refParam = @"
{
    "reference": {
        "keyVault": {
        "id": "$($vault.ResourceId)"
        },
        "secretName": "$sshPrivateKeySecretName"
    }
}
"@
$json.Add("KEYVAULT-SSH-PRIVATE-KEY-REFERENCE", (ConvertFrom-Json $refParam))

$refParam = @"
{
    "reference": {
        "keyVault": {
        "id": "$($vault.ResourceId)"
        },
        "secretName": "$sshPublicKeySecretName"
    }
}
"@
$json.Add("KEYVAULT-SSH-PUBLIC-KEY-REFERENCE", (ConvertFrom-Json $refParam))


#5 ) SSL Cert (TODO not sure if this is making the correct cert, need to test it) 
#https://docs.microsoft.com/en-us/azure/virtual-machines/windows/tutorial-secure-web-server#generate-a-certificate-and-store-in-key-vault
#$policy = New-AzureKeyVaultCertificatePolicy -SubjectName "CN=www.contoso.com" -SecretContentType "application/x-pkcs12" -IssuerName Self -ValidityInMonths 120
#Add-AzureKeyVaultCertificate -VaultName $keyvaultName -Name "mycert" -CertificatePolicy $policy

# Use the same cert we generated for Service Fabric here
$pfxFileFullPath = $(Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Definition) "\$CertDNSName.pfx")
$cerFileFullPath = $(Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Definition) "\$CertDNSName.cer")

Export-PfxCertificate -Cert $NewCert -FilePath "$pfxFileFullPath" -Password $(ConvertTo-SecureString -String $CertPass -Force -AsPlainText)
Export-Certificate -Cert $NewCert -FilePath "$cerFileFullPath"

$kvCert = Import-AzureKeyVaultCertificate -VaultName $KeyVaultName -Name "azbot-ssl-cert" -FilePath $pfxFileFullPath -Password $(ConvertTo-SecureString -String $CertPass -Force -AsPlainText)

$json.Add("KEYVAULT-SSL-SECRET-NAME", $kvCert.Name)
$json.Add("KEYVAULT-SSL-SECRET-URI", $kvCert.Id)
$json.Add("SELFSIGNED-CERT-PFXDATA", [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes("$pfxFileFullPath")))
$json.Add("SELFSIGNED-CERT-CERDATA", [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes("$cerFileFullPath")))
$json.Add("SELFSIGNED-CERT-PASSWORD", $CertPass)
$json.Add("SELFSIGNED-CERT-THUMBPRINT", $kvCert.Thumbprint)
$json.Add("SELFSIGNED-CERT-DNSNAME", $CertDNSName)

#6) Create 2 url signing keys for a specific quickstart
$SecretValue = ConvertTo-SecureString -String $(new-guid) -AsPlainText -Force
$s1 = Set-AzureKeyVaultSecret -VaultName $KeyVaultName -Name 'url-sign-secret-1' -SecretValue $SecretValue -Verbose
$SecretValue = ConvertTo-SecureString -String $(new-guid) -AsPlainText -Force
$s2 = Set-AzureKeyVaultSecret -VaultName $KeyVaultName -Name 'url-sign-secret-2' -SecretValue $SecretValue -Verbose
 
$json.Add("KEYVAULT-URLSIGN-SECRET1-NAME", 'url-sign-secret-1')
$json.Add("KEYVAULT-URLSIGN-SECRET2-NAME", 'url-sign-secret-2')

$json.Add("KEYVAULT-URLSIGN-SECRET1-VERSION", $s1.Version)
$json.Add("KEYVAULT-URLSIGN-SECRET2-VERSION", $s2.Version)

# Create the Microsoft.appConfiguration/configurationStores
# There are no PS cmdlets for app config store yet - use context must be set with "az account set ..."
# Also, not available in Fairfax
az appconfig create -g "$ResourceGroupName" -n "$appConfigStoreName" -l "$Location" --verbose 
az appconfig kv set -n "$appConfigStoreName" --key 'key1' --value "value1" --label 'template' -y --verbose
az appconfig kv set -n "$appConfigStoreName" --key 'windowsOSVersion' --value '2019-Datacenter' --label 'template' -y --verbose
az appconfig kv set -n "$appConfigStoreName" --key 'diskSizeGB' --value "1023" --label 'template' -y --verbose

$json.Add("APPCONFIGSTORE-NAME", $appConfigStoreName)
$json.Add("APPCONFIGSTORE-RESOURCEGROUP-NAME", $ResourceGroupName)
$json.Add("APPCONFIGSTORE-KEY1", "key1")
$json.Add("APPCONFIGSTORE-KEY1", "windowsOSVersion")
$json.Add("APPCONFIGSTORE-KEY1", "diskSizeGB")

# Output all the values needed for the config file
Write-Output $($json | ConvertTo-json -Depth 30)
