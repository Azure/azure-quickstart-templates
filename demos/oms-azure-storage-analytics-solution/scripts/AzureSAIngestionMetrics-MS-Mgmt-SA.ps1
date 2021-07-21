param(
[Parameter(Mandatory=$false)] [string]$SubscriptionidFilter,
[Parameter(Mandatory=$false)] [bool] $collectionFromAllSubscriptions=$false,
[Parameter(Mandatory=$false)] [bool] $getAsmHeader=$true)


$ErrorActionPreference= "Stop"

Write-Output "RB Initial Memory  : $([System.gc]::gettotalmemory('forcefullcollection') /1MB) MB" 

#region Variables definition
# Variables definition
# Common  variables  accross solution 

$StartTime = [dateTime]::Now
$Timestampfield = "Timestamp"

#will use exact time for all inventory 
$timestamp=$StartTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:00.000Z")


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


#Variable to sync between runspaces

$hash = [hashtable]::New(@{})

$Starttimer=get-date
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
Function invoke-StorageREST($sharedKey, $method, $msgbody, $resource,$uri,$svc,$download)
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
	




	IF($download)
	{
		$resp1= Invoke-WebRequest -Uri $uri -Headers $headersforsa -Method $method -ContentType application/xml -UseBasicParsing -Body $msgbody  -OutFile "$($env:TEMP)\$resource.$($uri.LocalPath.Replace('/','.').Substring(7,$uri.LocalPath.Length-7))"

		
		#$xresp=Get-Content "$($env:TEMP)\$resource.$($uri.LocalPath.Replace('/','.').Substring(7,$uri.LocalPath.Length-7))"
		return "$($env:TEMP)\$resource.$($uri.LocalPath.Replace('/','.').Substring(7,$uri.LocalPath.Length-7))"


	}Else{
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
				$resp1= Invoke-WebRequest -Uri $uri -Headers $headersforsa -Method $method -ContentType application/xml -UseBasicParsing -Body $msgbody -ea 0

				$xresp=$resp1.Content.Substring($resp1.Content.IndexOf("<")) 
				return $xresp
			}Elseif($method -eq 'HEAD')
			{
				$resp1= Invoke-WebRequest -Uri $uri -Headers $headersforsa -Method $method -ContentType application/xml -UseBasicParsing -Body $msgbody 

				
				return $resp1
			}
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


	#usage     Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($jsonlogs)) -logType $logname
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

	Try{
		$response = Invoke-WebRequest -Uri $uri -Method POST  -ContentType $contentType -Headers $OMSheaders -Body $body -UseBasicParsing
	}catch [Net.WebException] 
	{
		$ex=$_.Exception
		If ($_.Exception.Response.StatusCode.value__) {
			$exrespcode = ($_.Exception.Response.StatusCode.value__ ).ToString().Trim();
			#Write-Output $crap;
		}
		If  ($_.Exception.Message) {
			$exMessage = ($_.Exception.Message).ToString().Trim();
			#Write-Output $crapMessage;
		}
		$errmsg= "$exrespcode : $exMessage"
	}

	if ($errmsg){return $errmsg }
	Else{	return $response.StatusCode }
	#write-output $response.StatusCode
	Write-error $error[0]
}


function Cleanup-Variables {

	Get-Variable |

	Where-Object { $startupVariables -notcontains $_.Name } |

	% { Remove-Variable -Name “$($_.Name)” -Force -Scope “global” }

}


#endregion

#region Login to Azure Using both ARM , ASM and REST
#Authenticate to Azure with SPN section
"Logging in to Azure..."
$ArmConn = Get-AutomationConnection -Name AzureRunAsConnection 

if ($ArmConn  -eq $null)
{
	throw "Could not retrieve connection asset AzureRunAsConnection,  Ensure that runas account  exists in the Automation account."
}

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

#try to authenticate with ASM

if ($getAsmHeader) {
    
	try
    {
        $AsmConn = Get-AutomationConnection -Name AzureClassicRunAsConnection -ea 0
       
    }
    Catch
    {
        if ($AsmConn -eq $null) {
            Write-Warning "Could not retrieve connection asset AzureClassicRunAsConnection. Ensure that runas account exist and valid in the Automation account."
            $getAsmHeader=$false
        }
    }
     if ($AsmConn -eq $null) {
        Write-Warning "Could not retrieve connection asset AzureClassicRunAsConnection. Ensure that runas account exist and valid in the Automation account. Quota usage infomration for classic accounts will no tbe collected"
        $getAsmHeader=$false
    }Else{

        $CertificateAssetName = $AsmConn.CertificateAssetName
        $AzureCert = Get-AutomationCertificate -Name $CertificateAssetName
        if ($AzureCert -eq $null)
        {
            Write-Warning  "Could not retrieve certificate asset: $CertificateAssetName. Ensure that this asset exists and valid  in the Automation account."
            $getAsmHeader=$false
        }
        Else{

        "Logging into Azure Service Manager"
        Write-Verbose "Authenticating to Azure with certificate." -Verbose
        Set-AzureSubscription -SubscriptionName $AsmConn.SubscriptionName -SubscriptionId $AsmConn.SubscriptionId -Certificate $AzureCert
        Select-AzureSubscription -SubscriptionId $AsmConn.SubscriptionId
        #finally create the headers for ASM REST 
        $headerasm = @{"x-ms-version"="2013-08-01"}
        }
    }

}



#get subscriptionlist

