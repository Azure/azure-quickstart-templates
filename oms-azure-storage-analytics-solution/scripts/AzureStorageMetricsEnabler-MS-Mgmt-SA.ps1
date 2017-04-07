
$ErrorActionPreference = "SilentlyContinue"

#region Variables definition
# Variables definition

#Replace the below string with a metric value name such as 'TimeStamp' to update TimeGenerated to be that metric named instead of ingestion time
$Timestampfield = "Timestamp" 

#Update customer Id to your Operational Insights workspace ID
$customerID = Get-AutomationVariable -Name 'AzureSAIngestion-OPSINSIGHTS_WS_ID-MS-Mgmt-SA'

#For shared key use either the primary or seconday Connected Sources client authentication key   
$sharedKey = Get-AutomationVariable -Name 'AzureSAIngestion-OPSINSIGHTS_WS_KEY-MS-Mgmt-SA'

#define API Versions for REST Calls


$ApiVerSaAsm = '2016-04-01'
$ApiVerSaArm = '2016-01-01'
$ApiStorage='2016-05-31'


# define name to Stora Queues in Automation Account

$AAAccount = Get-AutomationVariable -Name 'AzureSAIngestion-AzureAutomationAccount-MS-Mgmt-SA'

$AAResourceGroup = Get-AutomationVariable -Name 'AzureSAIngestion-AzureAutomationResourceGroup-MS-Mgmt-SA'


#Inventory variables
$varQueueList="AzureSAIngestion-List-Queues"
$varFilesList="AzureSAIngestion-List-Files"
$varTableList="AzureSAIngestion-List-Tables"


#vmIolimits
$vmiolimits=@{"Basic_A0"=300;
"Basic_A1"=300;
"Basic_A2"=300;
"Basic_A3"=300;
"Basic_A4"=300;
"ExtraSmall"=500;
"Small"=500;
"Medium"=500;
"Large"=500;
"ExtraLarge"=500;
"Standard_A0"=500;
"Standard_A1"=500;
"Standard_A2"=500;
"Standard_A3"=500;
"Standard_A4"=500;
"Standard_A5"=500;
"Standard_A6"=500;
"Standard_A7"=500;
"Standard_A8"=500;
"Standard_A9"=500;
"Standard_A10"=500;
"Standard_A11"=500;
"Standard_A1_v2"=500;
"Standard_A2_v2"=500;
"Standard_A4_v2"=500;
"Standard_A8_v2"=500;
"Standard_A2m_v2"=500;
"Standard_A4m_v2"=500;
"Standard_A8m_v2"=500;
"Standard_D1"=500;
"Standard_D2"=500;
"Standard_D3"=500;
"Standard_D4"=500;
"Standard_D11"=500;
"Standard_D12"=500;
"Standard_D13"=500;
"Standard_D14"=500;
"Standard_D1_v2"=500;
"Standard_D2_v2"=500;
"Standard_D3_v2"=500;
"Standard_D4_v2"=500;
"Standard_D5_v2"=500;
"Standard_D11_v2"=500;
"Standard_D12_v2"=500;
"Standard_D13_v2"=500;
"Standard_D14_v2"=500;
"Standard_D15_v2"=500;
"Standard_DS1"=3200;
"Standard_DS2"=6400;
"Standard_DS3"=12800;
"Standard_DS4"=25600;
"Standard_DS11"=6400;
"Standard_DS12"=12800;
"Standard_DS13"=25600;
"Standard_DS14"=51200;
"Standard_DS1_v2"=3200;
"Standard_DS2_v2"=6400;
"Standard_DS3_v2"=12800;
"Standard_DS4_v2"=25600;
"Standard_DS5_v2"=51200;
"Standard_DS11_v2"=6400;
"Standard_DS12_v2"=12800;
"Standard_DS13_v2"=25600;
"Standard_DS14_v2"=51200;
"Standard_DS15_v2"=64000;
"Standard_F1"=500;
"Standard_F2"=500;
"Standard_F4"=500;
"Standard_F8"=500;
"Standard_F16"=500;
"Standard_F1s"=3200;
"Standard_F2s"=6400;
"Standard_F4s"=12800;
"Standard_F8s"=25600;
"Standard_F16s"=51200;
"Standard_G1"=500;
"Standard_G2"=500;
"Standard_G3"=500;
"Standard_G4"=500;
"Standard_G5"=500;
"Standard_GS1"=5000;
"Standard_GS2"=10000;
"Standard_GS3"=20000;
"Standard_GS4"=40000;
"Standard_GS5"=80000;
"Standard_H8"=500;
"Standard_H16"=500;
"Standard_H8m"=500;
"Standard_H16m"=500;
"Standard_H16r"=500;
"Standard_H16mr"=500;
"Standard_NV6"=500;
"Standard_NV12"=500;
"Standard_NV24"=500;
"Standard_NC6"=500;
"Standard_NC12"=500;
"Standard_NC24"=500;
"Standard_NC24r"=500}



