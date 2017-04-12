# Suspend the runbook if any errors, not just exceptions, are encountered
$ErrorActionPreference = "Stop"

#region Setting up connections
# ASM authentication
$ConnectionAssetName = "AzureClassicRunAsConnection"

# Get the connection
$connection = Get-AutomationConnection -Name $connectionAssetName        

# Authenticate to Azure with certificate
Write-Verbose "Get connection asset: $ConnectionAssetName" -Verbose
$Conn = Get-AutomationConnection -Name $ConnectionAssetName
if ($Conn -eq $null)
    {
        throw "Could not retrieve connection asset: $ConnectionAssetName. Assure that this asset exists in the Automation account."
    }

$CertificateAssetName = $Conn.CertificateAssetName
Write-Verbose "Getting the certificate: $CertificateAssetName" -Verbose

$AzureCert = Get-AutomationCertificate -Name $CertificateAssetName
if ($AzureCert -eq $null)
    {
        throw "Could not retrieve certificate asset: $CertificateAssetName. Assure that this asset exists in the Automation account."
    }

Write-Verbose "Authenticating to Azure with certificate." -Verbose
Set-AzureSubscription -SubscriptionName $Conn.SubscriptionName -SubscriptionId $Conn.SubscriptionID -Certificate $AzureCert 
Select-AzureSubscription -SubscriptionId $Conn.SubscriptionID
#endregion

#region Variables definition
#Ingestion starttime 
$StartTime = [dateTime]::Now

#Replace the below string with a metric value name such as 'TimeStamp' to update TimeGenerated to be that metric named instead of ingestion time
$Timestampfield = "Timestamp" 

#Update customer Id to your Operational Insights workspace ID
$customerID = Get-AutomationVariable -Name 'OMSWorkspaceId'

#For shared key use either the primary or seconday Connected Sources client authentication key   
$sharedKey = Get-AutomationVariable -Name 'OMSWorkspaceKey'

$logType  = "servicebus"
#endregion