$SubscriptionsURI="https://management.azure.com/subscriptions?api-version=2016-06-01" 
$Subscriptions = Invoke-RestMethod -Uri  $SubscriptionsURI -Method GET  -Headers $headers -UseBasicParsing 
$Subscriptions=@($Subscriptions.value)


IF($collectionFromAllSubscriptions -and $Subscriptions.count -gt 1 )
{
	Write-Output "$($Subscriptions.count) Subscription found , additonal runbook jobs will be created to collect data "
	$AAResourceGroup = Get-AutomationVariable -Name 'AzureSAIngestion-AzureAutomationResourceGroup-MS-Mgmt-SA'
	$AAAccount = Get-AutomationVariable -Name 'AzureSAIngestion-AzureAutomationAccount-MS-Mgmt-SA'
	$MetricsRunbookName = "AzureSAIngestionMetrics-MS-Mgmt-SA"

	#we will process first subscription with this runbook and  pass the rest to additional jobs

	$n=$Subscriptions.count-1
	#$subslist=$Subscriptions[-$n..-1]
	#remove existing subsription from list 
	$subslist=$subscriptions|where {$_.subscriptionId  -ne $subscriptionId}
	Foreach($item in $subslist)
	{

		$params1 = @{"SubscriptionidFilter"=$item.subscriptionId;"collectionFromAllSubscriptions" = $false;"getAsmHeader"=$false}
		Start-AzureRmAutomationRunbook -AutomationAccountName $AAAccount -Name $MetricsRunbookName -ResourceGroupName $AAResourceGroup -Parameters $params1 | out-null
	}
}


#endregion

#region Get Storage account list

"$(GEt-date) - Get ARM storage Accounts "

$Uri="https://management.azure.com/subscriptions/{1}/providers/Microsoft.Storage/storageAccounts?api-version={0}"   -f  $ApiVerSaArm,$SubscriptionId 
$armresp=Invoke-RestMethod -Uri $uri -Method GET  -Headers $headers -UseBasicParsing
$saArmList=$armresp.Value
"$(GEt-date)  $($saArmList.count) classic storage accounts found"

#get Classic SA

"$(GEt-date)  Get Classic storage Accounts "

$Uri="https://management.azure.com/subscriptions/{1}/providers/Microsoft.ClassicStorage/storageAccounts?api-version={0}"   -f  $ApiVerSaAsm,$SubscriptionId 

$asmresp=Invoke-RestMethod -Uri $uri -Method GET  -Headers $headers -UseBasicParsing
$saAsmList=$asmresp.value

"$(GEt-date)  $($saAsmList.count) storage accounts found"

#endregion

#region Cache Storage Account Name , RG name and Build paramter array

$colParamsforChild=@()

foreach($sa in $saArmList|where {$_.Sku.tier -ne 'Premium'})
{

	$rg=$sku=$null

	$rg=$sa.id.Split('/')[4]

	$colParamsforChild+="$($sa.name);$($sa.id.Split('/')[4]);ARM;$($sa.sku.tier);$($sa.Kind)"
	
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
		$colParamsforChild+="$($sa.name);$($sa.id.Split('/')[4]);Classic;$tier;$($sa.Kind)"
	}

	

}

#clean up variables which is not needed 
Write-Output "Core Count  $([System.Environment]::ProcessorCount)"
#endregion

#check if there are Storage accounts to process if not  then exit
if($colParamsforChild.count -eq 0)
{
	Write-Output " No Storage account found under subscription $subscriptionid , please note that Premium storage does not support metrics and excluded from the collection!"
	exit
}


#populate Storage Account inventory 

