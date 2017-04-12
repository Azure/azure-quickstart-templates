param (
[Parameter(Mandatory=$true)][array]$Salist,
[Parameter(Mandatory=$false)][boolean] $EnableExtraMetrics = $false
)

#$ErrorActionPreference = "SilentlyContinue"

#region Variables definition
# Variables definition
# Common  variables  accross solution 

$StartTime = [dateTime]::Now
$Timestampfield = "Timestamp" 

#Update customer Id to your Operational Insights workspace ID
$customerID = Get-AutomationVariable -Name 'AzureSAIngestion-OPSINSIGHTS_WS_ID-MS-Mgmt-SA'

#For shared key use either the primary or seconday Connected Sources client authentication key   
$sharedKey = Get-AutomationVariable -Name 'AzureSAIngestion-OPSINSIGHTS_WS_KEY-MS-Mgmt-SA'

#define API Versions for REST API  Calls


$ApiVerSaAsm = '2016-04-01'
$ApiVerSaArm = '2016-01-01'
$ApiStorage='2016-05-31'


# Automation Account and Resource group for automation

$AAAccount = Get-AutomationVariable -Name 'AzureSAIngestion-AzureAutomationAccount-MS-Mgmt-SA'

$AAResourceGroup = Get-AutomationVariable -Name 'AzureSAIngestion-AzureAutomationResourceGroup-MS-Mgmt-SA'

# OMS log analytics custom log name

$logname='AzureStorage'

# Runbook specific variables 

#Inventory variables
$varQueueList="AzureSAIngestion-List-Queues"
$varFilesList="AzureSAIngestion-List-Files"

#endregion

#region Login to Azure Using both ARM , ASM and REST
#Authenticate to Azure with SPN section
"Logging in to Azure..."
$ArmConn = Get-AutomationConnection -Name AzureRunAsConnection 
$AsmConn = Get-AutomationConnection -Name AzureClassicRunAsConnection  