#endregion


#region define functions
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
	#    $stringToHash+= $str.ToString();
	#$str.ToString()
	############
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
	##############
	
# write-host $stringToHash
#$stringToHash|?{ out-file -InputObject $_ -FilePath 'C:\OneDrive - Microsoft\Azure\logsarest.txt'  -Append -Force}
	$bytesToHash = [Text.Encoding]::UTF8.GetBytes($stringToHash)
	$keyBytes = [Convert]::FromBase64String($sharedKey)
	$sha256 = New-Object System.Security.Cryptography.HMACSHA256
	$sha256.Key = $keyBytes
	$calculatedHash = $sha256.ComputeHash($bytesToHash)
	$encodedHash = [Convert]::ToBase64String($calculatedHash)
	$authorization = 'SharedKey {0}:{1}' -f $resource,$encodedHash
	return $authorization
	
}
#
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
	Try{
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
#Start Script (MAIN)
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
$certs= Get-ChildItem -Path Cert:\Currentuser\my -Recurse | Where{$_.Thumbprint -eq $ArmConn.CertificateThumbprint}
#$certs
[System.Security.Cryptography.X509Certificates.X509Certificate2]$mycert=$certs[0]
#Write-output "$mycert will be used to acquire token"
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
#Logtype will be the name of the custom log in Log Analytics 
# Define Log Type 
$logname  = "AzureStorage"
$timestamp=(get-date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:00.000Z")
# define metrics to enable on Storage Analytics
$services=@('Blob','Table','Queue','File')
$sacount=0
$satracking=0
$salist=@()
#check if metrics enabled

#region Get Storage account list
"$(GEt-date)  Get ARM storage Accounts "
$Uri="https://management.azure.com/subscriptions/{1}/providers/Microsoft.Storage/storageAccounts?api-version={0}"   -f  $ApiVerSaArm,$SubscriptionId 
$armresp=Invoke-WebRequest -Uri $uri -Method GET  -Headers $headers -UseBasicParsing
$salist+=(ConvertFrom-Json -InputObject $armresp.Content).Value
#get Classic SA
"$(GEt-date)  Get Classic storage Accounts "
$Uri="https://management.azure.com/subscriptions/{1}/providers/Microsoft.ClassicStorage/storageAccounts?api-version={0}"   -f  $ApiVerSaAsm,$SubscriptionId 
$sresp=Invoke-WebRequest -Uri $uri -Method GET  -Headers $headers -UseBasicParsing
$salist+=(ConvertFrom-Json -InputObject $sresp.Content).value
"$(GEt-date)  $($saList.count) storage accounts found"
#endregion

#region get  keys
Foreach($sa in $salist)
{
	$prikey=$storageaccount=$rg=$type=$null
	$storageaccount =$sa.name
	$rg=$sa.id.Split('/')[4]
	If($sa.type -match 'ClassicStorage')
	{$type='Classic'}Else{$type='ARM'}
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
	$sa|Add-Member -MemberType NoteProperty -Name Key -Value $prikey
}
#endregion

#region  collect VHD inventory 
$vhdinventory=@()
$allContainers=@()
Foreach($sa in $salist)
{
	[uri]$uriListC= "https://{0}.blob.core.windows.net/?comp=list" -f $sa.name
	
	Write-verbose "$(get-date) - Getting list of blobs for $($sa.name) "
	[xml]$lb=invoke-StorageREST -sharedKey $sa.key -method GET -resource $sa.name -uri $uriListC
	$containers=@($lb.EnumerationResults.Containers.Container)
	
	IF(![string]::IsNullOrEmpty($lb.EnumerationResults.Containers.Container))
	{
		Foreach($container in @($containers))
		{
			$allcontainers+=$container
			[uri]$uriLBlobs = "https://{0}.blob.core.windows.net/{1}/?comp=list&include=metadata&maxresults=1000&restype=container" -f $sa.name,$container.name
			
			[xml]$fresponse= invoke-StorageREST -sharedKey $sa.key -method GET -resource $sa.name -uri $uriLBlobs
			
			$blobs=$fresponse.EnumerationResults.Blobs.blob
			Foreach($blob in $blobs)
			{
				IF($blob.name -match '.vhd')
				{
					$cu = New-Object PSObject -Property @{
						Timestamp = $timestamp
						MetricName = 'Inventory'
						InventoryType='VHDFile'
						Capacity=[Math]::Round($blob.Properties.'Content-Length'/1024/1024/1024,0)               
						Container=$container.Name
						VHDName=$blob.name
						Uri= "{0}{1}/{2}" -f $fresponse.EnumerationResults.ServiceEndpoint,$Container.Name,$blob.Name
						LeaseState=$blob.Properties.LeaseState.ToString()
						StorageAccount= $sa.name 
						SubscriptionID = $ArmConn.SubscriptionId;
						AzureSubscription = $subscriptionInfo.displayName
						
					}
					$vhdinventory+=$cu
					
				}
			}
		}
	}
}
#upload to oms
$jsonvhdpool = ConvertTo-Json -InputObject $vhdinventory
If($jsonvhdpool){$OMSRES=Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($jsonvhdpool)) -logType $logname}
if($OMSRES -ge 200 -and $omsres -lt 300)
{
	Write-Output " $($vhdinventory.count) VHD inventory uploaded to OMS"
}
Else
{
	Write-Warning "Failed to upload VHD inventory to OMS"
}
#endregion

#region Inventory Queues 
$sa=$null
$queueinventory=@()
$queuearr=@()
Foreach ($sa in $salist|where{$_.properties.accountType -notmatch 'premium' -and $_.sku.tier -ne 'Premium' -and $_.Kind -ne 'BlobStorage'})
{
	[uri]$uriQueue="https://{0}.queue.core.windows.net?comp=list" -f $sa.name
	[xml]$Xresponse=invoke-StorageREST -sharedKey $sa.key -method GET -resource $sa.name -uri $uriQueue
	# "Checking $uriQueue"
	# $Xresponse.EnumerationResults.Queues.Queue
	IF (![String]::IsNullOrEmpty($Xresponse.EnumerationResults.Queues.Queue))
	{
		Foreach ($queue in $Xresponse.EnumerationResults.Queues.Queue)
		{
			write-verbose  "Queue found :$($sa.name) ; $($queue.name) "
			
			$queuearr+="{0};{1}" -f $queue.Name.tostring(),$sa.name
			$queueinventory+= New-Object PSObject -Property @{
				Timestamp = $timestamp
				MetricName = 'Inventory'
				InventoryType='Queue'
				StorageAccount=$sa.name
				Queue= $queue.Name
				Uri=$uriQueue.Scheme+'://'+$uriQueue.Host+'/'+$queue.Name
				SubscriptionID = $ArmConn.SubscriptionId;
				AzureSubscription = $subscriptionInfo.displayName
				
			}
		}
	}
}
$varq=Get-AzureRmAutomationVariable -Name $varQueueList -ResourceGroupName $AAResourceGroup -AutomationAccountName $AAAccount -ea 0
If ($varQ)
{
	Set-AzureRmAutomationVariable -Name $varQueueList -Encrypted 0 -Value $queuearr -ResourceGroupName $AAResourceGroup -AutomationAccountName $AAAccount 
	Write-Output " Updated automation variable with $($queuearr.count) items"
}
Else
{
	New-AzureRmAutomationVariable -Name $varQueueList -Description "Variable to store Ques list to be queired for messages, updated daily." -Value $queuearr -Encrypted 0 -ResourceGroupName $AAResourceGroup -AutomationAccountName $AAAccount 
	Write-Output " Created automation variable with $($queuearr.count) items"
}
#upload to OMS
$jsonqinv = ConvertTo-Json -InputObject  $queueinventory
# Submit the data to the API endpoint
If($jsonqinv){$postres=Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($jsonqinv)) -logType $logname}
$endtime=get-date
If ($postres -ge 200 -and $postres -lt 300)
{
	Write-Output " Succesfully uploaded $($queueinventory.Count) Queues to OMS"
}
Else
{
	Write-Warning " Failed to upload  $($queueinventory.Count) Queues to OMS"
}
#endregion