#region collect Storage account inventory 
$SAInventory=@()
$sa=$null

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
	IF ($t.properties.encryption.services.blob){$cu|Add-Member -MemberType NoteProperty -Name blobEncryption -Value 'enabled'}
	IF ($t.properties.encryption.services.file){$cu|Add-Member -MemberType NoteProperty -Name fileEncryption -Value 'enabled'}
	$SAInventory+=$cu
}
#Add Classic SA
foreach($sa in $saAsmList)
{
	$rg=$sa.id.Split('/')[4]
	$cu=$iotype=$null
	IF($sa.properties.accountType -like 'Standard*')
	{$iotype='Standard'}Else{$iotype='Premium'}
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

#populate Storgae Account Quota Usage 
#region get Storage Quota Consumption
$quotas=@()

IF($getAsmHeader)
{
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
}

$SAMAX=$SACurrent=$SAquotapct=$null
$usageuri="https://management.azure.com/subscriptions/"+$subscriptionid+"/providers/Microsoft.Storage/usages?api-version=2016-05-01"
$usageapi = Invoke-RestMethod -Uri $usageuri -Method GET -Headers $Headers  -UseBasicParsing
$usagecontent=$usageapi.value
$SAquotapct=$usagecontent[0].currentValue/$usagecontent[0].Limit*100
[int]$SAMAX=$usagecontent[0].limit
[int]$SACurrent=$usagecontent[0].currentValue

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

# Using powershell runspaces to cache  all storage account keys 
#region parallel with RS 

# Will use runspace pool with  to cache all storage account keys 

#Variable to sync between runspaces
$hash = [hashtable]::New(@{})
$hash['Host']=$host
$hash['subscriptionInfo']=$subscriptionInfo
$hash['ArmConn']=$ArmConn
$hash['AsmConn']=$AsmConn
$hash['headers']=$headers
$hash['headerasm']=$headers
$hash['AzureCert']=$AzureCert
$hash['Timestampfield']=$Timestampfield
$hash['customerID'] =$customerID
$hash['syncInterval']=$syncInterval
$hash['sharedKey']=$sharedKey 
$hash['Logname']=$logname
$hash['ApiVerSaAsm']=$ApiVerSaAsm
$hash['ApiVerSaArm']=$ApiVerSaArm
$hash['ApiStorage']=$ApiStorage
$hash['AAAccount']=$AAAccount
$hash['AAResourceGroup']=$AAResourceGroup

$hash['debuglog']=$true

$hash['saTransactionsMetrics']=@()
$hash['saCapacityMetrics']=@()
$hash['tableInventory']=@()
$hash['fileInventory']=@()
$hash['queueInventory']=@()
$hash['vhdinventory']=@()

$SAInfo=@()
$hash.'SAInfo'=$sainfo

$Throttle = [int][System.Environment]::ProcessorCount+1  #threads

$sessionstate = [system.management.automation.runspaces.initialsessionstate]::CreateDefault()
$runspacepool = [runspacefactory]::CreateRunspacePool(1, $Throttle, $sessionstate, $Host)
$runspacepool.Open() 
[System.Collections.ArrayList]$Jobs = @()

#endregion

#script to get storage account keys
# Script populates  $hash.SAInfo  with all storage account list and keys
$scriptBlockGetKeys={

	Param ($hash,[array]$Sa,$rsid)

	$subscriptionInfo=$hash.subscriptionInfo
	$ArmConn=$hash.ArmConn
	$headers=$hash.headers
	$AsmConn=$hash.AsmConn
	$headerasm=$hash.headerasm
	$AzureCert=$hash.AzureCert

	$Timestampfield = $hash.Timestampfield

	$Currency=$hash.Currency
	$Locale=$hash.Locale
	$RegionInfo=$hash.RegionInfo
	$OfferDurableId=$hash.OfferDurableId
	$syncInterval=$Hash.syncInterval
	$customerID =$hash.customerID 
	$sharedKey = $hash.sharedKey
	$logname=$hash.Logname
	$StartTime = [dateTime]::Now
	$ApiVerSaAsm = $hash.ApiVerSaAsm
	$ApiVerSaArm = $hash.ApiVerSaArm
	$ApiStorage=$hash.ApiStorage
	$AAAccount = $hash.AAAccount
	$AAResourceGroup = $hash.AAResourceGroup
	$debuglog=$hash.deguglog



#Inventory variables
	$varQueueList="AzureSAIngestion-List-Queues"
	$varFilesList="AzureSAIngestion-List-Files"

	$subscriptionId=$subscriptionInfo.subscriptionId




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
	Function invoke-StorageREST($sharedKey, $method, $msgbody, $resource,$uri,$svc,$download)
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
		




		IF($download)
		{
			$resp1= Invoke-WebRequest -Uri $uri -Headers $headersforsa -Method $method -ContentType application/xml -UseBasicParsing -Body $msgbody  -OutFile "$($env:TEMP)\$resource.$($uri.LocalPath.Replace('/','.').Substring(7,$uri.LocalPath.Length-7))"

			
			#$xresp=Get-Content "$($env:TEMP)\$resource.$($uri.LocalPath.Replace('/','.').Substring(7,$uri.LocalPath.Length-7))"
			return "$($env:TEMP)\$resource.$($uri.LocalPath.Replace('/','.').Substring(7,$uri.LocalPath.Length-7))"


		}Else{
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
					$resp1= Invoke-WebRequest -Uri $uri -Headers $headersforsa -Method $method -ContentType application/xml -UseBasicParsing -Body $msgbody -ea 0

					$xresp=$resp1.Content.Substring($resp1.Content.IndexOf("<")) 
					return $xresp
				}Elseif($method -eq 'HEAD')
				{
					$resp1= Invoke-WebRequest -Uri $uri -Headers $headersforsa -Method $method -ContentType application/xml -UseBasicParsing -Body $msgbody 

					
					return $resp1
				}
			}
		}
	}

#endregion


#initialize the variables 
	$prikey=$storageaccount=$rg=$type=$null
	$storageaccount =$sa.Split(';')[0]
	$rg=$sa.Split(';')[1]
	$type=$sa.Split(';')[2]
	$tier=$sa.Split(';')[3]
	$kind=$sa.Split(';')[4]


	If($type -eq 'ARM')
	{
		$Uri="https://management.azure.com/subscriptions/{3}/resourceGroups/{2}/providers/Microsoft.Storage/storageAccounts/{1}/listKeys?api-version={0}"   -f  $ApiVerSaArm, $storageaccount,$rg,$SubscriptionId 
		$keyresp=Invoke-RestMethod -Uri $uri -Method POST  -Headers $headers -UseBasicParsing
		$prikey=$keyresp.keys[0].value


	}Elseif($type -eq 'Classic')
	{
		$uri=$keyresp=$null
		$Uri="https://management.azure.com/subscriptions/{3}/resourceGroups/{2}/providers/Microsoft.ClassicStorage/storageAccounts/{1}/listKeys?api-version={0}"   -f  $ApiVerSaAsm,$storageaccount,$rg,$SubscriptionId 
		$keyresp=Invoke-RestMethod -Uri $uri -Method POST  -Headers $headers -UseBasicParsing
		$prikey=$keyresp.primaryKey


	}Else
	{
		
		"Could not detect storage account type, $storageaccount will not be processed"
		Continue
		

	}

