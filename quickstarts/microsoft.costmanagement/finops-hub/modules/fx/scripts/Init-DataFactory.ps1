# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

<#
.SYNOPSIS
Manages Azure Data Factory triggers and pipelines during FinOps hub deployment.

.DESCRIPTION
This script is called by Bicep deployment scripts to start/stop Data Factory triggers
and optionally run pipelines. It handles two types of triggers:

1. Schedule triggers - Can be started/stopped directly
2. BlobEventsTriggers - Require Event Grid subscription management before start/stop

BlobEventsTriggers use Event Grid to listen for storage blob events. Before stopping,
the Event Grid subscription must be removed (unsubscribed). Before starting, the
subscription must be added and fully provisioned. This script handles this automatically
by detecting BlobEventsTriggers via the BlobPathBeginsWith property.

The script uses retry logic with linear backoff to handle transient API failures and
wait for Event Grid subscription provisioning/deprovisioning to complete.

.PARAMETER DataFactoryResourceGroup
The resource group containing the Data Factory.

.PARAMETER DataFactoryName
The name of the Data Factory instance.

.PARAMETER Pipelines
Pipe-delimited list of pipeline names to run (e.g., "pipeline1|pipeline2").

.PARAMETER StartTriggers
Switch to start all stopped triggers (with Event Grid subscription for blob triggers).

.PARAMETER StopTriggers
Switch to stop all running triggers (with Event Grid unsubscription for blob triggers).

.EXAMPLE
.\Init-DataFactory.ps1 -DataFactoryResourceGroup "rg-hub" -DataFactoryName "adf-hub" -StopTriggers

.EXAMPLE
.\Init-DataFactory.ps1 -DataFactoryResourceGroup "rg-hub" -DataFactoryName "adf-hub" -StartTriggers
#>

param(
    [string] $DataFactoryResourceGroup,
    [string] $DataFactoryName,
    [string] $Pipelines = "",
    [switch] $StartTriggers,
    [switch] $StopTriggers
)

$MAX_RETRIES = 20
$DeploymentScriptOutputs = @{}

function Write-Log($Message)
{
    Write-Output "$(Get-Date -Format 'HH:mm:ss') $Message"
}

function Invoke-WithRetry([scriptblock]$Action, [string]$Name, [int]$Delay = 5)
{
    for ($i = 1; $i -le $MAX_RETRIES; $i++)
    {
        try { return & $Action }
        catch
        {
            Write-Log "$Name failed (attempt $i/${MAX_RETRIES}): $($_.Exception.Message)"
            if ($i -eq $MAX_RETRIES) { throw }
            Start-Sleep -Seconds ($Delay * $i)
        }
    }
}

function Set-BlobTriggerSubscription([string]$TriggerName, [switch]$Subscribe)
{
    $targetStatus = if ($Subscribe) { 'Enabled' } else { 'Disabled' }
    $action = if ($Subscribe) { 'Subscribing' } else { 'Unsubscribing' }

    Write-Log "$action $TriggerName to events..."

    # Check current status before attempting subscribe/unsubscribe
    $currentStatus = (Get-AzDataFactoryV2TriggerSubscriptionStatus `
            -ResourceGroupName $DataFactoryResourceGroup `
            -DataFactoryName $DataFactoryName `
            -Name $TriggerName).Status

    if ($currentStatus -eq $targetStatus)
    {
        Write-Log "$TriggerName subscription is already $targetStatus, skipping."
        return
    }

    if ($currentStatus -eq 'Provisioning' -or $currentStatus -eq 'Deprovisioning')
    {
        Write-Log "$TriggerName subscription is $currentStatus, waiting for completion..."
    }
    else
    {
        # Only call subscribe/unsubscribe when not already in a transitional state
        if ($Subscribe)
        {
            Add-AzDataFactoryV2TriggerSubscription `
                -ResourceGroupName $DataFactoryResourceGroup `
                -DataFactoryName $DataFactoryName `
                -Name $TriggerName | Out-Null
        }
        else
        {
            Remove-AzDataFactoryV2TriggerSubscription `
                -ResourceGroupName $DataFactoryResourceGroup `
                -DataFactoryName $DataFactoryName `
                -Name $TriggerName | Out-Null
        }
    }

    # Poll until provisioning completes
    Invoke-WithRetry -Name "$action status $TriggerName" -Delay 5 -Action {
        $status = Get-AzDataFactoryV2TriggerSubscriptionStatus `
            -ResourceGroupName $DataFactoryResourceGroup `
            -DataFactoryName $DataFactoryName `
            -Name $TriggerName
        if ($status.Status -ne $targetStatus)
        {
            throw "Subscription status is $($status.Status), expected $targetStatus"
        }
    }
}

if ($StartTriggers -or $StopTriggers)
{
    $triggers = Invoke-WithRetry -Name "Get triggers" -Action {
        Get-AzDataFactoryV2Trigger `
            -ResourceGroupName $DataFactoryResourceGroup `
            -DataFactoryName $DataFactoryName `
        | Where-Object {
            ($StartTriggers -and $_.Properties.RuntimeState -ne "Started") `
                -or ($StopTriggers -and $_.Properties.RuntimeState -ne "Stopped")
        }
    }

    Write-Log "Found $($triggers.Count) trigger(s) to $(if ($StartTriggers) { 'start' } else { 'stop' })"

    $triggers | ForEach-Object {
        $triggerName = $_.Name
        $isBlobTrigger = $null -ne $_.Properties.BlobPathBeginsWith

        if ($StopTriggers)
        {
            if ($isBlobTrigger) { Set-BlobTriggerSubscription -TriggerName $triggerName }
            Write-Log "Stopping trigger $triggerName..."
            Invoke-WithRetry -Name "Stop $triggerName" -Action {
                Stop-AzDataFactoryV2Trigger `
                    -ResourceGroupName $DataFactoryResourceGroup `
                    -DataFactoryName $DataFactoryName `
                    -Name $triggerName -Force
            }
        }
        else
        {
            if ($isBlobTrigger) { Set-BlobTriggerSubscription -TriggerName $triggerName -Subscribe }
            Write-Log "Starting trigger $triggerName..."
            Invoke-WithRetry -Name "Start $triggerName" -Action {
                Start-AzDataFactoryV2Trigger `
                    -ResourceGroupName $DataFactoryResourceGroup `
                    -DataFactoryName $DataFactoryName `
                    -Name $triggerName -Force
            }
        }

        Invoke-WithRetry -Name "Wait for $triggerName" -Action {
            $state = (Get-AzDataFactoryV2Trigger `
                    -ResourceGroupName $DataFactoryResourceGroup `
                    -DataFactoryName $DataFactoryName `
                    -Name $triggerName).Properties.RuntimeState
            $expected = if ($StartTriggers) { 'Started' } else { 'Stopped' }
            if ($state -ne $expected) { throw "Trigger is $state, expected $expected" }
        }

        Write-Log "...done"
        $DeploymentScriptOutputs[$triggerName] = $true
    }
}

if (-not [string]::IsNullOrWhiteSpace($Pipelines))
{
    $Pipelines.Split('|') | ForEach-Object {
        Write-Log "Running pipeline $_..."
        Invoke-AzDataFactoryV2Pipeline `
            -ResourceGroupName $DataFactoryResourceGroup `
            -DataFactoryName $DataFactoryName `
            -PipelineName $_
    }
}
