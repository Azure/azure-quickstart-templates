# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

param
(
    [switch]
    $storage,

    [switch]
    $dataFactory
)

$maxRetries = 5
$retryInterval = 180 # seconds

for ($i = 1; $i -le $maxRetries; $i++) {

    If ($dataFactory) {
        try {
            $trigger = Get-AzDataFactoryV2Trigger -DataFactoryName $env:dataFactoryName -ResourceGroupName $env:resourceGroupName -TriggerName msexports | Where-Object { $_.RuntimeState -eq "Started" }

            If ($trigger.RuntimeState -eq "Started") {
                Remove-AzUserAssignedIdentity -Name $env:managedIdentityName -ResourceGroupName $env:resourceGroupName
                Write-Output "Operation succeeded. Managed identity: $env:managedIdentityName has been removed."
                break
            }
            trow
        }
        catch {
            Write-Output "Operation failed. Retrying in $retryInterval seconds..."
            Start-Sleep -Seconds $retryInterval
        }
    }

    If ($storage) {
        try {
            $ctx = New-AzStorageContext -StorageAccountName $env:storageAccountName -UseConnectedAccount
            $settingsFile = Get-AzStorageBlob -Container $env:containerName -Context $ctx -Blob settings.json

            If ($settingsFile) {
                Remove-AzUserAssignedIdentity -Name $env:managedIdentityName -ResourceGroupName $env:resourceGroupName
                Write-Output "Operation succeeded. Managed identity: $env:managedIdentityName has been removed."
                break
            }
            trow
        }
        catch {
            Write-Output "Operation failed. Retrying in $retryInterval seconds..."
            Start-Sleep -Seconds $retryInterval
        }
    }
}

if ($i -gt $maxRetries) {
    Write-Output "Operation failed after $maxRetries attempts."
}