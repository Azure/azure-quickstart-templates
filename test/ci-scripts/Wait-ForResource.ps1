<#

This script will query regional endpoints directly to determine if replication is complete

#>

param( 
    $resourceId,
    $apiVersion,
    $timeOutSeconds = 60
)

$token = Get-AzAccessToken

$headers = @{
    'Content-Type'  = 'application/json'
    'Authorization' = 'Bearer ' + $token.Token
}

# locations can be dynamically fetched (for cross-cloud support or hardcoded)
# to query, the user needs permission to do so
$locations = @()
$azureLocations = ((Invoke-AzRestMethod -Method GET -Path "/locations?api-version=2022-01-01").content | ConvertFrom-Json -Depth 100).value
foreach($l in $azureLocations){
    if($l.metadata.RegionType -eq "Physical"){
        $locations += $l.name
        #Write-Host $l.name + $l.metadata.RegionType
    }
}

# list of locations is hard-coded so the user querying the resource does not need permissions at subscription scope for the /locations api
# this will need to be updated periodically, but in practice probably not immediately since 100% replication is generally not needed
# $locations = @(
#     "eastasia",
#     "southeastasia",
#     "centralus",
#     "eastus",
#     "eastus2",
#     "westus",
#     "northcentralus",
#     "southcentralus",
#     "northeurope",
#     "westeurope",
#     "japanwest",
#     "japaneast",
#     "brazilsouth",
#     "australiaeast",
#     "australiasoutheast",
#     "southindia",
#     "centralindia",
#     "westindia",
#     "jioindiawest",
#     "jioindiacentral",
#     "canadacentral",
#     "canadaeast",
#     "uksouth",
#     "ukwest",
#     "westcentralus",
#     "westus2",
#     "koreacentral",
#     "koreasouth",
#     "francecentral",
#     "francesouth",
#     "australiacentral",
#     "australiacentral2",
#     "uaecentral",
#     "uaenorth",
#     "southafricanorth",
#     "southafricawest",
#     "switzerlandnorth",
#     "switzerlandwest",
#     "germanynorth",
#     "germanywestcentral",
#     "norwaywest",
#     "norwayeast",
#     "brazilsoutheast",
#     "westus3",
#     "swedencentral",
#     "qatarcentral"
# )

# set ENV var with the result as expected, any location that doesn't find it will set to false
$env:FOUND = $true

# get the top level domain from the PS environment
$endpoint = (Get-AzContext).Environment.ResourceManagerUrl.Split('/')[2]

$locations | ForEach-Object -Parallel {

    # AzureGov regional endpoints are seemingly random, so we need to MAP those...
    switch ($_) {
        "usgovvirginia" {  
            $region = "usgoveast"
        }
        "usgovtexas" { 
            $region = "usgovsc"
        }
        "usgovarizona" { 
            $region = "usgovsw"
        }
        "usgoviowa" { 
            $region = "usgovcentral"
        }
        Default {
            $region = $_
        }
    }

    $uri = "https://$region.$($using:endpoint)/$($using:resourceId)?api-version=$($using:apiVersion)"

    $r = $null
    $stopTime = (Get-Date).AddSeconds($using:timeOutSeconds)

    While ($r -eq $null -and $(Get-Date) -lt $stopTime) {
        try {
            Write-Host $uri
            $r = Invoke-RestMethod -Headers $using:headers -Method "GET" $uri
        }
        catch {}

        if ($r -eq $null) {
            Write-Warning "Not found in $_"
            Start-Sleep 3
        }
        else {
            Write-Host "response:`n$r`n... from $_" -ForegroundColor Green
        }

    }

    if($r -eq $null){
        $env:FOUND = $false
    }
    
}

$DeploymentScriptOutputs = @{}
$DeploymentScriptOutputs['ResourceFound'] = $env:FOUND
Write-Host $DeploymentScriptOutputs['ResourceFound']