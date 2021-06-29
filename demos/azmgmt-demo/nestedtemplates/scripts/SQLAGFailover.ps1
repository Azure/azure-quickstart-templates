# This script gets called from Automation Runbook ASR-SQL-FailoverAG
Param(
    [string] $Path
 )
 import-module sqlps
 Switch-SqlAvailabilityGroup -Path $Path -AllowDataLoss -force
