# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

Param(
    [switch] $Stop
)

# Init outputs
$DeploymentScriptOutputs = @{}

if (-not $Stop) {
    Start-Sleep -Seconds 10
}

# Loop thru triggers
$env:Triggers.Split('|') `
| ForEach-Object {
    $trigger = $_
    if ($Stop) {
        Write-Host "Stopping trigger $trigger..." -NoNewline
        $triggerOutput = Stop-AzDataFactoryV2Trigger `
            -ResourceGroupName $env:DataFactoryResourceGroup `
            -DataFactoryName $env:DataFactoryName `
            -Name $trigger `
            -Force `
            -ErrorAction SilentlyContinue # Ignore errors, since the trigger may not exist
    } else {
        Write-Host "Starting trigger $trigger..." -NoNewline
        $triggerOutput = Start-AzDataFactoryV2Trigger `
            -ResourceGroupName $env:DataFactoryResourceGroup `
            -DataFactoryName $env:DataFactoryName `
            -Name $trigger `
            -Force
    }
    if ($triggerOutput) { 
        Write-Host 'done'
    } else {
        Write-Host 'failed'
    }
    $DeploymentScriptOutputs[$trigger] = $triggerOutput
}

if ($Stop) {
    Start-Sleep -Seconds 10
}