#check if metrics are enabled
	IF ($kind -eq 'BlobStorage')
	{
		$svclist=@('blob','table')
	}Else
	{
		$svclist=@('blob','table','queue')
	}


	$logging=$false

	Foreach ($svc in $svclist)
	{


		
		[uri]$uriSvcProp = "https://{0}.{1}.core.windows.net/?restype=service&comp=properties	" -f $storageaccount,$svc

		IF($svc -eq 'table')
		{
			[xml]$SvcPropResp= invoke-StorageREST -sharedKey $prikey -method GET -resource $storageaccount -uri $uriSvcProp -svc Table
			
		}else
		{
			[xml]$SvcPropResp= invoke-StorageREST -sharedKey $prikey -method GET -resource $storageaccount -uri $uriSvcProp 
			
		}

		IF($SvcPropResp.StorageServiceProperties.Logging.Read -eq 'true' -or $SvcPropResp.StorageServiceProperties.Logging.Write -eq 'true' -or $SvcPropResp.StorageServiceProperties.Logging.Delete -eq 'true')
		{
			$msg="Logging is enabled for {0} in {1}" -f $svc,$storageaccount
			#Write-output $msg

			$logging=$true

			

			
		}
		Else {
			$msg="Logging is not  enabled for {0} in {1}" -f $svc,$storageaccount

		}


	}


	$hash.SAInfo+=New-Object PSObject -Property @{
		StorageAccount = $storageaccount
		Key=$prikey
		Logging=$logging
		Rg=$rg
		Type=$type
		Tier=$tier
		Kind=$kind

	}


}

Write-Output "After Runspace creation  $([System.gc]::gettotalmemory('forcefullcollection') /1MB) MB"
write-output "$($colParamsforChild.count) objects will be processed "

$i=1 
$Starttimer=get-date
$colParamsforChild|foreach{

	$splitmetrics=$null
	$splitmetrics=$_
	$Job = [powershell]::Create().AddScript($scriptBlockGetKeys).AddArgument($hash).AddArgument($splitmetrics).Addargument($i)
	$Job.RunspacePool = $RunspacePool
	$Jobs += New-Object PSObject -Property @{
		RunNum = $i
		Pipe = $Job
		Result = $Job.BeginInvoke()

	}
	
	$i++
}

write-output  "$(get-date)  , started $i Runspaces "
Write-Output "After dispatching runspaces $([System.gc]::gettotalmemory('forcefullcollection') /1MB) MB"
$jobsClone=$jobs.clone()
Write-Output "Waiting.."

# Wait untill all keys are collected 

$s=1
Do {

	Write-Output "  $(@($jobs.result.iscompleted|where{$_  -match 'False'}).count)  jobs remaining"

	foreach ($jobobj in $JobsClone)
	{

		if ($Jobobj.result.IsCompleted -eq $true)
		{
			$jobobj.Pipe.Endinvoke($jobobj.Result)
			$jobobj.pipe.dispose()
			$jobs.Remove($jobobj)
		}
	}


	IF($([System.gc]::gettotalmemory('forcefullcollection') /1MB) -gt 200)
	{
		[gc]::Collect()
	}


	IF($s%10 -eq 0) 
	{
		Write-Output "Job $s - Mem: $([System.gc]::gettotalmemory('forcefullcollection') /1MB) MB"
	}  
	$s++
	
	Start-Sleep -Seconds 15


} While ( @($jobs.result.iscompleted|where{$_  -match 'False'}).count -gt 0)
Write-output "All jobs completed!"

#Clean up  runspace jobs and reclaim memory
$jobs|foreach{$_.Pipe.Dispose()}


if(Get-Variable -Name Jobs ){Remove-Variable Jobs -Force -Scope Global }
if(Get-Variable -Name Job ){Remove-Variable Job -Force -Scope Global }
if(Get-Variable -Name Jobobj ){Remove-Variable Jobobj -Force -Scope Global }
if(Get-Variable -Name Jobsclone ){Remove-Variable Jobsclone -Force -Scope Global }
$runspacepool.Close()
[gc]::Collect()


# Will utilize runspace pool to collect all metrics for each storage account

