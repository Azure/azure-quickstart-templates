[CmdletBinding()]
param (
    # Enter the resource group name as string
    [Parameter(Mandatory = $true)]
    [Alias("rg")]
    [string]
    $ResourceGroupName,

    # Enter Location of ResourceGroup as string
    [Parameter(Mandatory = $true)]
    [string]
    $Location,

    # Enter emailId to get DDoS attack alert
    [Parameter(Mandatory = $true)]
    [Alias("user")]
    [string]
    $Email
)

Write-Verbose "Configurating email alert at metrics level "
#Getting the resource Id of Public IP
$resourceId = (Get-AzureRmResource -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Network/publicIPAddresses).ResourceId
Write-Verbose "got resourceid "

$actionEmail = New-AzureRmAlertRuleEmail -CustomEmail $Email -WarningAction SilentlyContinue
Write-Verbose "got action email "

# Configuring the Metrics Alert rule for under DDoS attack status
Add-AzureRmMetricAlertRule -Name "DDoS attack alert" -ResourceGroup $ResourceGroupName -location $Location -TargetResourceId $resourceId -MetricName "IfUnderDDoSAttack" -Operator GreaterThanOrEqual -Threshold 1 -WindowSize 00:05:00 -TimeAggregationOperator Total -Action $actionEmail -Description "Under DDoS attack alert"
Write-Verbose "metric rule created"