#region Collect File Inventory
$sa=$null
$Fileinventory=@()
$filearr=@()
$timestamp=(get-date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:00.000Z")
Foreach ($sa in $salist|where {$_.properties.accountType -notmatch 'premium' -and $_.sku.tier -ne 'Premium' -and $_.Kind -ne 'BlobStorage'})
{
	
	[uri]$uriFile="https://{0}.file.core.windows.net?comp=list" -f $sa.name
	
	
	[xml]$Xresponse=invoke-StorageREST -sharedKey $sa.key -method GET -resource $sa.Name -uri $uriFile

	if(![string]::IsNullOrEmpty($Xresponse.EnumerationResults.Shares.Share))
	{
		foreach($share in @($Xresponse.EnumerationResults.Shares.Share))
		{
			write-verbose  "File Share found :$($sa.name) ; $($share.Name) "
			
			$filearr+="{0};{1}" -f $Share.Name,$sa.name
			$fileinventory+= New-Object PSObject -Property @{
				Timestamp = $timestamp
				MetricName = 'Inventory'
				InventoryType='File'
				StorageAccount=$sa.name 
				FileShare=$share.Name
				Uri=$uriFile.Scheme+'://'+$uriFile.Host+'/'+$Share.Name
				Quota=$share.Properties.Quota                              
				SubscriptionID = $ArmConn.SubscriptionId;
				AzureSubscription = $subscriptionInfo.displayName
			}
		}
	}
}
$varf=Get-AzureRmAutomationVariable -Name $varFilesList -ResourceGroupName $AAResourceGroup -AutomationAccountName $AAAccount -ea 0
If ($varf)
{
	Set-AzureRmAutomationVariable -Name $varfilesList -Encrypted 0 -Value $filearr -ResourceGroupName $AAResourceGroup -AutomationAccountName $AAAccount 
	Write-Output " Updated automation variable with $($filearr.count) items"
}
Else
{
	New-AzureRmAutomationVariable -Name $varfilesList -Description "Variable to store File Sahre  list to be queired for consumption , updated daily." -Value $filearr -Encrypted 0 -ResourceGroupName $AAResourceGroup -AutomationAccountName $AAAccount 
	Write-Output " Created automation variable with $($filearr.count) items"
}
#upload to OMS
$jsonfinv = ConvertTo-Json -InputObject  $fileinventory
# Submit the data to the API endpoint
If($jsonfinv){$postres=Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($jsonfinv)) -logType $logname}
$endtime=get-date
If ($postres -ge 200 -and $postres -lt 300)
{
	Write-Output " Succesfully uploaded $($allf.count) Queues to OMS"
}
Else
{
	Write-Warning " Failed to upload  $($allf.count) Queues to OMS"
}
#endregion