$scriptBlockGetMetrics={


	Param ($hash,$Sa,$rsid)

#Syncronize variables
	$subscriptionInfo=$hash.subscriptionInfo
	$ArmConn=$hash.ArmConn
	$headers=$hash.headers
	$AsmConn=$hash.AsmConn
	$headerasm=$hash.headerasm
	$AzureCert=$hash.AzureCert

	$Timestampfield = $hash.Timestampfield

	$Currency=$hash.Currency
	$Locale=$hash.Locale
	$RegionInfo=$hash.RegionInfo
	$OfferDurableId=$hash.OfferDurableId
	$syncInterval=$Hash.syncInterval
	$customerID =$hash.customerID 
	$sharedKey = $hash.sharedKey
	$logname=$hash.Logname
	$StartTime = [dateTime]::Now
	$ApiVerSaAsm = $hash.ApiVerSaAsm
	$ApiVerSaArm = $hash.ApiVerSaArm
	$ApiStorage=$hash.ApiStorage
	$AAAccount = $hash.AAAccount
	$AAResourceGroup = $hash.AAResourceGroup
	$debuglog=$hash.deguglog

#Inventory variables
	$varQueueList="AzureSAIngestion-List-Queues"
	$varFilesList="AzureSAIngestion-List-Files"
	$subscriptionId=$subscriptionInfo.subscriptionId


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
	Function invoke-StorageREST($sharedKey, $method, $msgbody, $resource,$uri,$svc,$download)
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
		




		IF($download)
		{
			$resp1= Invoke-WebRequest -Uri $uri -Headers $headersforsa -Method $method -ContentType application/xml -UseBasicParsing -Body $msgbody  -OutFile "$($env:TEMP)\$resource.$($uri.LocalPath.Replace('/','.').Substring(7,$uri.LocalPath.Length-7))"

			
			#$xresp=Get-Content "$($env:TEMP)\$resource.$($uri.LocalPath.Replace('/','.').Substring(7,$uri.LocalPath.Length-7))"
			return "$($env:TEMP)\$resource.$($uri.LocalPath.Replace('/','.').Substring(7,$uri.LocalPath.Length-7))"


		}Else{
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
					$resp1= Invoke-WebRequest -Uri $uri -Headers $headersforsa -Method $method -ContentType application/xml -UseBasicParsing -Body $msgbody -ea 0

					$xresp=$resp1.Content.Substring($resp1.Content.IndexOf("<")) 
					return $xresp
				}Elseif($method -eq 'HEAD')
				{
					$resp1= Invoke-WebRequest -Uri $uri -Headers $headersforsa -Method $method -ContentType application/xml -UseBasicParsing -Body $msgbody 

					
					return $resp1
				}
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


		#usage     Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($jsonlogs)) -logType $logname
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

		Try{
			$response = Invoke-WebRequest -Uri $uri -Method POST  -ContentType $contentType -Headers $OMSheaders -Body $body -UseBasicParsing
		}catch [Net.WebException] 
		{
			$ex=$_.Exception
			If ($_.Exception.Response.StatusCode.value__) {
				$exrespcode = ($_.Exception.Response.StatusCode.value__ ).ToString().Trim();
				#Write-Output $crap;
			}
			If  ($_.Exception.Message) {
				$exMessage = ($_.Exception.Message).ToString().Trim();
				#Write-Output $crapMessage;
			}
			$errmsg= "$exrespcode : $exMessage"
		}

		if ($errmsg){return $errmsg }
		Else{	return $response.StatusCode }
		#write-output $response.StatusCode
		Write-error $error[0]
	}






#endregion

	$prikey=$sa.key
	$storageaccount =$sa.StorageAccount
	$rg=$sa.rg
	$type=$sa.Type
	$tier=$sa.Tier
	$kind=$sa.Kind

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

#define filter for metric query
	$fltr1='?$filter='+"PartitionKey%20ge%20'"+$MetricColstartTime+"'%20and%20PartitionKey%20le%20'"+$MetricColendTime+"'%20and%20RowKey%20eq%20'user;All'"
	$slct1='&$select=PartitionKey,TotalRequests,TotalBillableRequests,TotalIngress,TotalEgress,AverageE2ELatency,AverageServerLatency,PercentSuccess,Availability,PercentThrottlingError,PercentNetworkError,PercentTimeoutError,SASAuthorizationError,PercentAuthorizationError,PercentClientOtherError,PercentServerOtherError'


	$sa=$null
	$vhdinventory=@()
	$allContainers=@()
	$queueinventory=@()
	$queuearr=@()
	$queueMetrics=@()
	$Fileinventory=@()
	$filearr=@()
	$invFS=@()
	$fileshareinventory=@()
	$tableinventory=@()
	$tablearr=@{}

	$vmlist=@()
	$allvms=@()
	$allvhds=@()


#region Transaction Metrics 

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
		#"$(GEt-date)- Metircs query  $tablename for    $($storageaccount) completed. "
		
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
				
				$hash['saTransactionsMetrics']+=$cu
				

			}

			
		}
	}

#endregion

#region Capacity metrics 
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
		$hash['saCapacityMetrics']+=$cu
		
	}

#endregion

#region Inventory Queues 

	IF($tier -notmatch 'premium' -and $kind -ne 'BlobStorage')
	{
		[uri]$uriQueue="https://{0}.queue.core.windows.net?comp=list" -f $storageaccount
		[xml]$Xresponse=invoke-StorageREST -sharedKey $prikey -method GET -resource $storageaccount -uri $uriQueue
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
					ShowinDesigner=1
				}

				#collect metrics

				
				[uri]$uriforq="https://$storageaccount.queue.core.windows.net/$($queue.name)/messages?peekonly=true"
				[xml]$Xmlqresp= invoke-StorageREST -sharedKey $prikey -method GET -resource $storageaccount -uri $uriforq 
				
				[uri]$uriform="https://$storageaccount.queue.core.windows.net/$($queue.name)?comp=metadata"
				$Xmlqrespm= invoke-StorageREST -sharedKey $prikey -method HEAD -resource $storageaccount -uri $uriform
				
				
				$cuq=$null
				$cuq+= New-Object PSObject -Property @{
					Timestamp=$timestamp
					MetricName = 'QueueMetrics';
					StorageAccount=$storageaccount
					StorageService="Queue" 
					Queue= $queue.Name
					approximateMsgCount=$Xmlqrespm.Headers.'x-ms-approximate-messages-count' 
					SubscriptionId = $ArmConn.SubscriptionId;
					AzureSubscription = $subscriptionInfo.displayName
				}

				$msg=$Xmlqresp.QueueMessagesList.QueueMessage
				IF(![string]::IsNullOrEmpty($Xmlqresp.QueueMessagesList))
				{
					$cuq|Add-Member -MemberType NoteProperty -Name FirstMessageID -Value $msg.MessageId
					$cuq|Add-Member -MemberType NoteProperty -Name FirstMessageText -Value $msg.MessageText
					$cuq|Add-Member -MemberType NoteProperty -Name FirstMsgInsertionTime -Value $msg.InsertionTime
					$cuq|Add-Member -MemberType NoteProperty -Name Minutesinqueue -Value [Math]::Round(((Get-date).ToUniversalTime()-[datetime]($Xmlqresp.QueueMessagesList.QueueMessage.InsertionTime)).Totalminutes,0)
				}

				$hash['tableInventory']+=$cuq
				



			}

		}
	}

