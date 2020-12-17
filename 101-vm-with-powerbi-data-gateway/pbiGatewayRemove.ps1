#! /opt/microsoft/powershell/7/pwsh

Param(
    # AAD Application Id to install the data gateway under: https://docs.microsoft.com/en-us/powershell/module/datagateway.profile/connect-datagatewayserviceaccount?view=datagateway-ps
    [Parameter(Mandatory = $true)][string]$AppId,

    # AAD Application secret: https://docs.microsoft.com/en-us/powershell/module/datagateway.profile/connect-datagatewayserviceaccount?view=datagateway-ps
    [Parameter(Mandatory = $true)][string]$Secret,

    # AAD Tenant Id (or name): https://docs.microsoft.com/en-us/powershell/module/datagateway.profile/connect-datagatewayserviceaccount?view=datagateway-ps
    [Parameter(Mandatory = $true)][string]$TenantId,
 
    # Documented on the Remove-DataGatewayCluster: https://docs.microsoft.com/en-us/powershell/module/datagateway/remove-datagatewaycluster?view=datagateway-ps
    [Parameter(Mandatory = $true)][string]$GatewayName,

    # Documented on the Remove-DataGatewayCluster: https://docs.microsoft.com/en-us/powershell/module/datagateway/remove-datagatewaycluster?view=datagateway-ps
    [Parameter(Mandatory = $true)][string]$RegionKey
)

if(($PSVersionTable).PSVersion.Major -lt 7) {
    Write-Error("This script requires PowerShell v7 or above")
    exit 1
}

# DataGateway module should already been installed within the container
# ((Get-Module -ListAvailable | Where-Object {$_.Name -eq "Storage"}).Length -eq 0)
if (!(Get-InstalledModule "DataGateway")) {
    Write-Error("DataGateway PS Module is missing")
    exit 1
}

$secureClientSecret = ConvertTo-SecureString $Secret -AsPlainText

# Connect to the Data Gateway service
Write-Host("Connect to the Data Gateway Service")
$connected = (Connect-DataGatewayServiceAccount -ApplicationId $AppId -ClientSecret $secureClientSecret -Tenant $TenantId)
if ($null -eq $connected){
    Write-Error("Error connecting to Data Gateway Service")
    exit 1
}

# Get Gateway ClusterId (not GatewayId)
$gatewayClusterId = (Get-DataGatewayCluster -RegionKey $RegionKey | Where-Object {$_.Name -eq $GatewayName}).Id

# If there was a problem during cluster creation we won't have a ClusterId
if ($null -eq $gatewayClusterId) {
    Write-Error("Error! Data Gateway Cluster not found with Gateway Name: '$GatewayName' in RegionKey: '$RegionKey'")
    exit 1
} else {
    Write-Host("Removing Data Gateway ClusterId: '$gatewayClusterId' in RegionKey: '$RegionKey'")
}

Remove-DataGatewayCluster -GatewayClusterId $gatewayClusterId -RegionKey $RegionKey
Write-Host("Gateway: '$GatewayName' removed")
