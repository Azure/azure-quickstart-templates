#region Variables definition
# Variables definition
# Common  variables  accross solution 

$StartTime = [dateTime]::Now
$Timestampfield = "Timestamp"

#will use exact time for all inventory 
$timestamp=$StartTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:45:00.000Z")


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

$childrunbook="AzureSAIngestionChild-MS-Mgmt-SA"
$schedulename="AzureStorageIngestionChild-Schedule-MS-Mgmt-SA"

#Inventory variables
$varQueueList="AzureSAIngestion-List-Queues"
$varFilesList="AzureSAIngestion-List-Files"


#Define VMSizes - Fetch from variable but failback to hardcoded if needed 
$vmiolimits = Get-AutomationVariable -Name 'AzureSAIngestion-VM-IOPSLimits'

IF(!$vmiolimits)
{
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
}


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

#get blob file size in gb 

function Get-BlobSize ($bloburi,$storageaccount,$rg,$type)
{

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





$vhdblob=invoke-StorageREST -sharedKey $prikey -method HEAD -resource $storageaccount -uri $bloburi
	
Return [math]::round($vhdblob.Headers.'Content-Length'/1024/1024/1024,0)



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


#region Get Storage account list

"$(GEt-date)  Get ARM storage Accounts "

$Uri="https://management.azure.com/subscriptions/{1}/providers/Microsoft.Storage/storageAccounts?api-version={0}"   -f  $ApiVerSaArm,$SubscriptionId 
$armresp=Invoke-WebRequest -Uri $uri -Method GET  -Headers $headers -UseBasicParsing
$saArmList=(ConvertFrom-Json -InputObject $armresp.Content).Value

"$(GEt-date)  $($saArmList.count) storage accounts found"

#get Classic SA
"$(GEt-date)  Get Classic storage Accounts "

$Uri="https://management.azure.com/subscriptions/{1}/providers/Microsoft.ClassicStorage/storageAccounts?api-version={0}"   -f  $ApiVerSaAsm,$SubscriptionId 

$sresp=Invoke-WebRequest -Uri $uri -Method GET  -Headers $headers -UseBasicParsing
$saAsmList=(ConvertFrom-Json -InputObject $sresp.Content).value

"$(GEt-date)  $($saAsmList.count) storage accounts found"
#endregion



#region Cache Storage Account Name , RG name and Build paramter array

$colParamsforChild=@()

foreach($sa in $saArmList|where {$_.Sku.tier -ne 'Premium'})
{

	$rg=$sku=$null

	$rg=$sa.id.Split('/')[4]

	$colParamsforChild+="$($sa.name);$($sa.id.Split('/')[4]);ARM;$($sa.sku.tier)"
	
}

#Add Classic SA
$sa=$rg=$null

foreach($sa in $saAsmList|where{$_.properties.accounttype -notmatch 'Premium'})
{

	$rg=$sa.id.Split('/')[4]
	$tier=$null

# array  wth SAName,ReouceGroup,Prikey,Tier 

	If( $sa.properties.accountType -notmatch 'premium')
	{
		$tier='Standard'
		$colParamsforChild+="$($sa.name);$($sa.id.Split('/')[4]);Classic;$tier"
	}

	

}


#endregion



#batch jobs and start them every 15 min 
$Till = (Get-Date).AddMinutes(15)  
$MetricColTime=(get-date).addhours(1).ToUniversalTime()
$spltlist=@()

#define batch job size based on total storage accouns
If($colParamsforChild.Count  -In 1..20){$splitSize=10} 
ElseIf($colParamsforChild.Count  -In 21..40){$splitSize=20} 
Else{$splitSize=30} 

" {1} SA will be split into $splitSize in  {0}  Runbooks" -f $([Math]::Round(($colParamsforChild.Count/$splitSize),0)+1), $colParamsforChild.Count

#If($colParamsforChild.Count -gt 40) {$splitSize=30} 
#region Clean up Automation Schedules and Creat new ones
$SchRB=Get-AzureRmAutomationScheduledRunbook -AutomationAccountName $AAAccount 		-ResourceGroupName $AAResourceGroup -RunbookName $childrunbook
IF($SchRB)
{
	foreach ($sch in $SchRB)
	{
		Unregister-AzureRmAutomationScheduledRunbook -AutomationAccountName $AAAccount -ResourceGroupName $AAResourceGroup -RunbookName $childrunbook -ScheduleName $sch.ScheduleName -Force
		
	}
}
$sch=$null
$RBsch=Get-AzureRmAutomationSchedule -AutomationAccountName $AAAccount -ResourceGroupName $AAResourceGroup|where{$_.name -match $ScheduleName}
IF($RBsch)
{
	foreach ($sch in $RBsch)
	{
		Remove-AzureRmAutomationSchedule -AutomationAccountName $AAAccount -Name $sch.Name -ResourceGroupName $AAResourceGroup -Force
		
	}
}


#Define collection time intervals

$Schtime=Get-Date

If($Schtime.Minute -in 0..15)
{
    $start1=(get-date -Minute 00 -Second 00).AddHours(1).ToUniversalTime() 
    $start2=(get-date -Minute 15 -Second 00).AddHours(1).ToUniversalTime() 
    $start3=(get-date -Minute 30 -Second 00).ToUniversalTime() 
    $start4=(get-date -Minute 45 -Second 00).ToUniversalTime() 
}
Elseif($Schtime.Minute -in 16..30)
{
    $start1=(get-date -Minute 00 -Second 00).AddHours(1).ToUniversalTime() 
    $start2=(get-date -Minute 15 -Second 00).AddHours(1).ToUniversalTime() 
    $start3=(get-date -Minute 30 -Second 00).AddHours(1).ToUniversalTime() 
    $start4=(get-date -Minute 45 -Second 00).ToUniversalTime() 
}
Else
{
    $start1=(get-date -Minute 00 -Second 00).AddHours(1).ToUniversalTime() 
    $start2=(get-date -Minute 15 -Second 00).AddHours(1).ToUniversalTime() 
    $start3=(get-date -Minute 30 -Second 00).AddHours(1).ToUniversalTime() 
    $start4=(get-date -Minute 45 -Second 00).AddHours(1).ToUniversalTime() 
}







If ($colParamsforChild.Count -lt $splitSize)
{
	$params1 = @{"Salist"=$colParamsforChild;"EnableExtraMetrics" = $false}
	
	Write-Verbose "Creating schedule $ScheduleName-$Count for $RunbookStartTime for runbook $RunbookName"
	$Schedule1 = New-AzureRmAutomationSchedule -Name "$ScheduleName-1" -StartTime $start1  -HourInterval 1 -AutomationAccountName $AAAccount -ResourceGroupName $AAResourceGroup
	$Schedule2 = New-AzureRmAutomationSchedule -Name "$ScheduleName-2" -StartTime $start2  -HourInterval 1 -AutomationAccountName $AAAccount -ResourceGroupName $AAResourceGroup
	$Schedule3 = New-AzureRmAutomationSchedule -Name "$ScheduleName-3" -StartTime $start3  -HourInterval 1 -AutomationAccountName $AAAccount -ResourceGroupName $AAResourceGroup
	$Schedule4 = New-AzureRmAutomationSchedule -Name "$ScheduleName-4" -StartTime $start4  -HourInterval 1 -AutomationAccountName $AAAccount -ResourceGroupName $AAResourceGroup
	
	Register-AzureRmAutomationScheduledRunbook 	-AutomationAccountName $AAAccount -Parameters $Params1  -ResourceGroupName  $AAResourceGroup   -RunbookName $childrunbook  -ScheduleName "$schedulename-1"
	Register-AzureRmAutomationScheduledRunbook 	-AutomationAccountName $AAAccount -Parameters $Params1  -ResourceGroupName  $AAResourceGroup   -RunbookName $childrunbook  -ScheduleName "$schedulename-2"
	Register-AzureRmAutomationScheduledRunbook 	-AutomationAccountName $AAAccount -Parameters $Params1  -ResourceGroupName  $AAResourceGroup   -RunbookName $childrunbook  -ScheduleName "$schedulename-3"
	Register-AzureRmAutomationScheduledRunbook 	-AutomationAccountName $AAAccount -Parameters $Params1  -ResourceGroupName  $AAResourceGroup   -RunbookName $childrunbook  -ScheduleName "$schedulename-4"
}
Else
{
	$spltlist+=for ($Index = 0; $Index -lt $colParamsforChild.Count; $Index += $splitSize)
	{
		,($colParamsforChild[$index..($index+$splitSize-1)])
	}
	
	$Count = 0
	Foreach($item in $spltlist)
	{
		$params=$null
		$count ++
		$params1 = @{"Salist"=$item;"EnableExtraMetrics" = $false}
		
		Write-Verbose "Creating schedule $ScheduleName-$Count for $RunbookStartTime for runbook $RunbookName"
		$Schedule1 = New-AzureRmAutomationSchedule -Name "$ScheduleName-$Count-1" -StartTime  $start1 -HourInterval 1 -AutomationAccountName $AAAccount -ResourceGroupName $AAResourceGroup
		$Schedule2 = New-AzureRmAutomationSchedule -Name "$ScheduleName-$Count-2" -StartTime  $start2 -HourInterval 1 -AutomationAccountName $AAAccount -ResourceGroupName $AAResourceGroup
		$Schedule3 = New-AzureRmAutomationSchedule -Name "$ScheduleName-$Count-3" -StartTime  $start3 -HourInterval 1 -AutomationAccountName $AAAccount -ResourceGroupName $AAResourceGroup
		$Schedule4 = New-AzureRmAutomationSchedule -Name "$ScheduleName-$Count-4" -StartTime  $start4 -HourInterval 1 -AutomationAccountName $AAAccount -ResourceGroupName $AAResourceGroup
		
		Register-AzureRmAutomationScheduledRunbook 	-AutomationAccountName $AAAccount -Parameters $Params1  -ResourceGroupName  $AAResourceGroup   -RunbookName $childrunbook  -ScheduleName "$ScheduleName-$Count-1" |Out-Null
		Register-AzureRmAutomationScheduledRunbook 	-AutomationAccountName $AAAccount -Parameters $Params1  -ResourceGroupName  $AAResourceGroup   -RunbookName $childrunbook  -ScheduleName "$ScheduleName-$Count-2" |Out-Null
		Register-AzureRmAutomationScheduledRunbook 	-AutomationAccountName $AAAccount -Parameters $Params1  -ResourceGroupName  $AAResourceGroup   -RunbookName $childrunbook  -ScheduleName "$ScheduleName-$Count-3" |Out-Null
		Register-AzureRmAutomationScheduledRunbook 	-AutomationAccountName $AAAccount -Parameters $Params1  -ResourceGroupName  $AAResourceGroup   -RunbookName $childrunbook  -ScheduleName "$ScheduleName-$Count-4" |Out-Null
		
		"$(get-date) - Assigned new schedules batch $count"
		
	}
}

#region collect Storage account inventory 
$SAInventory=@()
foreach($sa in $saArmList)
{
	$rg=$sa.id.Split('/')[4]
	$cu=$null
	$cu = New-Object PSObject -Property @{
		Timestamp = $timestamp
		MetricName = 'Inventory';
		InventoryType='StorageAccount'
		StorageAccount=$sa.name
		Uri="https://management.azure.com"+$sa.id
		DeploymentType='ARM'
		Location=$sa.location
		Kind=$sa.kind
		ResourceGroup=$rg
		Sku=$sa.sku.name
		Tier=$sa.sku.tier
		
		SubscriptionId = $ArmConn.SubscriptionId;
		AzureSubscription = $subscriptionInfo.displayName
	}
	
	IF ($sa.properties.creationTime){$cu|Add-Member -MemberType NoteProperty -Name CreationTime -Value $sa.properties.creationTime}
	IF ($sa.properties.primaryLocation){$cu|Add-Member -MemberType NoteProperty -Name PrimaryLocation -Value $sa.properties.primaryLocation}
	IF ($sa.properties.secondaryLocation){$cu|Add-Member -MemberType NoteProperty -Name secondaryLocation-Value $sa.properties.secondaryLocation}
	IF ($sa.properties.statusOfPrimary){$cu|Add-Member -MemberType NoteProperty -Name statusOfPrimary -Value $sa.properties.statusOfPrimary}
	IF ($sa.properties.statusOfSecondary){$cu|Add-Member -MemberType NoteProperty -Name statusOfSecondary -Value $sa.properties.statusOfSecondary}
	IF ($sa.kind -eq 'BlobStorage'){$cu|Add-Member -MemberType NoteProperty -Name accessTier -Value $sa.properties.accessTier}
	$SAInventory+=$cu
}
#Add Classic SA
foreach($sa in $saAsmList)
{
	$rg=$sa.id.Split('/')[4]
	$cu=$iotype=$null
	IF($sa.properties.accountType -like 'Standard*')
	{$iotype='Standard'}Else{{$iotype='Premium'}}
	$cu = New-Object PSObject -Property @{
		Timestamp = $timestamp
		MetricName = 'Inventory'
		InventoryType='StorageAccount'
		StorageAccount=$sa.name
		Uri="https://management.azure.com"+$sa.id
		DeploymentType='Classic'
		Location=$sa.location
		Kind='Storage'
		ResourceGroup=$rg
		Sku=$sa.properties.accountType
		Tier=$iotype
		SubscriptionId = $ArmConn.SubscriptionId;
		AzureSubscription = $subscriptionInfo.displayName
	}
	
	IF ($sa.properties.creationTime){$cu|Add-Member -MemberType NoteProperty -Name CreationTime -Value $sa.properties.creationTime}
	IF ($sa.properties.geoPrimaryRegion){$cu|Add-Member -MemberType NoteProperty -Name PrimaryLocation -Value $sa.properties.geoPrimaryRegion.Replace(' ','')}
	IF ($sa.properties.geoSecondaryRegion ){$cu|Add-Member -MemberType NoteProperty -Name SecondaryLocation-Value $sa.properties.geoSecondaryRegion.Replace(' ','')}
	IF ($sa.properties.statusOfPrimaryRegion){$cu|Add-Member -MemberType NoteProperty -Name statusOfPrimary -Value $sa.properties.statusOfPrimaryRegion}
	IF ($sa.properties.statusOfSecondaryRegion){$cu|Add-Member -MemberType NoteProperty -Name statusOfSecondary -Value $sa.properties.statusOfSecondaryRegion}
	
	$SAInventory+=$cu
}

$jsonSAInventory = ConvertTo-Json -InputObject $SAInventory
If($jsonSAInventory){Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($jsonSAInventory)) -logType $logname}
"$(get-date)  - SA Inventory  data  uploaded"
#endregion


