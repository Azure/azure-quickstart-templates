#Reference URL for SQL PaaS Script content borrowed below
#https://azure.microsoft.com/en-us/documentation/articles/sql-database-elastic-pool-manage-powershell/

# Suspend the runbook if any errors, not just exceptions, are encountered
$ErrorActionPreference = "Stop"

#region Variables definition
# Variables definition
# Starttime for gathering DB metrics (default is 5 minutes in the past) and run every 10 mins on a schedule for 2 metric points per run 
$StartTime = [dateTime]::Now.Subtract([TimeSpan]::FromMinutes(5))

#Replace the below string with a metric value name such as 'TimeStamp' to update TimeGenerated to be that metric named instead of ingestion time
$Timestampfield = "Timestamp" 

#Update customer Id to your Operational Insights workspace ID
$customerID = Get-AutomationVariable -Name 'OPSINSIGHTS_WS_ID'

#For shared key use either the primary or seconday Connected Sources client authentication key   
$sharedKey = Get-AutomationVariable -Name 'OPSINSIGHTS_WS_KEY'
#endregion

#Start Script (MAIN)
#region Login to Azure account and select the subscription.
#Authenticate to Azure with SPN section
"Logging in to Azure..."
$Conn = Get-AutomationConnection -Name AzureRunAsConnection 
 Add-AzureRMAccount -ServicePrincipal -Tenant $Conn.TenantID `
 -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint

"Selecting Azure subscription..."
Select-AzureRmSubscription -SubscriptionId $Conn.SubscriptionID -TenantId $Conn.tenantid 
#endregion

#region Get PaaS resource, Metrics Data, and Post to Ingestion API
#Logtype will be the name of the custom log in Log Analytics 
#Example: sqlazure will be sqlazure_CL once ingested 
# Define Log Type 
$logType  = "webappazure"
"Logtype Name is $logType"

# Get all WebApps w/in an Azure Subscription 
$WebApps = Find-AzureRmResource -ResourceType Microsoft.Web/sites
# Process each retrieved WebApp in list
# Do not process if listing is $null  
if($WebApps -ne $Null)
{
	foreach($WebApp in $WebApps)
	{
		# Get resource usage metrics for a webapp for the specified time interval.
		# This example will run every 10 minutes on a schedule and gather two data points for 15 metrics leveraging the ARM API 
        $Metrics = @()
        $Metrics = $Metrics + (Get-AzureRmMetric -ResourceId $WebApp.ResourceId -TimeGrain ([TimeSpan]::FromMinutes(1)) -StartTime $StartTime)
		
		# Format metrics into a table.
        $table = @()
        foreach($metric in $Metrics)
        { 
            foreach($metricValue in $metric.MetricValues)
            {
                $sx = New-Object PSObject -Property @{
                    Timestamp = $metricValue.Timestamp.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
                    MetricName = $metric.Name; 
                    Average = $metricValue.Average;
                    SubscriptionID = $Conn.SubscriptionID;
                    ResourceGroup = $WebApp.ResourceGroupName;
                    ServerName = $WebApp.Name
                }
                $table = $table += $sx
            }
        # Convert table to a JSON document for ingestion 
		$jsonTable = ConvertTo-Json -InputObject $table
        }
					
		#Post the data to the endpoint - looking for an "accepted" response code
        Send-OMSAPIIngestionFile -customerId $customerId -sharedKey $sharedKey -body $jsonTable -logType $logType -TimeStampField $Timestampfield
        # Uncomment below to troubleshoot
		#$jsonTable
    }
}
#endregion
