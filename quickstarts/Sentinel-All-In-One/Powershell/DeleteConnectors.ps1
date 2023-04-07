param(
    [Parameter(Mandatory=$true)]$ResourceGroup,
    [Parameter(Mandatory=$true)]$Workspace,    
    [Parameter(Mandatory=$true)]$Location
)

function CheckModules($module) {
    $installedModule = Get-InstalledModule -Name $module -ErrorAction SilentlyContinue
    if ($null -eq $installedModule) {
        Write-Warning "The $module PowerShell module is not found"
        #check for Admin Privleges
        $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

        if (-not ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {
            #Not an Admin, install to current user
            Write-Warning -Message "Can not install the $module module. You are not running as Administrator"
            Write-Warning -Message "Installing $module module to current user Scope"
            Install-Module -Name $module -Scope CurrentUser -Force
            Import-Module -Name $module -Force
        }
        else {
            #Admin, install to all users
            Write-Warning -Message "Installing the $module module to all users"
            Install-Module -Name $module -Force
            Import-Module -Name $module -Force
        }
    }
    #Install-Module will obtain the module from the gallery and install it on your local machine, making it available for use.
    #Import-Module will bring the module and its functions into your current powershell session, if the module is installed.  
}

function DeleteDataConnector ($dataConnector, $dataConUri) {
    #Enable or Update AzureActivityLog Connector with http put method
    try {
        $deleteResponse = Invoke-AzRestMethod -Path $dataConUri -Method DELETE
        if ($deleteResponse.StatusCode -eq 200) {            
            Write-Host "Successfully deleted Data connector: $($dataConnector)" -ForegroundColor Green                        
        }
        else {
            Write-Host "Unable to delete Data connector $($dataConnector) with error: $($deleteResponse.message)" 
        }           
                    
    }
    catch {
        $errorReturn = $_
        Write-Verbose $_.Exception.Message
        Write-Error "Unable to invoke webrequest with error message: $errorReturn" -ErrorAction Stop
    }
    
}

CheckModules("Az.Resources")
CheckModules("Az.OperationalInsights")
CheckModules("Az.SecurityInsights")

Write-Host "`r`nYou will now be asked to log in to your Azure environment. `nFor this script to work correctly, you need to provide credentials of a Global Admin or Security Admin for your organization. `nThis will allow the script to enable all required connectors.`r`n" -BackgroundColor Magenta

Read-Host -Prompt "Press enter to continue or CTRL+C to quit the script" 

$context = Get-AzContext

if(!$context){
    Connect-AzAccount
    $context = Get-AzContext
}

$SubscriptionId = $context.Subscription.Id

$ConnectorsFile = "$PSScriptRoot\connectors.json"

#Check Resource Group Existing or not
Get-AzResourceGroup -Name $ResourceGroup -ErrorVariable notPresent -ErrorAction SilentlyContinue
if ($notPresent){        
    Write-Host "ResourceGroup $($ResourceGroup) associated to Log Analytics Workspace - not found"
    Write-Host "Exiting.................." -ForegroundColor Red
    break
}

#Check Log Analytics workspace Existing or not
try {
    $WorkspaceObject = Get-AzOperationalInsightsWorkspace -Name $Workspace -ResourceGroupName $ResourceGroup  -ErrorAction Stop
    $ExistingLocation = $WorkspaceObject.Location
    Write-Output "Workspace $Workspace in region $ExistingLocation exists."
} catch {
    Write-Output "Provided Log Analytics Workspace $Workspace not found"
    Write-Host "Exiting.................." -ForegroundColor Red
    break
}

#Urls to be used for Sentinel API calls
$baseUri = "/subscriptions/${SubscriptionId}/resourceGroups/${ResourceGroup}/providers/Microsoft.OperationalInsights/workspaces/${Workspace}"

#Getting all data connectors connector to workspace
try{
    $connectorsUri = "$baseUri/providers/Microsoft.SecurityInsights/dataConnectors/?api-version=2020-01-01"
    $connectedDataConnectors = (Invoke-AzRestMethod -Path $connectorsUri -Method GET).Content | ConvertFrom-Json
    if ($connectedDataConnectors.value.Length -eq 0)
    {
        Write-Host "There were no Data connectors enabled on your Workspace $($Workspace)"
        Write-Host "Exiting.................." -ForegroundColor Red
        break
    }
}
catch {
    $errorReturn = $_
    Write-Error "Unable to invoke webrequest with error message: $errorReturn" -ErrorAction Stop
}
#Getting all rules from file
$connectorsToDelete = Get-Content -Raw -Path $ConnectorsFile | ConvertFrom-Json

foreach ($toBeDeletedConnector in $connectorsToDelete.connectors) {   
    
    foreach ($dataConnector in $connectedDataConnectors.value){
        # Check if ASC is already enabled (assuming there will be only one ASC per workspace)
        if ($dataConnector.kind -eq $toBeDeletedConnector.kind) {
            Write-Host "`r`nProcessing connector: " -NoNewline 
            Write-Host "$($dataConnector.kind)" -ForegroundColor Blue
            Write-Host "Data connector $($dataConnector.kind) - enabled"
            Write-Verbose $dataConnector
            $guid = $dataConnector.name                    
            $dataConnectorUri = "${baseUri}/providers/Microsoft.SecurityInsights/dataConnectors/${guid}?api-version=2020-01-01"
            DeleteDataConnector $dataConnector.kind $dataConnectorUri
            break     
        }        
    }    
}