#region get Storage Quota Consumption
$quotas=@()
$uri="https://management.core.windows.net/$subscriptionId"
$qresp=Invoke-WebRequest -Uri $uri -Method GET  -Headers $headerasm -UseBasicParsing -Certificate $AzureCert
[xml]$qres=$qresp.Content
[int]$SAMAX=$qres.Subscription.MaxStorageAccounts
[int]$SACurrent=$qres.Subscription.CurrentStorageAccounts
$Quotapct=$qres.Subscription.CurrentStorageAccounts/$qres.Subscription.MaxStorageAccounts*100  
$quotas+= New-Object PSObject -Property @{
	Timestamp = $timestamp
	MetricName = 'StorageQuotas';
	QuotaType="Classic"
	SAMAX=$samax
	SACurrent=$SACurrent
	Quotapct=$Quotapct     
	SubscriptionId = $ArmConn.SubscriptionId;
	AzureSubscription = $subscriptionInfo.displayName;
	
}
$SAMAX=$SACurrent=$SAquotapct=$null
$usageuri="https://management.azure.com/subscriptions/"+$subscriptionid+"/providers/Microsoft.Storage/usages?api-version=2016-05-01"
$usageapi = Invoke-WebRequest -Uri $usageuri -Method GET -Headers $Headers  -UseBasicParsing
$usagecontent= ConvertFrom-Json -InputObject $usageapi.Content
$usagecontent.value.limit
$usagecontent.value.currentValue
$SAquotapct=$usagecontent.value.currentValue/$usagecontent.value.Limit*100
[int]$SAMAX=$usagecontent.value.limit
[int]$SACurrent=$usagecontent.value.currentValue

