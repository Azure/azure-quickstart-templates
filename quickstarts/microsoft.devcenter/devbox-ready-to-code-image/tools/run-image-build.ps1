$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
$ProgressPreference = 'SilentlyContinue'

RunWithRetries { Connect-AzAccount -Identity | Out-Null }
RunWithRetries { Install-Module -Name Az.ImageBuilder -AllowPrerelease -Force | Out-Null }

Write-Host "=== Starting the image build"
RunWithRetries {
    Invoke-AzResourceAction -ResourceName "${env:imageTemplateName}" -ResourceGroupName "${env:resourceGroupName}" -ResourceType "Microsoft.VirtualMachineImages/imageTemplates" -ApiVersion "2020-02-14" -Action Run -Force
}

Write-Host "=== Waiting for the image build to complete"

# https://learn.microsoft.com/en-us/dotnet/api/microsoft.azure.powershell.cmdlets.imagebuilder.support.runstate?view=az-ps-latest
$global:status = 'UNKNOWN'
while ($global:status -ne 'Succeeded' -and $global:status -ne 'Failed' -and $global:status -ne 'Canceled') { 
    Start-Sleep -Seconds 15
    RunWithRetries {
        $global:info = Get-AzImageBuilderTemplate -ImageTemplateName ${env:imageTemplateName} -ResourceGroupName ${env:resourceGroupName}
        $global:status = $info.LastRunStatusRunState
    }
}

$buildStatusShort = "status '$global:status', message '$($global:info.LastRunStatusMessage)'"
Write-Host "=== Image build completed with $buildStatusShort"

$ignoreBuildFailure = [bool]::Parse("${env:ignoreBuildFailure}")
if ( (!$ignoreBuildFailure) -and ($global:status -ne 'Succeeded')) {
    Start-Sleep -Seconds 15 # Appears to help with the script output being captured in full
    Write-Error "!!! [ERROR] Image build failed with $buildStatusShort"
}

$printCustomizationLogLastLines = [int]::Parse("${env:printCustomizationLogLastLines}")
if ($printCustomizationLogLastLines -ne 0) {

    $stagingResourceGroupName = ${env:stagingResourceGroupName}
    $logsFile = 'customization.log'
    Write-Host "=== Looking for storage account in staging RG '$stagingResourceGroupName'"
    $stagingStorageAccountName = (Get-AzResource -ResourceGroupName $stagingResourceGroupName -ResourceType "Microsoft.Storage/storageAccounts")[0].Name

    $stagingStorageAccountKey = $(Get-AzStorageAccountKey -StorageAccountName $stagingStorageAccountName -ResourceGroupName $stagingResourceGroupName)[0].value
    $ctx = New-AzStorageContext -StorageAccountName $stagingStorageAccountName -StorageAccountKey $stagingStorageAccountKey
    $logsBlob = Get-AzStorageBlob -Context $ctx -Container packerlogs | Where-Object { $_.Name -like "*/$logsFile" }
    if ($logsBlob) {
        Write-Host "=== Downloading $logsFile from storage account '$stagingStorageAccountName'"
        Get-AzStorageBlobContent -Context $ctx -CloudBlob $logsBlob.ICloudBlob -Destination $logsFile -Force | Format-List

        if ($printCustomizationLogLastLines -gt 0) {
            Write-Host "=== Last $printCustomizationLogLastLines lines of $logsFile :`n"
            Write-Host "$(Get-Content $logsFile -Tail $printCustomizationLogLastLines | Out-String)"
        }
        else {
            Write-Host "=== Content of $logsFile :`n"
            Write-Host "$(Get-Content $logsFile | Out-String)"
        }
    }
    else {
        Write-Host "Could not find customization.log in storage account: $stagingStorageAccountName"
    }
}

Write-Host "=== DONE"
Start-Sleep -Seconds 15 # Appears to help with the script output being captured in full