#endregion

#region Collect File Share Inventory

	IF($tier -notmatch 'premium' -and $kind -ne 'BlobStorage')
	{
		
		[uri]$uriFile="https://{0}.file.core.windows.net?comp=list" -f $storageaccount
		
		
		[xml]$Xresponse=invoke-StorageREST -sharedKey $prikey -method GET -resource $storageaccount -uri $uriFile

		if(![string]::IsNullOrEmpty($Xresponse.EnumerationResults.Shares.Share))
		{
			foreach($share in @($Xresponse.EnumerationResults.Shares.Share))
			{
				write-verbose  "File Share found :$($storageaccount) ; $($share.Name) "
				$filelist=@()			


				$filearr+="{0};{1}" -f $Share.Name,$storageaccount

				
				$cuf= New-Object PSObject -Property @{
					Timestamp = $timestamp
					MetricName = 'Inventory'
					InventoryType='File'
					StorageAccount=$storageaccount
					FileShare=$share.Name
					Uri=$uriFile.Scheme+'://'+$uriFile.Host+'/'+$Share.Name
					Quota=$share.Properties.Quota                              
					SubscriptionID = $ArmConn.SubscriptionId;
					AzureSubscription = $subscriptionInfo.displayName
					ShowinDesigner=1
				}

				[uri]$uriforF="https://{0}.file.core.windows.net/{1}?restype=share&comp=stats" -f $storageaccount,$share.Name 
				[xml]$Xmlresp=invoke-StorageREST -sharedKey $prikey -method GET -resource $storageaccount -uri $uriforF 
				
				IF($Xmlresp)
				{       
					$cuf|Add-Member -MemberType NoteProperty -Name  ShareUsedGB -Value $([int]$Xmlresp.ShareStats.ShareUsage)
				} 
				
				$hash['fileInventory']+=$cuf

			}
		}
	}

#endregion