$quotas+= New-Object PSObject -Property @{
	Timestamp = $timestamp
	MetricName = 'StorageQuotas';
	QuotaType="ARM"
	SAMAX=$SAMAX
	SACurrent=$SACurrent
	Quotapct=$SAquotapct     
	SubscriptionId = $ArmConn.SubscriptionId;
	AzureSubscription = $subscriptionInfo.displayName;
	
}
#submit data to oms
$jsonquotas = ConvertTo-Json -InputObject $quotas
If($jsonquotas){Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($jsonquotas)) -logType $logname}
"$(get-date)  - Quota info uploaded"
#endregion

#region collect VHD data 
#Get Providers 
## only VM attached VHD s listed here , decide to keep it or offload all to metric enabler 
$uri="https://management.azure.com/subscriptions/"+$subscriptionid+"/providers?api-version=2016-02-01"
$resultarm = Invoke-WebRequest -Method GET -Uri $uri -Headers $headers -UseBasicParsing
$content=$resultarm.Content
$content= ConvertFrom-Json -InputObject $resultarm.Content
$uri="https://management.azure.com/subscriptions/"+$subscriptionid+"/providers?api-version=2016-02-01"
$resultarm = Invoke-WebRequest -Method GET -Uri $uri -Headers $headers -UseBasicParsing
$usageuri="https://management.azure.com/subscriptions/"+$subscriptionid+"/providers/Microsoft.Storage?api-version=2016-09-01"
$providers=@()

