
param (
    [Parameter (Mandatory= $false)]
    [string] $resourcegroup,

    [Parameter (Mandatory= $false)]
    [string] $targetSubscriptionId,

    [Parameter (Mandatory= $false)]
    [string] $automationaccount,

    [Parameter (Mandatory= $false)]
    [string] $deleteList 
)

$ErrorActionPreference = "SilentlyContinue"

if ((-not ($deleteList)) -or (-not ($resourcegroup)) -or (-not ($automationaccount)))
{
    return "Exiting:  Input is null"
}

If ($deleteList -eq "VMManagement") {
    $delTask = "Runbook=StartByResourceGroup-MS-Mgmt-VM;Runbook=StopByResourceGroup-MS-Mgmt-VM;Runbook=SendMailO365-MS-Mgmt;Schedule=StartByResourceGroup-Schedule-MS-Mgmt;Schedule=StopByResourceGroup-Schedule-MS-Mgmt"
}
elseif ($deleteList -eq "SQLAnalytic") {
    $delTask = "Runbook=SqlAzureIngestion-MS-Mgmt-SQL;Runbook=CreateSchedules-MS-Mgmt-SQL;Runbook=Update-ModulesInAutomationToLatestVersion;Runbook=SQLAzureElasticPoolsMetrics-MS-Mgmt-SQL;Runbook=AzureStoageMetricsEnablerScheduler-MS-Mgmt-SA;Schedule=SqlAzureIngestion-Schedule-MS-Mgmt-SQL-1;Schedule=SqlAzureIngestion-Schedule-MS-Mgmt-SQL-2;Schedule=SqlAzureIngestion-Schedule-MS-Mgmt-SQL-3;Schedule=SqlAzureIngestion-Schedule-MS-Mgmt-SQL-4;Schedule=SqlAzureIngestion-Schedule-MS-Mgmt-SQL-5;Schedule=SqlAzureIngestion-Schedule-MS-Mgmt-SQL-6;Schedule=SQLAzureElasticPoolsMetrics-Schedule-MS-Mgmt-SQL-1;Schedule=SQLAzureElasticPoolsMetrics-Schedule-MS-Mgmt-SQL-2"
}
elseif ($deleteList -eq "AzSAAnalytic") {
    $delTask = "Runbook=AzureSAIngestionParent-MS-Mgmt-SA;Runbook=AzureSAIngestionChild-MS-Mgmt-SA;Runbook=CreateSchedules-MS-Mgmt-SA;Runbook=AzureStorageMetricsEnabler-MS-Mgmt-SA;Schedule=AzureStorageIngestionParent-HourlySchedule-MS-Mgmt-SA;Schedule=AzureStorageMetricsEnabler-Schedule-MS-Mgmt-SA;Variable=AzureSAIngestion-OPSINSIGHTS_WS_ID-MS-Mgmt-SA;Variable=AzureSAIngestion-OPSINSIGHTS_WS_KEY-MS-Mgmt-SA;Variable=AzureSAIngestion-AzureAutomationAccount-MS-Mgmt-SA;Variable=AzureSAIngestion-AzureAutomationResourceGroup-MS-Mgmt-SA"
}
else {
    return "Exiting:  Delete option invalid"
}
#
# Initialize the Azure subscription we will be working against for AzureRM resources
#
Write-Verbose "Authenticating ARM RunAs account"
$connectionName = "AzureRunAsConnection"
# Get the connection "AzureRunAsConnection "
Write-Verbose "Logging in to Azure..."

# retry
$retry = 6
$syncOk = $false
$servicePrincipalConnection = Get-AutomationConnection -Name $connectionName 
do
{ 
	try
	{  
		Add-AzureRmAccount -ServicePrincipal -TenantId $servicePrincipalConnection.TenantId -ApplicationId $servicePrincipalConnection.ApplicationId -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint
		$syncOk = $true
	}
	catch
	{
		$ErrorMessage = $_.Exception.Message
		$StackTrace = $_.Exception.StackTrace
		Write-Warning "Error during sync: $ErrorMessage, stack: $StackTrace. Retry attempts left: $retry"
		$retry = $retry - 1       
		Start-Sleep -s 60        
	}
} while (-not $syncOk -and $retry -ge 0)

Select-AzureRMSubscription -SubscriptionId $targetSubscriptionId -TenantId $servicePrincipalConnection.TenantId
$currentSubscription = Get-AzureRMSubscription -SubscriptionId $targetSubscriptionId -TenantId $servicePrincipalConnection.TenantId
Write-Verbose "Found ARM subscription [$($currentSubscription.SubscriptionName)] ($($currentSubscription.SubscriptionId))"

$dList = $delTask.split(";")
foreach ($item in $dList)
{
    $actionItem = $item.split("=")
    if ($actionItem.Count -eq 2)
    {
        if ($actionItem[0] -eq "Runbook")
        {
            Write-Verbose "CleanUp:  Removing runbook $actionItem[1]"
            Remove-AzureRmAutomationRunbook -Name $actionItem[1] -AutomationAccountName $automationaccount -ResourceGroupName $resourcegroup -Force 
        } 
        elseif ($actionItem[0] -eq "Schedule")
        {
            Write-Verbose "CleanUp:  Removing schedule $actionItem[1]"
            Remove-AzureRmAutomationSchedule -Name $actionItem[1] -AutomationAccountName $automationaccount -ResourceGroupName $resourcegroup -Force
            IF($deleteList -eq "AzSAAnalytic")
            {
            $RBsch=Get-AzureRmAutomationSchedule -AutomationAccountName $automationaccount -ResourceGroupName $resourcegroup|where{$_.name -match 'AzureStorageIngestionChild-Schedule-MS-Mgmt-SA'}

                IF($RBsch)
                {
                    foreach ($sch in $RBsch)
                    {

                    Remove-AzureRmAutomationSchedule -AutomationAccountName $automationaccount -Name $sch.Name -ResourceGroupName $resourcegroup -Force
                               
                    }
                }

            }
            
        }
        elseif ($actionItem[0] -eq "Lock")
        {
            $lockList = Get-AzureRmResourceLock
            foreach ($l in $lockList) 
            {
                $lockNameCompareStr = "*" + $actionItem[1] + "*"
                if ($l.LockId -Like $lockNameCompareStr)
                {
                    Write-Verbose "CleanUp:  Removing lock $actionItem[1]"
                    Remove-AzureRmResourceLock -LockId $l.LockId -Force
                }
            }
        }
        elseif ($actionItem[0] -eq "Variable")
        {
            Write-Verbose "CleanUp:  Removing variable $actionItem[1]"
           Remove-AzureRmAutomationVariable -Name  $actionItem[1]  -AutomationAccountName $automationaccount -ResourceGroupName $resourcegroup 

        }
    }
}