#region Collect Table Inventory
	IF($tier -notmatch 'premium')
	{
		[uri]$uritable="https://{0}.table.core.windows.net/Tables" -f $storageaccount
		
		$rfc1123date = [DateTime]::UtcNow.ToString("r")
		$signature = Build-StorageSignature `
		-sharedKey $prikey
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
				write-verbose  "Table found :$storageaccount ; $($tbl) "
				
				#$tablearr+="{0}" -f $sa.name
				IF ([string]::IsNullOrEmpty($tablearr.Get_item($storageaccount)))
				{
					$tablearr.add($sa.name,'Storageaccount') 
				}
				
				
				$hash['queueInventory']+= New-Object PSObject -Property @{
					Timestamp = $timestamp
					MetricName = 'Inventory'
					InventoryType='Table'
					StorageAccount=$storageaccount
					Table=$tbl
					Uri=$uritable.Scheme+'://'+$uritable.Host+'/'+$tbl
					SubscriptionID = $ArmConn.SubscriptionId;
					AzureSubscription = $subscriptionInfo.displayName
					ShowinDesigner=1
					
				}
			}
		}
	}

#endregion

#region  collect VHD inventory 
# we will do blob scan only every 4 hour 

	if ((get-date).hour -in (1,5,9,13,17,21) -and   (get-date).minute -in (1..16)   )
	{

		[uri]$uriListC= "https://{0}.blob.core.windows.net/?comp=list" -f $storageaccount
		
		Write-verbose "$(get-date) - Getting list of blobs for $($sa.name) "
		[xml]$lb=invoke-StorageREST -sharedKey $prikey -method GET -resource $storageaccount -uri $uriListC
		$containers=@($lb.EnumerationResults.Containers.Container)
		
		IF(![string]::IsNullOrEmpty($lb.EnumerationResults.Containers.Container))
		{
			Foreach($container in @($containers))
			{
				$allcontainers+=$container
				[uri]$uriLBlobs = "https://{0}.blob.core.windows.net/{1}/?comp=list&include=metadata&maxresults=1000&restype=container" -f $storageaccount,$container.name
				[xml]$fresponse= invoke-StorageREST -sharedKey $prikey -method GET -resource $storageaccount -uri $uriLBlobs
				
				$filesincontainer=@()

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
							StorageAccount= $storageaccount
							SubscriptionID = $ArmConn.SubscriptionId;
							AzureSubscription = $subscriptionInfo.displayName
							ShowinDesigner=1
							
						}
						
						$hash['vhdinventory']+=$cu
						
					}

					
				}

				$filesincontainer|Group-Object Fileextension|select Name,count

				$fileshareinventory+=$filesincontainer
			}
		}

	}
#endregion

}

#endregion

$Throttle = [System.Environment]::ProcessorCount+1
$sessionstate = [system.management.automation.runspaces.initialsessionstate]::CreateDefault()
$runspacepool = [runspacefactory]::CreateRunspacePool(1, $Throttle, $sessionstate, $Host)
$runspacepool.Open() 
[System.Collections.ArrayList]$Jobs = @()

Write-Output "After Runspace creation for metric collection : $([System.gc]::gettotalmemory('forcefullcollection') /1MB) MB"

$i=1 
$Starttimer=get-date

$hash.SAInfo|foreach{

	$splitmetrics=$null
	$splitmetrics=$_
	$Job = [powershell]::Create().AddScript($scriptBlockGetMetrics).AddArgument($hash).AddArgument($splitmetrics).Addargument($i)
	$Job.RunspacePool = $RunspacePool
	$Jobs += New-Object PSObject -Property @{
		RunNum = $i
		Pipe = $Job
		Result = $Job.BeginInvoke()

	}
	
	$i++
}

write-output  "$(get-date)  , started $i Runspaces "
Write-Output "After dispatching runspaces $([System.gc]::gettotalmemory('forcefullcollection') /1MB) MB"
$jobsClone=$jobs.clone()
Write-Output "Waiting.."


#wait all runspaces finish

$s=1
Do {

	Write-Output "  $(@($jobs.result.iscompleted|where{$_  -match 'False'}).count)  jobs remaining"

	foreach ($jobobj in $JobsClone)
	{

		if ($Jobobj.result.IsCompleted -eq $true)
		{
			$jobobj.Pipe.Endinvoke($jobobj.Result)
			$jobobj.pipe.dispose()
			$jobs.Remove($jobobj)
		}
	}




	IF($s%2 -eq 0) 
	{
		Write-Output " Mem: $([System.gc]::gettotalmemory('forcefullcollection') /1MB) MB"
	}  
	$s++

	Start-Sleep -Seconds 15


} While ( @($jobs.result.iscompleted|where{$_  -match 'False'}).count -gt 0)
Write-output "All jobs completed!"


# Clean up variables

$jobs|foreach{$_.Pipe.Dispose()}
Remove-Variable Jobs -Force -Scope Global
Remove-Variable Job -Force -Scope Global
Remove-Variable Jobobj -Force -Scope Global
Remove-Variable Jobsclone -Force -Scope Global
$runspacepool.Close()

$([System.gc]::gettotalmemory('forcefullcollection') /1MB)


$Endtimer=get-date

Write-Output "All jobs completed in $(($Endtimer-$starttimer).TotalMinutes) minutes"


#region Upload all collected metrics to OMS
# Will split metrics into batches of 5000 to avoid hitting any limits 

Write-Output "Uploading to OMS ..."

$splitSize=5000

If($hash.saTransactionsMetrics)
{

	write-output  "Uploading  $($hash.saTransactionsMetrics.count) transaction metrics"
	$uploadToOms=$hash.saTransactionsMetrics
	$hash.saTransactionsMetrics=@()
	
	If($uploadToOms.count -gt $splitSize)
	{
		$spltlist=@()
		$spltlist+=for ($Index = 0; $Index -lt $uploadToOms.count; $Index += $splitSize)
		{
			,($uploadToOms[$index..($index+$splitSize-1)])
		}
		
		
		$spltlist|foreach{
			$splitLogs=$null
			$splitLogs=$_
			$jsonlogs= ConvertTo-Json -InputObject $splitLogs
			Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($jsonlogs)) -logType $logname

		}



	}Else{

		$jsonlogs= ConvertTo-Json -InputObject $uploadToOms

		Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($jsonlogs)) -logType $logname


	}
	Remove-Variable uploadToOms -Force -Scope Global -ErrorAction SilentlyContinue
	Remove-Variable jsonlogs -Force -Scope Global -ErrorAction SilentlyContinue
	Remove-Variable spltlist -Force -Scope Global -ErrorAction SilentlyContinue
	[System.gc]::Collect()
}


If($hash.saCapacityMetrics)
{

	write-output  "Uploading  $($hash.saCapacityMetrics.count) capacity metrics"
	$uploadToOms=$hash.saCapacityMetrics
	$hash.saCapacityMetrics=@()
	
	If($uploadToOms.count -gt $splitSize)
	{
		$spltlist=@()
		$spltlist+=for ($Index = 0; $Index -lt $uploadToOms.count; $Index += $splitSize)
		{
			,($uploadToOms[$index..($index+$splitSize-1)])
		}
		
		
		$spltlist|foreach{
			$splitLogs=$null
			$splitLogs=$_
			$jsonlogs= ConvertTo-Json -InputObject $splitLogs
			Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($jsonlogs)) -logType $logname

		}



	}Else{

		$jsonlogs= ConvertTo-Json -InputObject $uploadToOms

		Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($jsonlogs)) -logType $logname

	}
	Remove-Variable uploadToOms -Force -Scope Global  -ErrorAction SilentlyContinue
	Remove-Variable jsonlogs -Force -Scope Global -ErrorAction SilentlyContinue
	Remove-Variable spltlist -Force -Scope Global -ErrorAction SilentlyContinue
	[System.gc]::Collect()
}

If($hash.tableInventory)
{
	write-output  "Uploading  $($hash.tableInventory.count) table inventory"
	$uploadToOms=$hash.tableInventory

	$hash.tableInventory=@()

	If($uploadToOms.count -gt $splitSize)
	{
		$spltlist=@()
		$spltlist+=for ($Index = 0; $Index -lt $uploadToOms.count; $Index += $splitSize)
		{
			,($uploadToOms[$index..($index+$splitSize-1)])
		}
		
		
		$spltlist|foreach{
			$splitLogs=$null
			$splitLogs=$_
			$jsonlogs= ConvertTo-Json -InputObject $splitLogs
			Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($jsonlogs)) -logType $logname

		}



	}Else{

		$jsonlogs= ConvertTo-Json -InputObject $uploadToOms

		Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($jsonlogs)) -logType $logname

	}
	Remove-Variable uploadToOms -Force -Scope Global -ErrorAction SilentlyContinue
	Remove-Variable jsonlogs -Force -Scope Global -ErrorAction SilentlyContinue
	Remove-Variable spltlist -Force -Scope Global -ErrorAction SilentlyContinue
	[System.gc]::Collect()
}


If(!$hash.queueInventory)
{

	$hash.queueInventory+=New-Object PSObject -Property @{
		Timestamp = $timestamp
		MetricName = 'Inventory'
		InventoryType='Queue'
		Queue= "NO RESOURCE FOUND"
		Uri="NO RESOURCE FOUND"
		SubscriptionID = $ArmConn.SubscriptionId;
		AzureSubscription = $subscriptionInfo.displayName
		ShowinDesigner=0
	}
}

write-output  "Uploading  $($hash.queueInventory.count) queue inventory"
$uploadToOms=$hash.queueInventory
$hash.queueInventory=@()

If($uploadToOms.count -gt $splitSize)
{
	$spltlist=@()
	$spltlist+=for ($Index = 0; $Index -lt $uploadToOms.count; $Index += $splitSize)
	{
		,($uploadToOms[$index..($index+$splitSize-1)])
	}
	
	
	$spltlist|foreach{
		$splitLogs=$null
		$splitLogs=$_
		$jsonlogs= ConvertTo-Json -InputObject $splitLogs
		Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($jsonlogs)) -logType $logname

	}



}Else{

	$jsonlogs= ConvertTo-Json -InputObject $uploadToOms

	Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($jsonlogs)) -logType $logname

}
Remove-Variable uploadToOms -Force -Scope Global  -ErrorAction SilentlyContinue
Remove-Variable jsonlogs -Force -Scope Global  -ErrorAction SilentlyContinue
Remove-Variable spltlist -Force -Scope Global  -ErrorAction SilentlyContinue
[System.gc]::Collect()


If(!$hash.fileInventory)
{


	$hash.fileInventory+=New-Object PSObject -Property @{
		Timestamp = $timestamp
		MetricName = 'Inventory'
		InventoryType='File'
		FileShare="NO RESOURCE FOUND"
		Uri="NO RESOURCE FOUND"                       
		SubscriptionID = $ArmConn.SubscriptionId;
		AzureSubscription = $subscriptionInfo.displayName
		ShowinDesigner=0
	}
	
}

write-output  "Uploading  $($hash.fileInventory.count) file inventory"
$uploadToOms=$hash.fileInventory
$hash.fileInventory=@()

If($uploadToOms.count -gt $splitSize)
{
	$spltlist=@()
	$spltlist+=for ($Index = 0; $Index -lt $uploadToOms.count; $Index += $splitSize)
	{
		,($uploadToOms[$index..($index+$splitSize-1)])
	}
	
	
	$spltlist|foreach{
		$splitLogs=$null
		$splitLogs=$_
		$jsonlogs= ConvertTo-Json -InputObject $splitLogs

		Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($jsonlogs)) -logType $logname

	}



}Else{

	$jsonlogs= ConvertTo-Json -InputObject $uploadToOms


	Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($jsonlogs)) -logType $logname

}
Remove-Variable uploadToOms -Force -Scope Global -ErrorAction SilentlyContinue
Remove-Variable jsonlogs -Force -Scope Global -ErrorAction SilentlyContinue
Remove-Variable spltlist -Force -Scope Global -ErrorAction SilentlyContinue
[System.gc]::Collect()



If(!$hash.vhdinventory)
{


	$hash.vhdinventory+= New-Object PSObject -Property @{
		Timestamp = $timestamp
		MetricName = 'Inventory'
		InventoryType='VHDFile'
		VHDName="NO RESOURCE FOUND"
		Uri= "NO RESOURCE FOUND"
		SubscriptionID = $ArmConn.SubscriptionId;
		AzureSubscription = $subscriptionInfo.displayName
		ShowinDesigner=0		
	}        

}

write-output  "Uploading  $($hash.vhdinventory.count) vhd inventory"
$uploadToOms=$hash.vhdinventory
$hash.vhdinventory=@()

If($uploadToOms.count -gt $splitSize)
{
	$spltlist=@()
	$spltlist+=for ($Index = 0; $Index -lt $uploadToOms.count; $Index += $splitSize)
	{
		,($uploadToOms[$index..($index+$splitSize-1)])
	}
	
	
	$spltlist|foreach{
		$splitLogs=$null
		$splitLogs=$_
		$jsonlogs= ConvertTo-Json -InputObject $splitLogs

		Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($jsonlogs)) -logType $logname

	}



}Else{

	$jsonlogs= ConvertTo-Json -InputObject $uploadToOms

	Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($jsonlogs)) -logType $logname
	
	
}
Remove-Variable uploadToOms -Force -Scope Global -ErrorAction SilentlyContinue
Remove-Variable jsonlogs -Force -Scope Global -ErrorAction SilentlyContinue
Remove-Variable spltlist -Force -Scope Global -ErrorAction SilentlyContinue
[System.gc]::Collect()

#endregion

" Final Memory Consumption: $([System.gc]::gettotalmemory('forcefullcollection') /1MB) MB"

#upload done