Foreach($item in $content.value)
{
	foreach ($rgobj in $item.resourceTypes)
	{
		$properties = @{'ID'=$item.id;
			'namespace'=$item.namespace;
			'Resourcetype'=$rgobj.resourceType;
			'Apiversion'=$rgobj.apiVersions[0]}
		$object = New-Object –TypeName PSObject –Prop $properties
		$providers+=$object
	}
}

$vmlist=@()
$allvms=@()
$allvhds=@()

Foreach ($prvitem in $providers|where{$_.resourcetype -eq 'virtualMachines'})
{
	$uri="https://management.azure.com"+$prvitem.id+"/$($prvitem.Resourcetype)?api-version=$($prvitem.apiversion)"
	# this list can be used to dynamically get  the latest api available
	$resultarm = Invoke-WebRequest -Method $HTTPVerb -Uri $uri -Headers $headers -UseBasicParsing
	$content=$resultarm.Content
	$content= ConvertFrom-Json -InputObject $resultarm.Content
	$vmlist+=$content.value

    IF(![string]::IsNullOrEmpty($content.nextLink))
    {
        do 
        {
            $uri2=$content.nextLink
            $content=$null
             $resultarm = Invoke-WebRequest -Method $HTTPVerb -Uri $uri2 -Headers $headers -UseBasicParsing
	            $content=$resultarm.Content
	            $content= ConvertFrom-Json -InputObject $resultarm.Content
	            $vmlist+=$content.value

        $uri2=$null
        }While (![string]::IsNullOrEmpty($content.nextLink))
    }
}



$vmsclassic=$vmlist|where {$_.type -eq 'Microsoft.ClassicCompute/virtualMachines'}
$vmsarm=$vmlist|where {$_.type -eq 'Microsoft.Compute/virtualMachines'}
$vm=$cu=$null

