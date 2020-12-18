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

if (($PSVersionTable).PSVersion.Major -lt 7) {
    $progressMsg = "Error: This script requires PowerShell v7 or above"
    $logger.Log($progressMsg)
    Write-Error($progressMsg)
    exit 1
}

# Install the DataGateway module if not already available
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
if ($null -eq $connected) {
    # Surface last error detail
    $lastError = Resolve-DataGatewayError -Last
    $logger.Log($lastError.Message)
    Write-Host($lastError.Message)

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
    }
    else {
        # Use local installer
        $progressMsg = "InstallerLocation: '$InstallerLocation' found"
        $logger.Log($progressMsg)
        Write-Host($progressMsg)
        Install-DataGateway -AcceptConditions -InstallerLocation $InstallerLocation
    }
}

# Due to a bug in the DataGeteway PS module only pass in the region to each command if we're not using the default
$defaultRegionKey = (Get-DataGatewayRegion | Where-Object {$_.IsDefaultPowerBIRegion -eq $true}).RegionKey
$progressMsg = "Default RegionKey: '$defaultRegionKey'"
$logger.Log($progressMsg)
Write-Host($progressMsg)   

# Only splat the RegionKey parameter if it's not been passed or is the default
$regionKeyParam = @{}
if ((![string]::IsNullOrEmpty($RegionKey)) -and ($defaultRegionKey -ne $RegionKey)) {
    $regionKeyParam = @{
        RegionKey = $RegionKey
    }
    $progressMsg = "Creating Data Gateway Cluster: '$GatewayName' in RegionKey: '$RegionKey'"
} else  {
    $progressMsg = "Creating Data Gateway Cluster: '$GatewayName' in RegionKey: '$defaultRegionKey' (default)"
}
$logger.Log($progressMsg)
Write-Host($progressMsg)

# Create the Data Gateway Cluster, returning it's Id
# First check if this cluster already exists & get its ClusterId (not GatewayId)
$gatewayClusterId = $null
$gatewayClusterId = (Get-DataGatewayCluster @regionKeyParam | Where-Object { $_.Name -eq $GatewayName }).Id
if ($null -ne $gatewayClusterId) {
    $progressMsg = "Data Gateway Cluster name: '$GatewayName' already exists Cluster Id: '$gatewayClusterId'"
    $logger.Log($progressMsg)
    Write-Host($progressMsg)
} else {
    # Attempt to create cluster
    $gatewayClusterId = (Add-DataGatewayCluster @regionKeyParam -Name $GatewayName -RecoveryKey $secureRecoveryKey -OverwriteExistingGateway).GatewayObjectId   
    if ($null -ne $gatewayClusterId) {
        $progressMsg = "Data Gateway Cluster name: '$GatewayName' created Cluster Id: '$gatewayClusterId'"
        $logger.Log($progressMsg)
        Write-Host($progressMsg)
    }
}

# If problem during cluster creation or cluster missing we won't have a ClusterId
if ($null -eq $gatewayClusterId) {
    # Surface last error detail
    $lastError = Resolve-DataGatewayError -Last
    $logger.Log($lastError.Message)
    Write-Host($lastError.Message)

    $progressMsg = "Error: Data Gateway Cluster not created or found, check if Gateway Name: '$GatewayName' already exists, the status and supplied RegionKey: '$RegionKey'"
    $logger.Log($progressMsg)
    Write-Error($progressMsg)
    exit 1
}

# Optionally add additional user as an admin for this data gateway
if (!([string]::IsNullOrEmpty($GatewayAdminUserIds))) {
    $GatewayAdminUserIdArray = $GatewayAdminUserIds -split ','
    $GatewayAdminUserIdArray.foreach{
        [GUID]$userGuid = $PSItem
        $progressMsg = "Adding Data Gateway admin user: '$userGuid'"
        $logger.Log($progressMsg)
        Write-Host($progressMsg)
        Add-DataGatewayClusterUser @regionKeyParam -GatewayClusterId $gatewayClusterId -PrincipalObjectId $userGuid -AllowedDataSourceTypes $null -Role Admin

        # Check the user was added ok
        if ((Get-DataGatewayCluster @regionKeyParam -Cluster $gatewayClusterId | Select-Object -ExpandProperty Permissions | Where-Object { $_.Id -eq $userGuid }).Length -ne 0) {
            $progressMsg = "Data Gateway admin user added"
            $logger.Log($progressMsg)
            Write-Host($progressMsg)
        }
        else {
            # Surface last error detail
            $lastError = Resolve-DataGatewayError -Last
            $logger.Log($lastError.Message)
            Write-Host($lastError.Message)            

            $progressMsg = "Warning! Data Gateway admin user not added"
            $logger.Log($progressMsg)
            Write-Warning($progressMsg)
        }
    }
} else {
    $progressMsg = "Warning! No additional Data Gateway admins have been set - you will only be able to use the AAD App credentials used to manage this cluster"
    $logger.Log($progressMsg)
    Write-Warning($progressMsg)
}

# Retrieve the cluster status
$cs = (Get-DataGatewayClusterStatus -GatewayClusterId $gatewayClusterId @regionKeyParam)
$progressMsg = "Cluster '$gatewayClusterId' ClusterStatus: '$($cs.ClusterStatus)' GatewayVersion: '$($cs.GatewayVersion)' GatewayUpgradeState: '$($cs.GatewayUpgradeState)'"
$logger.Log($progressMsg)
Write-Host($progressMsg)

# Status other than Live indicates issue
if ('Live' -ne $cs.ClusterStatus) {
    # Surface last error detail
    $lastError = Resolve-DataGatewayError -Last
    $logger.Log($lastError.Message)
    Write-Host($lastError.Message)

    $progressMsg = "Error: Power BI Gateway not started!"
    $logger.Log($progressMsg)
    Write-Host($progressMsg)
    exit 1
}
else {
    $progressMsg = "Finished pbiGateway.ps1"
    $logger.Log($progressMsg)
    Write-Host($progressMsg)
}
