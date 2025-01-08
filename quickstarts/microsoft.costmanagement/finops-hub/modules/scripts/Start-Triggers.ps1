# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

Param(
    [switch] $Stop
)

# Init outputs
$DeploymentScriptOutputs = @{}

if (-not $Stop)
{
    Start-Sleep -Seconds 10
}

# Loop thru triggers
$env:Triggers.Split('|') `
| ForEach-Object {
    $trigger = $_
    if ($Stop)
    {
        Write-Output "Stopping trigger $trigger..."
        $triggerOutput = Stop-AzDataFactoryV2Trigger `
            -ResourceGroupName $env:DataFactoryResourceGroup `
            -DataFactoryName $env:DataFactoryName `
            -Name $trigger `
            -Force `
            -ErrorAction SilentlyContinue # Ignore errors, since the trigger may not exist
    }
    else
    {
        Write-Output "Starting trigger $trigger..."
        $triggerOutput = Start-AzDataFactoryV2Trigger `
            -ResourceGroupName $env:DataFactoryResourceGroup `
            -DataFactoryName $env:DataFactoryName `
            -Name $trigger `
            -Force
    }
    if ($triggerOutput)
    {
        Write-Output "done..."
    }
    else
    {
        Write-Output "failed..."
    }
    $DeploymentScriptOutputs[$trigger] = $triggerOutput
}

if ($Stop)
{
    Start-Sleep -Seconds 10
}

if (-not [string]::IsNullOrWhiteSpace($env:Pipelines))
{
    $env:Pipelines.Split('|') `
    | ForEach-Object {
        Write-Output "Running the init pipeline..."
        Invoke-AzDataFactoryV2Pipeline `
            -ResourceGroupName $env:DataFactoryResourceGroup `
            -DataFactoryName $env:DataFactoryName `
            -PipelineName $_
    }
}