Foreach ($vm in $vmsclassic)
{


#first get os disk then iterate data disks 

   IF(![string]::IsNullOrEmpty($vm.properties.storageProfile.operatingSystemDisk.storageAccount.Name))
    {	


        $safordisk=$SAInventory|where {$_.StorageAccount -eq $vm.properties.storageProfile.operatingSystemDisk.storageAccount.Name}
        $IOtype=$safordisk.Tier

	    $sizeingb=$null
        $sizeingb=Get-BlobSize -bloburi $([uri]$vm.properties.storageProfile.operatingSystemDisk.vhdUri) -storageaccount $safordisk.StorageAccount -rg $safordisk.ResourceGroup -type Classic



	         $cu = New-Object PSObject -Property @{
		Timestamp = $timestamp
		MetricName = 'Inventory';
		InventoryType='VHDIOPs'
		Deploymentname=$vm.properties.hardwareProfile.deploymentName.ToString()
		DeploymentType='Classic'
		Location=$vm.location
		VmName=$vm.Name
		VHDUri=$vm.properties.storageProfile.operatingSystemDisk.vhdUri
		DiskIOType=$IOtype
		StorageAccount=$vm.properties.storageProfile.operatingSystemDisk.storageAccount.Name
		SubscriptionId = $ArmConn.SubscriptionId;
		AzureSubscription = $subscriptionInfo.displayName
		SizeinGB=$sizeingb
		
	}
	

         IF ($IOtype -eq 'Standard' -and $vm.properties.hardwareProfile.size.ToString() -like  'Basic*')
	    {
		    $cu|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 300
	    }ElseIf  ($IOtype -eq 'Standard' )
	    {
		    $cu|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 500
        }Elseif($IOtype -eq 'Premium')
        {
            $cu|Add-Member -MemberType NoteProperty -Name MaxVMIO -Value $vmiolimits.Item($vm.properties.hardwareProfile.size)

              
           if ($cu.SizeinGB -le 128 )
           {
                $cu|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 500
           }Elseif ($cu.SizeinGB -in  129..512 )
           {
                $cu|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 2300
           }Elseif ($cu.SizeinGB -in  513..1024 )
           {
                $cu|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 5000
           }
        }
        
        $allvhds+=$cu
    }

#check data disks 
	IF($vm.properties.storageProfile.dataDisks)
	{
		$ddisks=$null
		$ddisks=@($vm.properties.storageProfile.dataDisks)

		Foreach($disk in $ddisks)
		{
            IF(![string]::IsNullOrEmpty($disk.storageAccount.Name))
            {	
			        $safordisk=$null
			        $safordisk=$SAInventory|where {$_ -match $disk.storageAccount.Name}
			        $IOtype=$safordisk.Tier

			        $cu = New-Object PSObject -Property @{
				        Timestamp = $timestamp
				        MetricName = 'Inventory';
				        InventoryType='VHDIOPs'
				        Deploymentname=$vm.properties.hardwareProfile.deploymentName.ToString()
				        DeploymentType='Classic'
				        Location=$vm.location
				        VmName=$vm.Name
				        VHDUri=$disk.vhdUri
				        DiskIOType=$IOtype
				        StorageAccount=$disk.storageAccount.Name
				        SubscriptionId = $ArmConn.SubscriptionId;
				        AzureSubscription = $subscriptionInfo.displayName
				        SizeinGB=$disk.diskSize
				
			        }
			

  
                 IF ($IOtype -eq 'Standard' -and $vm.properties.hardwareProfile.size.ToString() -like  'Basic*')
	            {
		            $cu|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 300
	            }ElseIf  ($IOtype -eq 'Standard' )
	            {
		            $cu|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 500
                }Elseif($IOtype -eq 'Premium')
                {
                   if ($cu.SizeinGB -le 128 )
                   {
                        $cu|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 500
                   }Elseif ($cu.SizeinGB -in  129..512 )
                   {
                        $cu|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 2300
                   }Elseif ($cu.SizeinGB -in  513..1024 )
                   {
                        $cu|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 5000
                   }
                }

			    $allvhds+=$cu    
		      }
		   }
	}
	
}


