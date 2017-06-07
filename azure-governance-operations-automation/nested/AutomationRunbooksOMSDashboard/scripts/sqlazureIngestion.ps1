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
$SelectedAzureSub = Select-AzureRmSubscription -SubscriptionId $Conn.SubscriptionID -TenantId $Conn.tenantid 

#endregion

#region Get PaaS resource, Metrics Data, and Post to Ingestion API
#Logtype will be the name of the custom log in Log Analytics 
#Example: sqlazure will be sqlazure_CL once ingested 
# Define Log Type 
$logType  = "sqlazure"
"Logtype Name for SQL DB(s) is $logType"

# Get all SQL Servers w/in an Azure Subscription 
$SQLServers = Find-AzureRmResource -ResourceType Microsoft.Sql/servers
# Process each retrieved SQL Server in list
# Do not process if SQL Server listing is $null  
$DBCount = 0
$FailedConnections = @()
if($SQLServers -ne $Null)
{
	foreach($SQLServer in $SQLServers)
    	{
		# Get resource usage metrics for a database in an elastic database for the specified time interval.
		# This example will run every 10 minutes on a schedule and gather two data points for 15 metrics leveraging the ARM API 
		$DBList = Get-AzureRmSqlDatabase -ServerName $SQLServer.Name -ResourceGroupName $SQLServer.ResourceGroupName
        
		# If the listing of databases is not $null 
		if($dbList -ne $Null)
		{
			foreach ($db in $dbList)
			{
                		if($db.Edition -ne "None")
                		{
		                    	$DBCount++
		                    	$Metrics = @()
		                    	if($db.ElasticPoolName -ne $Null)
		    			{
						$elasticPool = $db.ElasticPoolName
		    			}
		    			else
		    			{
						$elasticPool = "none"
		    			}                    
					try
	                    		{
	                        		$Metrics = $Metrics + (Get-AzureRmMetric -ResourceId $db.ResourceId -TimeGrain ([TimeSpan]::FromMinutes(5)) -StartTime $StartTime)
					}
	                    		catch
	            			{
						# Add up failed connections due to offline or access denied
						$FailedConnections = $FailedConnections + "Failed to connect to $($db.DatabaseName) on SQL Server $($db.ServerName)"
					}		
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
                                			ResourceGroup = $db.ResourceGroupName;
                                			ServerName = $SQLServer.Name;
                                			DatabaseName = $db.DatabaseName;
		                        		ElasticPoolName = $elasticPool;
		                        		AzureSubscription = $SelectedAzureSub.subscription.subscriptionName;
		                        		ResourceLink = "https://portal.azure.com/#resource/subscriptions/$($Conn.SubscriptionID)/resourceGroups/$($db.ResourceGroupName)/providers/Microsoft.Sql/Servers/$($SQLServer.Name)/databases/$($db.DatabaseName)"
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
		}
	}		
}
"Total DBs processed $DBCount"
if($FailedConnections -ne $Null)
{
    ""
    "Failed to connect to $($FailedConnections.Count) databases"
    $FailedConnections
}
#endregion