#region Azure login
#Authenticate to Azure with SPN
"Logging in to Azure..."
$Conn = Get-AutomationConnection -Name AzureRunAsConnection 
 Add-AzureRMAccount -ServicePrincipal -Tenant $Conn.TenantID `
 -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint

"Selecting Azure subscription..."
$SelectedAzureSub = Select-AzureRmSubscription -SubscriptionId $Conn.SubscriptionID -TenantId $Conn.tenantid 
#endregion


"Logtype Name for ServiceBus(es) is '$logType'"

 #region Functions
 Function CalculateFreeSpacePercentage{
 param(
[Parameter(Mandatory=$true)]
[int]$MaxSizeMB,
[Parameter(Mandatory=$true)]
[int]$CurrentSizeMB
)

$percentage = (($MaxSizeMB - $CurrentSizeMB)/$MaxSizeMB)*100 #calculate percentage
#Return ("Space remaining: $Percentage" + "%")
Return ($percentage)
}

Function Publish-SbQueueMetrics{
$sbList = Get-AzureSBNamespace
	if ($sbList -ne $null)
	{
		"Found $($sbList.Count) service bus namespace(s)."
		
		foreach ($sb in $sbList)
		{
		    # Format metrics into a table.
		    $table1 = @()
		    
			"Processing service bus `"$($sb.Name)`" for queues..."
			    
		    $sbAuth = Get-AzureSBAuthorizationRule -Namespace $sb.Name
            $nsManager = [Microsoft.ServiceBus.NamespaceManager]::CreateFromConnectionString($sbAuth[0].ConnectionString); # We are grabbing the first connectionstring[0] we find

            "Attempting to get queues...."
		    $queueList = $nsManager.GetQueues()

		    foreach ($sbQueue in $queueList)
		    {
					
				$Queue = $null
				try
				{
		        	$Queue = $nsManager.GetQueue($sbQueue.Path);
				}
                
                catch
                {
                "Could not get any queues"
                $ErrorMessage = $_.Exception.Message
                Write-Output ("Error Message: " + $ErrorMessage)
                }

				
				if ($Queue -ne $null)
				{

                    #check if the queue message size (SizeInBytes) exceeds the threshold (MaxSizeInMegabytes)
                    #if so we will raise an alert (=1)
                    if(($Queue.SizeInBytes/1MB) -gt $Queue.MaxSizeInMegabytes)
                    {
                        $QueueThresholdAlert = 1 #Queue exceeds Queue threshold, so raise alert
                    }
                    
                    else
                    {
                        $QueueThresholdAlert = 0 #Queue size is below threshold
                    }

                    #Convert Bytes to MB and calculate percentage of free space
                    if($Queue.SizeInBytes -ne 0)
                    {
                        ("QueueSizeInBytes is: " + $Queue.SizeInBytes)
                        $QueueSizeInMB = $null

                        #Convert SizeInBytes to MegaBytes
                        $QueueSizeInMB = ($Queue.SizeInBytes/1MB)
                        ("QueueSize converted to: " + $QueueSizeInMB)

                    
                        $QueueFreeSpacePercentage = $null
                        $QueueFreeSpacePercentage = CalculateFreeSpacePercentage -MaxSizeMB $Queue.MaxSizeInMegabytes -CurrentSizeMB $QueueSizeInMB
                        $QueueFreeSpacePercentage = "{0:N2}" -f $QueueFreeSpacePercentage
                    }
                    
                    else
                    {
                        "QueueSizeInBytes is 0, so we are setting the percentage to 100"
                        $QueueFreeSpacePercentage = 100
                    }

			            #Construct table for ingestion
                        $sx = New-Object PSObject -Property @{
                        TimeStamp = $([DateTime]::Now.ToString("yyyy-MM-ddTHH:mm:ss.fffZ"));
			            SubscriptionName = $subscriptionName;
                        ServiceBusName = $sb.Name;
                        Region = $sb.Region;
                        NamespaceType = $sb.Namespacetype.ToString();
                        ConnectionString = $sb.connectionString;
			            LockDuration = $Queue.LockDuration;
			            MaxSizeInMegabytes = $Queue.MaxSizeInMegabytes;
			            RequiresDuplicateDetection = $Queue.RequiresDuplicateDetection;
			            RequiresSession = $Queue.RequiresSession;
			            DefaultMessageTimeToLive = $Queue.DefaultMessageTimeToLive;
			            AutoDeleteOnIdle = $Queue.AutoDeleteOnIdle;
			            EnableDeadLetteringOnMessageExpiration = $Queue.EnableDeadLetteringOnMessageExpiration;
			            DuplicateDetectionHistoryTimeWindow = $Queue.DuplicateDetectionHistoryTimeWindow;
			            Path = $Queue.Path;
			            MaxDeliveryCount = $Queue.MaxDeliveryCount;
			            EnableBatchedOperations = $Queue.EnableBatchedOperations;
			            SizeInBytes = $Queue.SizeInBytes;
			            MessageCount = $Queue.MessageCount;
			            ActiveMessageCount = $Queue.MessageCountDetails.ActiveMessageCount;
			            DeadLetterMessageCount = $Queue.MessageCountDetails.DeadLetterMessageCount;
			            ScheduledMessageCount = $Queue.MessageCountDetails.ScheduledMessageCount;
			            TransferMessageCount = $Queue.MessageCountDetails.TransferMessageCount;
			            TransferDeadLetterMessageCount = $Queue.MessageCountDetails.TransferDeadLetterMessageCount;			
			            Authorization = $Queue.Authorization;
			            IsAnonymousAccessible = $Queue.IsAnonymousAccessible;
			            SupportOrdering = $Queue.SupportOrdering;
			            Status = $Queue.Status;
			            AvailabilityStatus = $Queue.AvailabilityStatus;
			            ForwardTo = $Queue.ForwardTo;
			            ForwardDeadLetteredMessagesTo = $Queue.ForwardDeadLetteredMessagesTo;
			            CreatedAt = $Queue.CreatedAt;
			            UpdatedAt = $Queue.UpdatedAt;
			            AccessedAt = $Queue.AccessedAt;
			            EnablePartitioning = $Queue.EnablePartitioning;
			            UserMetadata = $Queue.UserMetadata;
			            EnableExpress = $Queue.EnableExpress;
			            IsReadOnly = $Queue.IsReadOnly;
			            ExtensionData = $Queue.ExtensionData;
                        QueueThresholdAlert = $QueueThresholdAlert;
                        QueueFreeSpacePercentage = $QueueFreeSpacePercentage;

			        }
			
					$sx
					$table1 = $table1 += $sx
			        
			        # Convert table to a JSON document for ingestion 
			        $jsonTable1 = ConvertTo-Json -InputObject $table1
				}
			    #Post the data to the endpoint - looking for an "accepted" response code 
		    	Send-OMSAPIIngestionData -customerId $customerId -sharedKey $sharedKey -body $jsonTable1 -logType $logType -TimeStampField $Timestampfield
		    	# Uncomment below to troubleshoot
		    	#$jsonTable
			}
		}
	} 
    else #if we get here, then there are no service bus namespaces
	{
		"This subscription contains no service bus namespaces."
	}
}