#forarm
$vm=$cu=$osdisk=$null
Foreach ($vm in $vmsarm)
{
   
    $osdisk=$saforVm=$IOtype=$null
   IF(![string]::IsNullOrEmpty($vm.properties.storageProfile.osDisk.vhd.uri))
    {	

        $osdisk=[uri]$vm.properties.storageProfile.osDisk.vhd.uri

        $saforVm=$SAInventory|where {$_.StorageAccount -eq $osdisk.host.Substring(0,$osdisk.host.IndexOf('.')) } 
	    IF($saforvm)
	            {
		$IOtype=$saforvm.tier
	}
	    $sizeingb=$null
        $sizeingb=Get-BlobSize -bloburi $([uri]$vm.properties.storageProfile.osDisk.vhd.uri) -storageaccount $saforvm.StorageAccount -rg $saforVm.ResourceGroup -type ARM

	     $cu = New-Object PSObject -Property @{
		        Timestamp = $timestamp
		        MetricName = 'Inventory';
		        InventoryType='VHDIOPs'
		        Deploymentname=$vm.id.split('/')[4]   # !!! consider chnaging this to ResourceGroup here or in query
		        DeploymentType='ARM'
		        Location=$vm.location
		        VmName=$vm.Name
		        VHDUri=$vm.properties.storageProfile.osDisk.vhd.uri
		        #arm does not expose this need to queri it from $colParamsforChild
		        DiskIOType=$IOtype
		        StorageAccount=$saforVM.StorageAccount
		        SubscriptionId = $ArmConn.SubscriptionId;
		        AzureSubscription = $subscriptionInfo.displayName
		        SizeinGB=[long]$sizeingb
                } -ea 0

	    IF ($cu.DiskIOType -eq 'Standard' -and $vm.properties.hardwareProfile.vmSize.ToString() -like  'BAsic*')
	            {
		$cu|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 300
	}ElseIf  ($cu.DiskIOType -eq 'Standard' -and $vm.properties.hardwareProfile.vmSize.ToString() -like 'Standard*')
	            {
		$cu|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 500
	}Elseif($IOtype -eq 'Premium')
        {
            $cu|Add-Member -MemberType NoteProperty -Name MaxVMIO -Value $vmiolimits.Item($vm.properties.hardwareProfile.vmSize)
              
           if ($cu.SizeinGB -le 128 )
           {
                $cu|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 500
                 
           }Elseif ($cu.SizeinGB -in  129..512 )
           {
                $cu|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 2300
           }Elseif ($cu.SizeinGB -in  513..1024 )
           {
                $cu|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 5000
           }
        }
        $allvhds+=$cu    
    
    }
    Else
    {

        $cu = New-Object PSObject -Property @{
		    Timestamp = $timestamp
		    MetricName = 'Inventory';
		    InventoryType='ManagedDisk'
		    Deploymentname=$vm.id.split('/')[4]   # !!! consider chnaging this to ResourceGroup here or in query
		    DeploymentType='ARM'
		    Location=$vm.location
		    VmName=$vm.Name
		    Uri="https://management.azure.com/{0}" -f $vm.properties.storageProfile.osDisk.managedDisk.id
		    StorageAccount=$vm.properties.storageProfile.osDisk.managedDisk.id
		    SubscriptionId = $ArmConn.SubscriptionId;
		    AzureSubscription = $subscriptionInfo.displayName
		    SizeinGB=128
                } -ea 0

	    IF ($vm.properties.storageProfile.osDisk.managedDisk.storageAccountType -match 'Standard')
	    {
		    $cu|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 500
            $cu|Add-Member -MemberType NoteProperty -Name DiskIOType -Value 'Standard'

	    }Elseif($vm.properties.storageProfile.osDisk.managedDisk.storageAccountType -match  'Premium')
        {
            $cu|Add-Member -MemberType NoteProperty -Name MaxVMIO -Value $vmiolimits.Item($vm.properties.hardwareProfile.vmSize)
                 $cu|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 500
                  $cu|Add-Member -MemberType NoteProperty -Name DiskIOType -Value 'Premium'

           }
           $allvhds+=$cu
     }

               
	#check for Data disks 
	iF ($vm.properties.storageProfile.dataDisks)
	{
		$ddisks=$null
		$ddisks=@($vm.properties.storageProfile.dataDisks)
		Foreach($disk in $ddisks)
		{

               IF(![string]::IsNullOrEmpty($disk.vhd.uri))
            {	
			        $diskuri=$safordisk=$IOtype=$null
			        $diskuri=[uri]$disk.vhd.uri
			        $safordisk=$SAInventory|where {$_ -match $diskuri.host.Substring(0,$diskuri.host.IndexOf('.')) }
			        $IOtype=$safordisk.Tier
			        $cu = New-Object PSObject -Property @{
				        Timestamp = $timestamp
				        MetricName = 'Inventory';
				        InventoryType='VHDIOPs'
				        Deploymentname=$vm.id.split('/')[4] 
				        DeploymentType='ARM'
				        Location=$vm.location
				        VmName=$vm.Name
				        VHDUri=$disk.vhd.uri
				        DiskIOType=$IOtype
				        StorageAccount=$safordisk.StorageAccount
				        SubscriptionId = $ArmConn.SubscriptionId;
				        AzureSubscription = $subscriptionInfo.displayName
				        SizeinGB=[long]$disk.diskSizeGB
				
			        } -ea 0 
			
			IF ($cu.DiskIOType -eq 'Standard' -and $vm.properties.hardwareProfile.vmSize.ToString() -like  'BAsic*')
			{
				$cu|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 300
			}ElseIf  ($cu.DiskIOType -eq 'Standard' -and $vm.properties.hardwareProfile.vmSize.ToString() -like 'Standard*')
			{
				$cu|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 500
			}Elseif($IOtype -eq 'Premium')
            {
                $cu|Add-Member -MemberType NoteProperty -Name MaxVMIO -Value $vmiolimits.Item($vm.properties.hardwareProfile.vmSize)
              
               if ($cu.SizeinGB -le 128 )
               {
                    $cu|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 500
               }Elseif ($cu.SizeinGB -in  129..512 )
               {
                    $cu|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 2300
               }Elseif ($cu.SizeinGB -in  513..1024 )
               {
                    $cu|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 5000
               }
           }
                       
			$allvhds+=$cu
    		}
            Else
            {
                 $cu = New-Object PSObject -Property @{
		            Timestamp = $timestamp
		            MetricName = 'Inventory';
		            InventoryType='ManagedDisk'
		            Deploymentname=$vm.id.split('/')[4]   # !!! consider chnaging this to ResourceGroup here or in query
		            DeploymentType='ARM'
		            Location=$vm.location
		            VmName=$vm.Name
		            Uri="https://management.azure.com/{0}" -f $disk.manageddisk.id
		            StorageAccount=$disk.managedDisk.id
		            SubscriptionId = $ArmConn.SubscriptionId;
		            AzureSubscription = $subscriptionInfo.displayName
		            SizeinGB=[long]$disk.diskSizeGB
                        } -ea 0

               IF ($vm.properties.storageProfile.osDisk.managedDisk.storageAccountType -match 'Standard')
	            {
		            $cu|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 500
                    $cu|Add-Member -MemberType NoteProperty -Name DiskIOType -Value 'Standard'

	            }Elseif($vm.properties.storageProfile.osDisk.managedDisk.storageAccountType -match  'Premium')
                {
                    $cu|Add-Member -MemberType NoteProperty -Name MaxVMIO -Value $vmiolimits.Item($vm.properties.hardwareProfile.vmSize)
                    $cu|Add-Member -MemberType NoteProperty -Name DiskIOType -Value 'Premium'

                     if ($disk.diskSizeGB -le 128 )
               {
                    $cu|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 500
               }Elseif ($disk.diskSizeGB -in  129..512 )
               {
                    $cu|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 2300
               }Elseif ($disk.diskSizeGB -in  513..1024 )
               {
                    $cu|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 5000
               }
           }
                $allvhds+=$cu
            }


        }
	}
}