# retry
$retry = 6
$syncOk = $false
do
{ 
	try
	{  
		Add-AzureRMAccount -ServicePrincipal -Tenant $ArmConn.TenantID -ApplicationId $ArmConn.ApplicationID -CertificateThumbprint $ArmConn.CertificateThumbprint
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

"Selecting Azure subscription..."
$SelectedAzureSub = Select-AzureRmSubscription -SubscriptionId $ArmConn.SubscriptionId -TenantId $ArmConn.tenantid 


#Creating headers for REST ARM Interface

$subscriptionid=$ArmConn.SubscriptionId

"Azure rm profile path  $((get-module -Name AzureRM.Profile).path) "

$path=(get-module -Name AzureRM.Profile).path
$path=Split-Path $path
$dlllist=Get-ChildItem -Path $path  -Filter Microsoft.IdentityModel.Clients.ActiveDirectory.dll  -Recurse
$adal =  $dlllist[0].VersionInfo.FileName



try
{
	Add-type -Path $adal
	[reflection.assembly]::LoadWithPartialName( "Microsoft.IdentityModel.Clients.ActiveDirectory" )

}
catch
{
	$ErrorMessage = $_.Exception.Message
	$StackTrace = $_.Exception.StackTrace
	Write-Warning "Error during sync: $ErrorMessage, stack: $StackTrace. "
}


#Create authentication token using the Certificate for ARM connection

$retry = 6
$syncOk = $false
do
{ 
	try
	{  
		$certs= Get-ChildItem -Path Cert:\Currentuser\my -Recurse | Where{$_.Thumbprint -eq $ArmConn.CertificateThumbprint}

		[System.Security.Cryptography.X509Certificates.X509Certificate2]$mycert=$certs[0]

		$syncOk = $true
	}
	catch
	{
		$ErrorMessage = $_.Exception.Message
		$StackTrace = $_.Exception.StackTrace
		Write-Warning "Error during certificate retrieval : $ErrorMessage, stack: $StackTrace. Retry attempts left: $retry"
		$retry = $retry - 1       
		Start-Sleep -s 60        
	}
} while (-not $syncOk -and $retry -ge 0)

IF ($mycert)
{
	$CliCert=new-object   Microsoft.IdentityModel.Clients.ActiveDirectory.ClientAssertionCertificate($ArmConn.ApplicationId,$mycert)
	$AuthContext = new-object Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext("https://login.windows.net/$($ArmConn.tenantid)")
	$result = $AuthContext.AcquireToken("https://management.core.windows.net/",$CliCert)
	$header = "Bearer " + $result.AccessToken
	$headers = @{"Authorization"=$header;"Accept"="application/json"}
    $body=$null
	$HTTPVerb="GET"
	$subscriptionInfoUri = "https://management.azure.com/subscriptions/"+$subscriptionid+"?api-version=2016-02-01"
	$subscriptionInfo = Invoke-RestMethod -Uri $subscriptionInfoUri -Headers $headers -Method Get -UseBasicParsing

	IF($subscriptionInfo)
	{
		"Successfully connected to Azure ARM REST"
	}
}
Else
{
	Write-error "Failed to login ro Azure ARM REST  , make sure Runas account configured correctly"
	Exit
}

#Authenticating to ASM 


if ($AsmConn  -eq $null)
{
	throw "Could not retrieve connection asset: $($AsmConn.CertificateAssetName) Ensure that this asset exists in the Automation account."
}

$CertificateAssetName = $AsmConn.CertificateAssetName

$AzureCert = Get-AutomationCertificate -Name $CertificateAssetName
if ($AzureCert -eq $null)
{
	throw "Could not retrieve certificate asset: $CertificateAssetName. Ensure that this asset exists in the Automation account."
}
"Logging into Azure Service Manager"
Write-Verbose "Authenticating to Azure with certificate." -Verbose

Set-AzureSubscription -SubscriptionName $AsmConn.SubscriptionName -SubscriptionId $AsmConn.SubscriptionId -Certificate $AzureCert
Select-AzureSubscription -SubscriptionId $AsmConn.SubscriptionId

#finally create the headers for ASM REST 
$headerasm = @{"x-ms-version"="2013-08-01"}

#endregion

#region Define Required Functions

Function Build-tableSignature ($customerId, $sharedKey, $date,  $method,  $resource,$uri)
{
    $stringToHash = $method + "`n" + "`n" + "`n"+$date+"`n"+"/"+$resource+$uri.AbsolutePath
	Add-Type -AssemblyName System.Web
	$query = [System.Web.HttpUtility]::ParseQueryString($uri.query)  
	$querystr=''
	$bytesToHash = [Text.Encoding]::UTF8.GetBytes($stringToHash)
	$keyBytes = [Convert]::FromBase64String($sharedKey)
	$sha256 = New-Object System.Security.Cryptography.HMACSHA256
	$sha256.Key = $keyBytes
	$calculatedHash = $sha256.ComputeHash($bytesToHash)
	$encodedHash = [Convert]::ToBase64String($calculatedHash)
	$authorization = 'SharedKey {0}:{1}' -f $resource,$encodedHash
	return $authorization
}

# Create the function to create the authorization signature
Function Build-StorageSignature ($sharedKey, $date,  $method, $bodylength, $resource,$uri ,$service)
{
	Add-Type -AssemblyName System.Web

	$str=  New-Object -TypeName "System.Text.StringBuilder";
	$builder=  [System.Text.StringBuilder]::new("/")
	$builder.Append($resource) |out-null
	$builder.Append($uri.AbsolutePath) | out-null
	$str.Append($builder.ToString()) | out-null
	$values2=@{}

	IF($service -eq 'Table')
	{
		$values= [System.Web.HttpUtility]::ParseQueryString($uri.query)  
		#    NameValueCollection values = HttpUtility.ParseQueryString(address.Query);
		foreach ($str2 in $values.Keys)
		{
			[System.Collections.ArrayList]$list=$values.GetValues($str2)
			$list.sort()
			$builder2=  [System.Text.StringBuilder]::new()
		
			foreach ($obj2 in $list)
			{
				if ($builder2.Length -gt 0)
				{
					$builder2.Append(",");
				}
				$builder2.Append($obj2.ToString()) |Out-Null
			}

			IF ($str2 -ne $null)
			{
				$values2.add($str2.ToLowerInvariant(),$builder2.ToString())
			} 
		}
		
		$list2=[System.Collections.ArrayList]::new($values2.Keys)
		$list2.sort()

		foreach ($str3 in $list2)
		{
			IF($str3 -eq 'comp')
			{
				$builder3=[System.Text.StringBuilder]::new()
				$builder3.Append($str3) |out-null
				$builder3.Append("=") |out-null
				$builder3.Append($values2[$str3]) |out-null
				$str.Append("?") |out-null
				$str.Append($builder3.ToString())|out-null
			}
		}
	}
	Else
	{
		$values= [System.Web.HttpUtility]::ParseQueryString($uri.query)  
		#    NameValueCollection values = HttpUtility.ParseQueryString(address.Query);
		foreach ($str2 in $values.Keys)
		{
			[System.Collections.ArrayList]$list=$values.GetValues($str2)
			$list.sort()
			$builder2=  [System.Text.StringBuilder]::new()
		
			foreach ($obj2 in $list)
			{
				if ($builder2.Length -gt 0)
				{
					$builder2.Append(",");
				}
				$builder2.Append($obj2.ToString()) |Out-Null
			}

			IF ($str2 -ne $null)
			{
				$values2.add($str2.ToLowerInvariant(),$builder2.ToString())
			} 
		}

		$list2=[System.Collections.ArrayList]::new($values2.Keys)
		$list2.sort()

		foreach ($str3 in $list2)
		{
			$builder3=[System.Text.StringBuilder]::new()
			$builder3.Append($str3) |out-null
			$builder3.Append(":") |out-null
			$builder3.Append($values2[$str3]) |out-null
			$str.Append("`n") |out-null
			$str.Append($builder3.ToString())|out-null
		}
	} 

	$xHeaders = "x-ms-date:" + $date+ "`n" +"x-ms-version:$ApiStorage"

	if ($service -eq 'Table')
	{
		$stringToHash= $method + "`n" + "`n" + "`n"+$date+"`n"+$str.ToString()
	}
	Else
	{
		IF ($method -eq 'GET' -or $method -eq 'HEAD')
		{
			$stringToHash = $method + "`n" + "`n" + "`n" + "`n" + "`n"+"application/xml"+ "`n"+ "`n"+ "`n"+ "`n"+ "`n"+ "`n"+ "`n"+$xHeaders+"`n"+$str.ToString()
		}
		Else
		{
			$stringToHash = $method + "`n" + "`n" + "`n" +$bodylength+ "`n" + "`n"+"application/xml"+ "`n"+ "`n"+ "`n"+ "`n"+ "`n"+ "`n"+ "`n"+$xHeaders+"`n"+$str.ToString()
		}     
	}
# write-host $stringToHash

	$bytesToHash = [Text.Encoding]::UTF8.GetBytes($stringToHash)
	$keyBytes = [Convert]::FromBase64String($sharedKey)
	$sha256 = New-Object System.Security.Cryptography.HMACSHA256
	$sha256.Key = $keyBytes
	$calculatedHash = $sha256.ComputeHash($bytesToHash)
	$encodedHash = [Convert]::ToBase64String($calculatedHash)
	$authorization = 'SharedKey {0}:{1}' -f $resource,$encodedHash
	return $authorization
}


# Create the function to create and post the request
Function invoke-StorageREST($sharedKey, $method, $msgbody, $resource,$uri,$svc)
{

	$rfc1123date = [DateTime]::UtcNow.ToString("r")

	
	If ($method -eq 'PUT')
	{$signature = Build-StorageSignature `
		-sharedKey $sharedKey `
		-date  $rfc1123date `
		-method $method -resource $resource -uri $uri -bodylength $msgbody.length -service $svc
	}Else
	{

		$signature = Build-StorageSignature `
		-sharedKey $sharedKey `
		-date  $rfc1123date `
		-method $method -resource $resource -uri $uri -body $body -service $svc
	} 

	If($svc -eq 'Table')
	{
		$headersforsa=  @{
			'Authorization'= "$signature"
			'x-ms-version'="$apistorage"
			'x-ms-date'=" $rfc1123date"
			'Accept-Charset'='UTF-8'
			'MaxDataServiceVersion'='3.0;NetFx'
			#      'Accept'='application/atom+xml,application/json;odata=nometadata'
			'Accept'='application/json;odata=nometadata'
		}
	}
	Else
	{ 
		$headersforSA=  @{
			'x-ms-date'="$rfc1123date"
			'Content-Type'='application\xml'
			'Authorization'= "$signature"
			'x-ms-version'="$ApiStorage"
		}
	}
	

	If ($svc -eq 'Table')
	{
		IF ($method -eq 'PUT'){  
			$resp1= Invoke-WebRequest -Uri $uri -Headers $headersforsa -Method $method  -UseBasicParsing -Body $msgbody  
			return $resp1
		}Else
		{  $resp1=Invoke-WebRequest -Uri $uri -Headers $headersforsa -Method $method   -UseBasicParsing -Body $msgbody 

			$xresp=$resp1.Content.Substring($resp1.Content.IndexOf("<")) 
		} 
		return $xresp

	}Else
	{
		IF ($method -eq 'PUT'){  
			$resp1= Invoke-WebRequest -Uri $uri -Headers $headersforsa -Method $method -ContentType application/xml -UseBasicParsing -Body $msgbody 
			return $resp1
		}Elseif($method -eq 'GET')
		{
			$resp1= Invoke-WebRequest -Uri $uri -Headers $headersforsa -Method $method -ContentType application/xml -UseBasicParsing -Body $msgbody 

			$xresp=$resp1.Content.Substring($resp1.Content.IndexOf("<")) 
			return $xresp
		}Elseif($method -eq 'HEAD')
        {
            $resp1= Invoke-WebRequest -Uri $uri -Headers $headersforsa -Method $method -ContentType application/xml -UseBasicParsing -Body $msgbody 

			
			return $resp1
        }
	}
}


# Create the function to create the authorization signature
Function Build-OMSSignature ($customerId, $sharedKey, $date, $contentLength, $method, $contentType, $resource)
{
	$xHeaders = "x-ms-date:" + $date
	$stringToHash = $method + "`n" + $contentLength + "`n" + $contentType + "`n" + $xHeaders + "`n" + $resource
	$bytesToHash = [Text.Encoding]::UTF8.GetBytes($stringToHash)
	$keyBytes = [Convert]::FromBase64String($sharedKey)
	$sha256 = New-Object System.Security.Cryptography.HMACSHA256
	$sha256.Key = $keyBytes
	$calculatedHash = $sha256.ComputeHash($bytesToHash)
	$encodedHash = [Convert]::ToBase64String($calculatedHash)
	$authorization = 'SharedKey {0}:{1}' -f $customerId,$encodedHash
	return $authorization
}

# Create the function to create and post the request
Function Post-OMSData($customerId, $sharedKey, $body, $logType)
{
	$method = "POST"
	$contentType = "application/json"
	$resource = "/api/logs"
	$rfc1123date = [DateTime]::UtcNow.ToString("r")
	$contentLength = $body.Length
	$signature = Build-OMSSignature `
	-customerId $customerId `
	-sharedKey $sharedKey `
	-date $rfc1123date `
	-contentLength $contentLength `
	-fileName $fileName `
	-method $method `
	-contentType $contentType `
	-resource $resource
	$uri = "https://" + $customerId + ".ods.opinsights.azure.com" + $resource + "?api-version=2016-04-01"

	$OMSheaders = @{
		"Authorization" = $signature;
		"Log-Type" = $logType;
		"x-ms-date" = $rfc1123date;
		"time-generated-field" = $TimeStampField;
	}

#write-output "OMS parameters"
#$OMSheaders
	Try
    {

		$response = Invoke-WebRequest -Uri $uri -Method POST  -ContentType $contentType -Headers $OMSheaders -Body $body -UseBasicParsing
	}
	Catch
	{
		$_.MEssage
	}
	return $response.StatusCode
	write-output $response.StatusCode
	Write-error $error[0]
}
#endregion

#Define collection time intervals

$colltime=Get-Date

If($colltime.Minute -in 0..15)
{
	$MetricColstartTime=$colltime.ToUniversalTime().AddHours(-1).ToString("yyyyMMdd'T'HH46")
	$MetricColendTime=$colltime.ToUniversalTime().ToString("yyyyMMdd'T'HH00")
}
Elseif($colltime.Minute -in 16..30)
{
	$MetricColstartTime=$colltime.ToUniversalTime().ToString("yyyyMMdd'T'HH00")
	$MetricColendTime=$colltime.ToUniversalTime().ToString("yyyyMMdd'T'HH15")
}
Elseif($colltime.Minute -in 31..45)
{
	$MetricColstartTime=$colltime.ToUniversalTime().ToString("yyyyMMdd'T'HH16")
	$MetricColendTime=$colltime.ToUniversalTime().ToString("yyyyMMdd'T'HH30")
}
Else
{
	$MetricColstartTime=$colltime.ToUniversalTime().ToString("yyyyMMdd'T'HH31")
	$MetricColendTime=$colltime.ToUniversalTime().ToString("yyyyMMdd'T'HH45")
}

#Log Timestamp will be based on  metric end date 
$hour=$MetricColEndTime.substring($MetricColEndTime.Length-4,4).Substring(0,2)
$min=$MetricColEndTime.substring($MetricColEndTime.Length-4,4).Substring(2,2)
$timestamp=(get-date).ToUniversalTime().ToString("yyyy-MM-ddT$($hour):$($min):00.000Z")

#region Get Storage account keys to query Metrics

$colParamsforChild=@()
$SaMetricsAvg=@()
$storcapacity=@()
$keylist=@{}

#define filter for metric query
$fltr1='?$filter='+"PartitionKey%20ge%20'"+$MetricColstartTime+"'%20and%20PartitionKey%20le%20'"+$MetricColendTime+"'%20and%20RowKey%20eq%20'user;All'"
$slct1='&$select=PartitionKey,TotalRequests,TotalBillableRequests,TotalIngress,TotalEgress,AverageE2ELatency,AverageServerLatency,PercentSuccess,Availability,PercentThrottlingError,PercentNetworkError,PercentTimeoutError,SASAuthorizationError,PercentAuthorizationError,PercentClientOtherError,PercentServerOtherError'

foreach($sa in $salist)
{
	$prikey=$storageaccount=$rg=$type=$null
	$storageaccount =$sa.Split(';')[0]
	$rg=$sa.Split(';')[1]
	$type=$sa.Split(';')[2]

	If($type -eq 'ARM')
	{
		$Uri="https://management.azure.com/subscriptions/{3}/resourceGroups/{2}/providers/Microsoft.Storage/storageAccounts/{1}/listKeys?api-version={0}"   -f  $ApiVerSaArm, $storageaccount,$rg,$SubscriptionId 
		$keyresp=Invoke-WebRequest -Uri $uri -Method POST  -Headers $headers -UseBasicParsing
		$keys=ConvertFrom-Json -InputObject $keyresp.Content
		$prikey=$keys.keys[0].value
	}Elseif($type -eq 'Classic')
	{
		$Uri="https://management.azure.com/subscriptions/{3}/resourceGroups/{2}/providers/Microsoft.ClassicStorage/storageAccounts/{1}/listKeys?api-version={0}"   -f  $ApiVerSaAsm,$storageaccount,$rg,$SubscriptionId 
		$keyresp=Invoke-WebRequest -Uri $uri -Method POST  -Headers $headers -UseBasicParsing
		$keys=ConvertFrom-Json -InputObject $keyresp.Content
		$prikey=$keys.primaryKey
	}Else
	{
		"Could not detect storage account type, $storageaccount will not be processed"
		Continue
	}

	IF($prikey)  
	{
		#build keylist for extended metrics usage 
		$keylist.add($storageaccount,$prikey)

		#get Transaction metrics
		"Start processing  $storageaccount"
		$tablelist= @('$MetricsMinutePrimaryTransactionsBlob','$MetricsMinutePrimaryTransactionsTable','$MetricsMinutePrimaryTransactionsQueue','$MetricsMinutePrimaryTransactionsFile')

		Foreach ($TableName in $tablelist)
		{
			$signature=$headersforsa=$null
			[uri]$tablequri="https://$($storageaccount).table.core.windows.net/"+$TableName+'()'
			
			$resource = $storageaccount
			$logdate=[DateTime]::UtcNow
			$rfc1123date = $logdate.ToString("r")
			
			$signature = Build-StorageSignature `
			-sharedKey $prikey `
			-date  $rfc1123date `
			-method GET -resource $storageaccount -uri $tablequri  -service table

			$headersforsa=  @{
				'Authorization'= "$signature"
				'x-ms-version'="$apistorage"
				'x-ms-date'="$rfc1123date"
				'Accept-Charset'='UTF-8'
				'MaxDataServiceVersion'='3.0;NetFx'
				'Accept'='application/json;odata=nometadata'
			}

			$response=$jresponse=$null
			$fullQuery=$tablequri.OriginalString+$fltr1+$slct1
			$method = "GET"

			Try
			{
				$response = Invoke-WebRequest -Uri $fullQuery -Method $method  -Headers $headersforsa  -UseBasicParsing  -ErrorAction SilentlyContinue
			}
			Catch
			{
				$ErrorMessage = $_.Exception.Message
				$StackTrace = $_.Exception.StackTrace
				Write-Warning "Error during accessing metrics table $tablename .Error: $ErrorMessage, stack: $StackTrace."
			}
			
			$Jresponse=convertFrom-Json    $response.Content
			"$(GEt-date)- Metircs query  $tablename for    $($storageaccount) completed. "
			
			IF($Jresponse.Value)
			{
				$entities=$null
				$entities=$Jresponse.value
				$stormetrics=@()
          
       
				foreach ($rowitem in $entities)
				{
					$cu=$null
					
                        $dt=$rowitem.PartitionKey
                       $timestamp=$dt.Substring(0,4)+'-'+$dt.Substring(4,2)+'-'+$dt.Substring(6,3)+$dt.Substring(9,2)+':'+$dt.Substring(11,2)+':00.000Z'


                       $cu = New-Object PSObject -Property @{
                        Timestamp = $timestamp
					    MetricName = 'MetricsTransactions'
						TotalRequests=[long]$rowitem.TotalRequests             
						TotalBillableRequests=[long]$rowitem.TotalBillableRequests      
						TotalIngress=[long]$rowitem.TotalIngress               
						TotalEgress=[long]$rowitem.TotalEgress                 
						Availability=[float]$rowitem.Availability               
						AverageE2ELatency=[int]$rowitem.AverageE2ELatency        
						AverageServerLatency=[int]$rowitem.AverageServerLatency       
						PercentSuccess=[float]$rowitem.PercentSuccess
						PercentThrottlingError=[float]$rowitem.PercentThrottlingError
						PercentNetworkError=[float]$rowitem.PercentNetworkError
						PercentTimeoutError=[float]$rowitem.PercentTimeoutError
						SASAuthorizationError=[float]$rowitem.SASAuthorizationError
						PercentAuthorizationError=[float]$rowitem.PercentAuthorizationError
						PercentClientOtherError=[float]$rowitem.PercentClientOtherError
						PercentServerOtherError=[float]$rowitem.PercentServerOtherError
						ResourceGroup=$rg
					    StorageAccount = $StorageAccount 
					    StorageService=$TableName.Substring(33,$TableName.Length-33) 
					    SubscriptionId = $ArmConn.SubscriptionID
					    AzureSubscription = $subscriptionInfo.displayName
					}
					#$stormetrics+=$cu
                    $SaMetricsAvg+=$cu
				}

				<#$cu1=$null
				$cu1 = New-Object PSObject -Property @{
					Timestamp =  $timestamp
					MetricName = 'MetricsTransactions'
					TotalRequests=($stormetrics|Measure-Object -Property TotalRequests -Average).Average
					TotalBillableRequests=($stormetrics|Measure-Object -Property TotalBillableRequests -Average).Average
					TotalIngress=($stormetrics|Measure-Object -Property TotalIngress -Average).Average
					TotalEgress=($stormetrics|Measure-Object -Property TotalEgress -Average).Average
					Availability=($stormetrics|Measure-Object -Property Availability -Average).Average
					AverageE2ELatency=($stormetrics|Measure-Object -Property AverageE2ELatency -Average).Average
					AverageServerLatency=($stormetrics|Measure-Object -Property AverageServerLatency -Average).Average
					PercentSuccess=($stormetrics|Measure-Object -Property PercentSuccess -Average).Average
					PercentThrottlingError=($stormetrics|Measure-Object -Property PercentThrottlingError -Average).Average
					PercentNetworkError=($stormetrics|Measure-Object -Property PercentNetworkError -Average).Average
					PercentTimeoutError=($stormetrics|Measure-Object -Property PercentTimeoutError -Average).Average
					SASAuthorizationError=($stormetrics|Measure-Object -Property SASAuthorizationError -Average).Average
					PercentAuthorizationError=($stormetrics|Measure-Object -Property PercentAuthorizationError -Average).Average
					PercentClientOtherError=($stormetrics|Measure-Object -Property PercentClientOtherError -Average).Average
					PercentServerOtherError=($stormetrics|Measure-Object -Property PercentServerOtherError -Average).Average
					ResourceGroup=$rg
					StorageAccount = $StorageAccount 
					StorageService=$TableName.Substring(33,$TableName.Length-33) 
					SubscriptionId = $ArmConn.SubscriptionID
					AzureSubscription = $subscriptionInfo.displayName
				}
				$SaMetricsAvg+=$cu1
                #>
			}
		}

		#Collect capacity metrics 
		$TableName = '$MetricsCapacityBlob'
		$startdate=(get-date).AddDays(-1).ToUniversalTime().ToString("yyyyMMdd'T'0000")

		$table=$null
		$signature=$headersforsa=$null
		[uri]$tablequri="https://$($storageaccount).table.core.windows.net/"+$TableName+'()'
		
		$resource = $storageaccount
		$logdate=[DateTime]::UtcNow
		$rfc1123date = $logdate.ToString("r")
		$signature = Build-StorageSignature `
		-sharedKey $prikey `
		-date  $rfc1123date `
		-method GET -resource $storageaccount -uri $tablequri  -service table

		$headersforsa=  @{
			'Authorization'= "$signature"
			'x-ms-version'="$apistorage"
			'x-ms-date'="$rfc1123date"
			'Accept-Charset'='UTF-8'
			'MaxDataServiceVersion'='3.0;NetFx'
			'Accept'='application/json;odata=nometadata'
		}

		$response=$jresponse=$null
		$fltr2='?$filter='+"PartitionKey%20gt%20'"+$startdate+"'%20and%20RowKey%20eq%20'data'"
		$fullQuery=$tablequri.OriginalString+$fltr2
		$method = "GET"
		
		Try
		{
			$response = Invoke-WebRequest -Uri $fullQuery -Method $method  -Headers $headersforsa  -UseBasicParsing  -ErrorAction SilentlyContinue
		}
		Catch
		{
			$ErrorMessage = $_.Exception.Message
			$StackTrace = $_.Exception.StackTrace
			Write-Warning "Error during accessing metrics table $tablename .Error: $ErrorMessage, stack: $StackTrace."
		}
		$Jresponse=convertFrom-Json    $response.Content

		IF($Jresponse.Value)
		
		{
			$entities=$null
			$entities=@($jresponse.value)
			$cu=$null

			$cu = New-Object PSObject -Property @{
				Timestamp = $timestamp
				MetricName = 'MetricsCapacity'				
				Capacity=$([long]$entities[0].Capacity)/1024/1024/1024               
				ContainerCount=[long]$entities[0].ContainerCount 
				ObjectCount=[long]$entities[0].ObjectCount
				ResourceGroup=$rg
				StorageAccount = $StorageAccount
				StorageService="Blob"  
				SubscriptionId = $ArmConn.SubscriptionId
				AzureSubscription = $subscriptionInfo.displayName
				
			}
			$storCapacity+=$cu
	
		}
	}
	Else
	{"Keys cannot be retrieved for $storageaccount , metrics will not be collected"}

}

"$($SaMetricsAvg.count)   metric data collected "

#endregion

$jsonSapool = ConvertTo-Json -InputObject  $SaMetricsAvg
$jsonCapacity = ConvertTo-Json -InputObject  $storCapacity

# Submit the data to the API endpoint

If($jsonSapool){$postres1=Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($jsonsapool)) -logType $logname}
If($jsonCapacity){$postres2=Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($jsonCapacity)) -logType $logname}

If ($postres1 -ge 200 -and $postres1 -lt 300)
{
	Write-Output " Succesfully uploaded $($SaMetricsAvg.count) transaction metrics to OMS"
}
Else
{
	Write-Warning " Failed to upload  $($SaMetricsAvg.count) transaction metrics to OMS"
}

If ($postres2 -ge 200 -and $postres2 -lt 300)
{
	Write-Output " Succesfully uploaded $($storCapacity.count) capacity metrics to OMS"
}
Else
{
	Write-Warning " Failed to upload  $($storCapacity.count) capacity metrics to OM"
}





$endtime=get-date

Write-Output " Runbook runtime total $(($endtime-$starttime).TotalMinutes) Mins"




