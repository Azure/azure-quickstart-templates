Param(
    # AAD Application Id to install the data gateway under: https://docs.microsoft.com/en-us/powershell/module/datagateway.profile/connect-datagatewayserviceaccount?view=datagateway-ps
    [Parameter(Mandatory = $true)][string]$AppId,

    # AAD Application secret: https://docs.microsoft.com/en-us/powershell/module/datagateway.profile/connect-datagatewayserviceaccount?view=datagateway-ps
    [Parameter(Mandatory = $true)][string]$Secret,

    # AAD Tenant Id (or name): https://docs.microsoft.com/en-us/powershell/module/datagateway.profile/connect-datagatewayserviceaccount?view=datagateway-ps
    [Parameter(Mandatory = $true)][string]$TenantId,

    # Documented on the Install-DataGateway: https://docs.microsoft.com/en-us/powershell/module/datagateway/install-datagateway?view=datagateway-ps
    [Parameter()][string]$InstallerLocation,

    # Documented on the Add-DataGatewayCluster: https://docs.microsoft.com/en-us/powershell/module/datagateway/add-datagatewaycluster?view=datagateway-ps
    [Parameter()][string]$RegionKey = $null,

    # Documented on the Add-DataGatewayCluster: https://docs.microsoft.com/en-us/powershell/module/datagateway/add-datagatewaycluster?view=datagateway-ps
    [Parameter(Mandatory = $true)][string]$RecoveryKey,

    # Documented on the Add-DataGatewayCluster: https://docs.microsoft.com/en-us/powershell/module/datagateway/add-datagatewaycluster?view=datagateway-ps
    [Parameter(Mandatory = $true)][string]$GatewayName,

    # Documented on the Add-DataGatewayClusterUser: https://docs.microsoft.com/en-us/powershell/module/datagateway/add-datagatewayclusteruser?view=datagateway-ps
    [Parameter()][string]$GatewayAdminUserIds = $null
)

# Import log utils
. .\logUtil.ps1

