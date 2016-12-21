workflow container1 {
    param(
     
        [Parameter(Mandatory=$true)]
        [string]
        $adfStorageAccName,

        [Parameter(Mandatory=$true)]
        [string]
        $adfStorageAccKey
    )

    InlineScript{

   
    $adfStorageAccName = $Using:adfStorageAccName
    $adfStorageAccKey = $Using:adfStorageAccKey

    Write-Output $adfStorageAccName,
    Write-Output $adfStorageAccKey

    $storageCtx = New-AzureStorageContext -StorageAccountName $adfStorageAccName -StorageAccountKey $adfStorageAccKey
	
    New-AzureStorageContainer -Name "adfgetstarted" -Context $storageCtx

    }
    
}