#region Collect Table Inventory
$sa=$null
$tableinventory=@()
$tablearr=@{}
$timestamp=(get-date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:00.000Z")
Foreach ($sa in $salist|where{$_.properties.accountType -notmatch 'premium' -and $_.sku.tier -ne 'Premium'})
{
	[uri]$uritable="https://{0}.table.core.windows.net/Tables" -f $sa.name
	
	$rfc1123date = [DateTime]::UtcNow.ToString("r")
	$signature = Build-StorageSignature `
	-sharedKey $sa.Key `
	-date  $rfc1123date `
	-method GET -resource $sa.name -uri $uritable  -service table
	$headersforsa=  @{
		'Authorization'= "$signature"
		'x-ms-version'="$apistorage"
		'x-ms-date'="$rfc1123date"
		'Accept-Charset'='UTF-8'
		'MaxDataServiceVersion'='3.0;NetFx'
		'Accept'='application/json;odata=nometadata'
	}
	$tableresp=Invoke-WebRequest -Uri $uritable -Headers $headersforsa -Method GET  -UseBasicParsing 
	$respJson=convertFrom-Json    $tableresp.Content
	
	IF (![string]::IsNullOrEmpty($respJson.value.Tablename))
	{
		foreach($tbl in @($respJson.value.Tablename))
		{
			write-verbose  "Table found :$sa.name ; $($tbl) "
			
			#$tablearr+="{0}" -f $sa.name
			IF ([string]::IsNullOrEmpty($tablearr.Get_item($sa.name)))
			{
				$tablearr.add($sa.name,'Storageaccount') 
			}
			$tableinventory+= New-Object PSObject -Property @{
				Timestamp = $timestamp
				MetricName = 'Inventory'
				InventoryType='Table'
				StorageAccount=$sa.name
				Table=$tbl
				Uri=$uritable.Scheme+'://'+$uritable.Host+'/'+$tbl
				SubscriptionID = $ArmConn.SubscriptionId;
				AzureSubscription = $subscriptionInfo.displayName
				
			}
		}
	}
}
#upload to OMS
$jsontinv = ConvertTo-Json -InputObject  $Tableinventory
# Submit the data to the API endpoint
If($jsontinv){$postres=Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($jsontinv)) -logType $logname}
$endtime=get-date
If ($postres -ge 200 -and $postres -lt 300)
{
	Write-Output " Succesfully uploaded $($Tableinventory.count) tables  to OMS"
}
Else
{
	Write-Warning " Failed to upload  $($Tableinventory.count) tables to OMS"
}
#endregion

#region Enable metrics
$settingon='<?xml version="1.0" encoding="utf-8"?><StorageServiceProperties><MinuteMetrics><Version>1.0</Version><Enabled>true</Enabled><RetentionPolicy><Enabled>true</Enabled><Days>1</Days></RetentionPolicy><IncludeAPIs>true</IncludeAPIs></MinuteMetrics></StorageServiceProperties>'
$settingoff='<?xml version="1.0" encoding="utf-8"?><StorageServiceProperties><MinuteMetrics><Version>1.0</Version><Enabled>false</Enabled><RetentionPolicy><Enabled>true</Enabled><Days>1</Days></RetentionPolicy></MinuteMetrics></StorageServiceProperties>'
Foreach($sa in $salist|Where{$_.properties.accountType -notmatch 'premium' -and $_.sku.tier -ne 'Premium'})
{
	Foreach ($svc in $services)
	{
		[uri]$uriprop="https://{0}.{1}.core.windows.net/?restype=service&comp=properties" -f $sa.name,$svc
		[xml]$Xresponse=invoke-StorageREST -sharedKey $sa.Key -method GET -resource $sa.name -uri $uriprop  -svc $svc
		
		
		IF ($Xresponse.StorageServiceProperties.MinuteMetrics.Enabled -ne 'true')
		{
			write-output "Metrics not enabled for $($sa.Name) / $svc service"
			
			
			$response=invoke-StorageREST -sharedKey $sa.Key -method PUT -resource $sa.name -uri $uriprop  -msgbody ([System.Text.Encoding]::UTF8.GetBytes($settingon)) -svc $svc 
			If ($response.StatusCode -in 200..299)
			{
				write-output "Minute metrics are  enabled for $($sa.Name) / $svc service"
				
			}
		}
	}
}
#endregion