#here   we need to check if there are any Premium SA without any reference to VMs 
$premSas=@($SAInventory|where {$_.Iotype -match 'Premium'}|select storageaccount)
foreach ($premsa in $premSas.StorageAccount)
{
	IF (@($allvhds |where {$_.StorageAccount -match $premsa}).Count -eq 0 )
	{
		$sa=$null
		$sa=$SAInventory|where {$_.StorageAccount  -match $premsa}
		$allvhds+= New-Object PSObject -Property @{
			Timestamp = $timestamp
			MetricName = 'Inventory';
			InventoryType='VHDIOPs'
			Deploymentname='None'
			DeploymentType=$sa.DeploymentType
			Location=$sa.Location
			VmName='None'
			VHDUri='NullUri'
			DiskIOType='Premium'
			StorageAccount=$sa.StorageAccount
			SubscriptionId = $ArmConn.SubscriptionId;
			AzureSubscription = $subscriptionInfo.displayName
			SizeinGB=0 
			
		}
	}
}
$jsonallvhds= ConvertTo-Json -InputObject $allvhds
If($jsonallvhds){Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($jsonallvhds)) -logType $logname}
"$(get-date)  - VHD Inventory  uploaded"
#endregion


#get Queue metrics
$varq=Get-AzureRmAutomationVariable -Name $varQueueList -ResourceGroupName $AAResourceGroup -AutomationAccountName $AAAccount -ea 0
if($varq)
{
	$messgaesinQ=@()
	$invQ=@()
	$method = "GET"

	
	Foreach ($sq in $varq.Value)
	{
		
		#get keys
		$prikey=$storageaccount=$rg=$type=$null
		$storageaccount =$sq.split(';')[1]
		IF($saArmList|where{$_.name -eq $storageaccount})
		{
			$rg=$null
			$rg=($saArmList|where{$_.name -eq $storageaccount}).id.split('/')[4]
			$Uri="https://management.azure.com/subscriptions/{3}/resourceGroups/{2}/providers/Microsoft.Storage/storageAccounts/{1}/listKeys?api-version={0}"   -f  $ApiVerSaArm, $storageaccount,$rg,$SubscriptionId 
			$keyresp=Invoke-WebRequest -Uri $uri -Method POST  -Headers $headers -UseBasicParsing
			$keys=ConvertFrom-Json -InputObject $keyresp.Content
			$prikey=$keys.keys[0].value
		}Else
		{
			$RG=$null
			$rg=($saAsmList|where{$_.name -eq $storageaccount}).id.split('/')[4]
			$Uri="https://management.azure.com/subscriptions/{3}/resourceGroups/{2}/providers/Microsoft.ClassicStorage/storageAccounts/{1}/listKeys?api-version={0}"   -f  $ApiVerSaAsm,$storageaccount,$rg,$SubscriptionId 
			$keyresp=Invoke-WebRequest -Uri $uri -Method POST  -Headers $headers -UseBasicParsing
			$keys=ConvertFrom-Json -InputObject $keyresp.Content
			$prikey=$keys.primaryKey
		}
		
		
		[uri]$uriforq="https://$($sq.split(';')[1]).queue.core.windows.net/$($sq.split(';')[0])/messages?peekonly=true"
		
		[xml]$Xmlqresp= invoke-StorageREST -sharedKey $prikey -method GET -resource $storageaccount -uri $uriforq 
		
		$msg=$Xmlqresp.QueueMessagesList.QueueMessage
		IF(![string]::IsNullOrEmpty($Xmlqresp.QueueMessagesList))
		{
			
			$invQ+= New-Object PSObject -Property @{
				Timestamp=$timestamp
				MetricName = 'QueueMetrics';
				StorageAccount=$sq.split(';')[1]
				StorageService="Queue" 
				Queue= $sq.split(';')[0]
				FirstMessageID=$msg.MessageId
				FirstMessageTest=$msg.MessageText
				FirstMsgInsertionTime=$msg.InsertionTime
				Minutesinqueue=[Math]::Round(((Get-date).ToUniversalTime()-[datetime]($Xmlqresp.QueueMessagesList.QueueMessage.InsertionTime)).Totalminutes,0)
				SubscriptionId = $ArmConn.SubscriptionId;
				AzureSubscription = $subscriptionInfo.displayName
				
				
				
			}
		}
		
	}
	$jsonqinv = ConvertTo-Json -InputObject  $allq
	# Submit the data to the API endpoint
	If($jsonqinv){$postres=Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($jsonqinv)) -logType $logname}
	$endtime=get-date
	If ($postres -ge 200 -and $postres -lt 300)
	{
		Write-Output " Succesfully uploaded $($allq.count) Queues to OMS"
	}
	Else
	{
		Write-Warning " Failed to upload  $($allq.count) Queues to OMS"
	}
}


