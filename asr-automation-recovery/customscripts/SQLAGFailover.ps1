Param(
    [string]$SQLAvailabilityGroupPath
 )
 import-module sqlps
 Switch-SqlAvailabilityGroup -Path $SQLAvailabilityGroupPath -AllowDataLoss -force
