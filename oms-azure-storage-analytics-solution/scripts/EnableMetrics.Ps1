
# define metrics to enable on Storage Analytics
$services=@('Blob','Table','Queue','File')
$sacount=0
$satracking=0


#region  Get classic Strorage Accounts

$SAClassic=Get-AzureStorageAccount

IF($SAClassic)
{

    foreach($obj in $SAClassic)
    {
        # check and enable storage metircs 
        $sacount++
        
        Foreach ($svc in $services)
        {
            IF(  (Get-AzureStorageServiceMetricsProperty -ServiceType $svc  -MetricsType Minute -Context $obj.Context).MetricsLevel.value__ -eq 0)
            {
              Set-AzureStorageServiceMetricsProperty -MetricsType Minute -ServiceType $svc  -MetricsLevel ServiceAndApi -RetentionDays 1 -Context $obj.Context
              Write-host "Enabling Minute Metrics for $svc  on  $($obj.StorageAccountName)"
              $satracking++
            }

        }
    }

}
#endregion



#region Get ARM based Storage Accounts

$SAArm=Get-AzureRmStorageAccount

$obj=$null

IF($SAArm)
{
    foreach($obj in $SAArm)
        {
           $sacount++
           Foreach ($svc in $services)
            {
                IF(  (Get-AzureStorageServiceMetricsProperty -ServiceType $svc  -MetricsType Minute -Context $obj.Context).MetricsLevel.value__ -eq 0)
                {
                    Set-AzureStorageServiceMetricsProperty -MetricsType Minute -ServiceType $svc  -MetricsLevel ServiceAndApi -RetentionDays 1 -Context $obj.Context
                    Write-host "Enabling Minute Metrics for $svc  on  $($obj.StorageAccountName)"
                    $satracking++
                }

            }
         }
}

#endregion

"$sacount storage accounts processed , $satracking  metrics enabled."