Function Publish-SbTopicMetrics{
$sbList = Get-AzureSBNamespace
	if ($sbList -ne $null)
	{
		foreach ($sb in $sbList)
		{
		    #Initialize tables for each round
            $table2 = @()
		    $jsonTable2 = @()
			
            "Processing service bus `"$($sb.Name)`" for Topics..."
			    
		    $sbAuth = Get-AzureSBAuthorizationRule -Namespace $sb.Name
		    $nsManager = [Microsoft.ServiceBus.NamespaceManager]::CreateFromConnectionString($sbAuth[0].ConnectionString); # We are grabbing the first connectionstring[0] we find

            "Attempting to get topics...."
            $topicList = @()

            try
            {
                $topicList = $nsManager.GetTopics()
            }
            catch
            {
                "Could not get any topics"
                $ErrorMessage = $_.Exception.Message
                Write-Output ("Error Message: " + $ErrorMessage)
            }
            
            "Found $($topicList.path.count) topic(s)."
            foreach ($topic in $topicList)
		    {
				if ($topicList -ne $null)
				{

                    #check if the topic message size (SizeInBytes) exceeds the threshold of MaxSizeInMegabytes
                    #if so we raise an alert (=1)
                    if(($topic.SizeInBytes/1MB) -gt $topic.MaxSizeInMegabytes)
                    {
                        $TopicThresholdAlert = 1 #exceeds Queue threshold
                    }
                    
                    else
                    {
                        $TopicThresholdAlert = 0
                    }

                    
                    if($topic.SizeInBytes -ne 0)
                    {
                        ("TopicSizeInBytes is: " + $topic.SizeInBytes)
                        $TopicSizeInMB = $null
                        $TopicSizeInMB = ($topic.SizeInBytes/1MB)
                        $TopicFreeSpacePercentage = $null
                        $TopicFreeSpacePercentage = CalculateFreeSpacePercentage -MaxSizeMB $topic.MaxSizeInMegabytes -CurrentSizeMB $TopicSizeInMB
                        $TopicFreeSpacePercentage = "{0:N2}" -f $TopicFreeSpacePercentage
                    }
                    else
                    {
                        "TopicSizeInBytes is 0, so we are setting the percentage to 100"
                        $TopicFreeSpacePercentage = 100
                    }

			            #Construct the ingestion table
                        $sx2 = New-Object PSObject -Property @{
                        TimeStamp = $([DateTime]::Now.ToString("yyyy-MM-ddTHH:mm:ss.fffZ"));
                        TopicName = $topic.path;
                        DefaultMessageTimeToLive = $topic.DefaultMessageTimeToLive;
                        MaxSizeInMegabytes = $topic.MaxSizeInMegabytes;
                        SizeInBytes = $topic.SizeInBytes;
                        EnableBatchedOperations = $topic.EnableBatchedOperations;
                        SubscriptionCount = $topic.SubscriptionCount;
                        CreatedAt = $topic.CreatedAt;
                        UpdatedAt = $topic.UpdatedAt;
                        AccessedAt = $topic.AccessedAt;  
                        TopicThresholdAlert = $TopicThresholdAlert;
                        TopicFreeSpacePercentage = $TopicFreeSpacePercentage;
                        ActiveMessageCount = $topic.MessageCountDetails.ActiveMessageCount;
                        DeadLetterMessageCount = $topic.messagecountdetails.DeadLetterMessageCount;
                        ScheduledMessageCount = $topic.messagecountdetails.ScheduledMessageCount;
                        TransferMessageCount = $topic.messagecountdetails.TransferMessageCount;
                        TransferDeadLetterMessageCount = $topic.messagecountdetails.TransferDeadLetterMessageCount;                                                           		            
			        }
			
					$sx2
			        $table2 = $table2 += $sx2
			        
			        # Convert table to a JSON document for ingestion 
			        $jsonTable2 = ConvertTo-Json -InputObject $table2
				}
                else{"No topics found."}
		    	
                Send-OMSAPIIngestionData -customerId $customerId -sharedKey $sharedKey -body $jsonTable2 -logType $logType -TimeStampField $Timestampfield
		    	# Uncomment below to troubleshoot
		    	#$jsonTable
			}
		}
	} 
    else
	{
		"This subscription contains no service bus namespaces."
	}
}
#endregion

#region Calling Functions to execute the ingestion and send verbose output
$output1 = Publish-SbQueueMetrics
$output1
$output2 = Publish-SbTopicMetrics
$output2
#endregion