#get Azure file Share Metrics 
$varf=Get-AzureRmAutomationVariable -Name $varFilesList -ResourceGroupName $AAResourceGroup -AutomationAccountName $AAAccount -ea 0
if($varF)
{
	
	$invFS=@()
	$method = "GET"

	Foreach ($sq in $varf.Value)
	{
		
		#get keys
		$prikey=$storageaccount=$rg=$type=$null
		$storageaccount =$sq.split(';')[1]
		IF($saArmList|where{$_.name -eq $storageaccount})
		{
			$rg=$null
			$rg=($saArmList|where{$_.name -eq $storageaccount}).id.split('/')[4]
			$Uri="https://management.azure.com/subscriptions/{3}/resourceGroups/{2}/providers/Microsoft.Storage/storageAccounts/{1}/listKeys?api-version={0}"   -f  $ApiVerSaArm, $storageaccount,$rg,$SubscriptionId 
			$keyresp=Invoke-WebRequest -Uri $uri -Method POST  -Headers $headers -UseBasicParsing
			$keys=ConvertFrom-Json -InputObject $keyresp.Content
			$prikey=$keys.keys[0].value
		}Else
		{
			$RG=$null
			$rg=($saAsmList|where{$_.name -eq $storageaccount}).id.split('/')[4]
			$Uri="https://management.azure.com/subscriptions/{3}/resourceGroups/{2}/providers/Microsoft.ClassicStorage/storageAccounts/{1}/listKeys?api-version={0}"   -f  $ApiVerSaAsm,$storageaccount,$rg,$SubscriptionId 
			$keyresp=Invoke-WebRequest -Uri $uri -Method POST  -Headers $headers -UseBasicParsing
			$keys=ConvertFrom-Json -InputObject $keyresp.Content
			$prikey=$keys.primaryKey
		}
		#get file share first 
		
		[uri]$uriFile="https://{0}.file.core.windows.net?comp=list" -f $storageaccount
		
		
		[xml]$Xresponse=invoke-StorageREST -sharedKey $prikey -method GET -resource $storageaccount -uri $uriFile
		$Xresponse.EnumerationResults.Shares.Share
		
		if(![string]::IsNullOrEmpty($Xresponse.EnumerationResults.Shares.Share))
		{
			foreach($share in @($Xresponse.EnumerationResults.Shares.Share))
			{
				write-verbose  "File Share found :$storageaccount ; $($share.Name) "
				
				[uri]$uriforF="https://{0}.file.core.windows.net/{1}?restype=share&comp=stats" -f $storageaccount,$share.Name 
				[xml]$Xmlresp=invoke-StorageREST -sharedKey $prikey -method GET -resource $storageaccount -uri $uriforF 
				
				
				$invFS+= New-Object PSObject -Property @{
					Timestamp=$timestamp
					MetricName = 'Inventory'
					InventoryType='File'
					StorageAccount=$storageaccount 
					FileShare=$share.Name
					Uri="https://{0}.file.core.windows.net/{1}" -f $storageaccount,$share.Name 
					Quota=[int]$share.Properties.Quota
					ShareUsedGB=[int]$Xmlresp.ShareStats.ShareUsage
					StorageService="File" 
					SubscriptionID = $ArmConn.SubscriptionId;
					AzureSubscription = $subscriptionInfo.displayName
				}
			}
		}
#
	}
	$jsoninvfs = ConvertTo-Json -InputObject  $invFS
	# Submit the data to the API endpoint
	If($jsoninvfs){$postres=Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($jsoninvfs)) -logType $logname}
	$endtime=get-date
	If ($postres -ge 200 -and $postres -lt 300)
	{
		Write-Output " Succesfully uploaded $($invFS.count) Share usage metrics to OMS"
	}
	Else
	{
		Write-Warning " Failed to upload  $($invFS.count) Share usage metrics to OMS"
	}
}
