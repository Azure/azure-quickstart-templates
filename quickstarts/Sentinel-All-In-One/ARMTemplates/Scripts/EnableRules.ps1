param(
    [Parameter(Mandatory=$true)][string]$ResourceGroup,
    [Parameter(Mandatory=$true)][string]$Workspace,
    [Parameter(Mandatory=$true)][string[]]$Connectors
)

$context = Get-AzContext

if(!$context){
    Connect-AzAccount
    $context = Get-AzContext
}

$SubscriptionId = $context.Subscription.Id

Write-Host "Connected to Azure with subscription: " + $context.Subscription

$baseUri = "/subscriptions/${SubscriptionId}/resourceGroups/${ResourceGroup}/providers/Microsoft.OperationalInsights/workspaces/${Workspace}"
$templatesUri = "$baseUri/providers/Microsoft.SecurityInsights/alertRuleTemplates?api-version=2019-01-01-preview"
$alertUri = "$baseUri/providers/Microsoft.SecurityInsights/alertRules/"


try {
    $alertRulesTemplates = ((Invoke-AzRestMethod -Path $templatesUri -Method GET).Content | ConvertFrom-Json).value
}
catch {
    Write-Verbose $_
    Write-Error "Unable to get alert rules with error code: $($_.Exception.Message)" -ErrorAction Stop
}

$return = @()

if ($Connectors){
    foreach ($item in $alertRulesTemplates) {
        if ($item.kind -eq "Scheduled"){
            foreach ($connector in $item.properties.requiredDataConnectors) {
                if ($connector.connectorId -in $Connectors){
                    #$return += $item.properties
                    $guid = New-Guid
                    $alertUriGuid = $alertUri + $guid + '?api-version=2020-01-01'

                    $properties = @{
                        displayName = $item.properties.displayName
                        enabled = $true
                        suppressionDuration = "PT5H"
                        suppressionEnabled = $false
                        alertRuleTemplateName = $item.name
                        description = $item.properties.description
                        query = $item.properties.query
                        queryFrequency = $item.properties.queryFrequency
                        queryPeriod = $item.properties.queryPeriod
                        severity = $item.properties.severity
                        tactics = $item.properties.tactics
                        triggerOperator = $item.properties.triggerOperator
                        triggerThreshold = $item.properties.triggerThreshold
                    }

                    $alertBody = @{}
                    $alertBody | Add-Member -NotePropertyName kind -NotePropertyValue $item.kind -Force
                    $alertBody | Add-Member -NotePropertyName properties -NotePropertyValue $properties

                    try{
                        Invoke-AzRestMethod -Path $alertUriGuid -Method PUT -Payload ($alertBody | ConvertTo-Json -Depth 3)
                    }
                    catch {
                        Write-Verbose $_
                        Write-Error "Unable to create alert rule with error code: $($_.Exception.Message)" -ErrorAction Stop
                    }

                    break
                }
            }
        }
    }
}

return $return