$logger = [TraceLog]::new("$env:SystemDrive\WindowsAzure\Logs\Plugins\Microsoft.Compute.CustomScriptExtension\", "pbiGateway.log")

if(($PSVersionTable).PSVersion.Major -lt 7) {
    $progressMsg = "Error: This script requires PowerShell v7 or above"
    $logger.Log($progressMsg)
    Write-Error($progressMsg)
    exit 1
}

# Install the DataGateway module if not already available
# ((Get-Module -ListAvailable | Where-Object {$_.Name -eq "Storage"}).Length -eq 0)
if (!(Get-InstalledModule "DataGateway" -ErrorAction SilentlyContinue)) {
    $progressMsg = "Installing DataGateway PS Module"
    $logger.Log($progressMsg)
    Write-Host($progressMsg)
    Install-Module -Name DataGateway -Force -Scope AllUsers
}

$secureClientSecret = ConvertTo-SecureString $Secret -AsPlainText
$secureRecoveryKey = ConvertTo-SecureString $RecoveryKey -AsPlainText

# Connect to the Data Gateway service
$progressMsg = "Connect to the Data Gateway Service"
$logger.Log($progressMsg)
Write-Host($progressMsg)
$connected = (Connect-DataGatewayServiceAccount -ApplicationId $AppId -ClientSecret $secureClientSecret -Tenant $TenantId)
if ($null -eq $connected){
    $progressMsg = "Error: Connecting to Data Gateway Service"
    $logger.Log($progressMsg)
    Write-Error($progressMsg)
    exit 1
}

# Check if gateway already installed
if (!(IsInstalled 'GatewayComponents' $logger)) {
    # Install the gateway on machine
    $progressMsg = "Installing Data Gateway"
    $logger.Log($progressMsg)
    Write-Host($progressMsg)

    if (!(Test-Path -Path $InstallerLocation)) {
        # Download the installer
        $progressMsg = "InstallerLocation: '$InstallerLocation' not found - using default"
        $logger.Log($progressMsg)
        Write-Host($progressMsg)
        Install-DataGateway -AcceptConditions
    }else {
        # Use local installer
        $progressMsg = "InstallerLocation: '$InstallerLocation' found"
        $logger.Log($progressMsg)
        Write-Host($progressMsg)
        Install-DataGateway -AcceptConditions -InstallerLocation $InstallerLocation
    }
}

# Create the Data Gateway Cluster, returning it's Id
$newGatewayCluster = $null
$gatewayClusterId = $null
$progressMsg = "Creating Data Gateway Cluster: '$GatewayName' in RegionKey: '$RegionKey'"
$logger.Log($progressMsg)
Write-Host($progressMsg)

$newGatewayCluster = (Add-DataGatewayCluster -Name $GatewayName -RecoveryKey $secureRecoveryKey -RegionKey $RegionKey -OverwriteExistingGateway) 

if ($null -eq $newGatewayCluster) {
    # If Gateway already exists, get the ClusterId (not GatewayId)
    $gatewayClusterId = (Get-DataGatewayCluster -RegionKey $RegionKey | Where-Object {$_.Name -eq $GatewayName}).Id
    $progressMsg = "Data Gateway Cluster name '$GatewayName' already exists: '$gatewayClusterId'"
    $logger.Log($progressMsg)
    Write-Host($progressMsg)
}else {
    # Gateway created ok, get the ClusterId
    $gatewayClusterId = $newGatewayCluster.GatewayObjectId
    $progressMsg = "Data Gateway Cluster created Id: '$gatewayClusterId'"
    $logger.Log($progressMsg)
    Write-Host($progressMsg)
}

# If problem during cluster creation or cluster missing we won't have a ClusterId
if ($null -eq $gatewayClusterId) {
    $progressMsg = "Error: Data Gateway Cluster not found, check if Gateway Name: '$GatewayName' already exists and status of Gateway Cluster Id: '$gatewayClusterId'"
    $logger.Log($progressMsg)
    Write-Error($progressMsg)
    exit 1
}

# Optionally add additional user as an admin for this data gateway
if (!([string]::IsNullOrEmpty($GatewayAdminUserIds))) {
    $progressMsg = "Adding Data Gateway admin user(s): '$GatewayAdminUserIds'"
    $logger.Log($progressMsg)
    Write-Host($progressMsg)

    $GatewayAdminUserIdArray = $GatewayAdminUserIds -split ','
    $GatewayAdminUserIdArray.foreach{
        [GUID]$userGuid = $PSItem
        $progressMsg = "Adding Data Gateway admin user: '$userGuid'"
        $logger.Log($progressMsg)
        Write-Host($progressMsg)
        Add-DataGatewayClusterUser -GatewayClusterId $gatewayClusterId -RegionKey $RegionKey -PrincipalObjectId $userGuid -AllowedDataSourceTypes $null -Role Admin

        # Check the user was added ok
        if ((Get-DataGatewayCluster -Cluster $gatewayClusterId -RegionKey $RegionKey | Select-Object -ExpandProperty Permissions | Where-Object {$_.Id -eq $userGuid}).Length -ne 0) {
            $progressMsg = "Data Gateway admin user added"
            $logger.Log($progressMsg)
            Write-Host($progressMsg)
        }else {
            $progressMsg = "Warning! Data Gateway admin user not added"
            $logger.Log($progressMsg)
            Write-Warning($progressMsg)
        }
    }
}

# Retrieve the cluster status
$cs = (Get-DataGatewayClusterStatus -GatewayClusterId $gatewayClusterId -RegionKey $RegionKey)
$progressMsg = "Cluster '$gatewayClusterId' ClusterStatus: '$($cs.ClusterStatus)' GatewayVersion: '$($cs.GatewayVersion)' GatewayUpgradeState: '$($cs.GatewayUpgradeState)'"
$logger.Log($progressMsg)
Write-Host($progressMsg)

# Status other than Live indicates issue
if ('Live' -ne $cs.ClusterStatus) {
    $progressMsg = "Error: Power BI Gateway not started!"
    $logger.Log($progressMsg)
    Write-Host($progressMsg)    
    exit 1
}else {
    $progressMsg = "Finished pbiGateway.ps1"
    $logger.Log($progressMsg)
    Write-Host($progressMsg)
}
