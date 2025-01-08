
param(
    [Parameter(Mandatory=$false)] [int] $apireadlimit=7500,
    [Parameter(Mandatory=$false)] [bool] $getarmvmstatus=$true,
    [Parameter(Mandatory=$false)] [bool] $getNICandNSG=$true,
    [Parameter(Mandatory=$false)] [bool] $getDiskInfo=$true
    
    )




#region Variables definition
# Variables definition
# Common  variables  accross solution 

$StartTime = [dateTime]::Now
$Timestampfield = "Timestamp" 

#Update customer Id to your Operational Insights workspace ID
$customerID = Get-AutomationVariable -Name  "AzureVMInventory-OPSINSIGHTS_WS_ID"

#For shared key use either the primary or seconday Connected Sources client authentication key   
$sharedKey = Get-AutomationVariable -Name  "AzureVMInventory-OPSINSIGHT_WS_KEY"

$ApiVerSaAsm = '2016-04-01'
$ApiVerSaArm = '2016-01-01'
$ApiStorage='2016-05-31'

$apiverVM='2016-02-01'




# OMS log analytics custom log name

$logname='AzureVMInventory'

# Runbook specific variables 

$VMstates = @{
"StoppedDeallocated"="Deallocated";
"ReadyRole"="Running";
"PowerState/deallocated"="Deallocated";
"PowerState/stopped" ="Stopped";
"StoppedVM" ="Stopped";
"PowerState/running" ="Running"}



#Define VMSizes - Fetch from variable but failback to hardcoded if needed 
$vmiolimits = Get-AutomationVariable -Name 'VMinfo_-IOPSLimits'  -ea 0 

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
	$subscriptionInfoUri = "https://management.azure.com/subscriptions/"+$ArmConn.SubscriptionId+"?api-version=$apiverVM"
	$subscriptionInfo = Invoke-RestMethod -Uri $subscriptionInfoUri -Headers $headers -Method Get -UseBasicParsing



  
	IF($subscriptionInfo)
	{
		"Successfully connected to Azure ARM REST;"
        $subscriptionInfo
	}
    Else
    {

        Write-warning "Unable to login to Azure ARM Rest , runbook will not continue"
        Exit

    }
}
Else
{
	Write-error "Failed to login ro Azure ARM REST  , make sure Runas account configured correctly"
	Exit
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

function Get-BlobSize ($bloburi,$storageaccount,$rg,$type)
{

	If($type -eq 'ARM')
	{
		$Uri="https://management.azure.com{3}/resourceGroups/{2}/providers/Microsoft.Storage/storageAccounts/{1}/listKeys?api-version={0}"   -f  $ApiVerSaArm, $storageaccount,$rg,$Subscriptioninfo.id 
		$keyresp=Invoke-WebRequest -Uri $uri -Method POST  -Headers $headers -UseBasicParsing
		$keys=ConvertFrom-Json -InputObject $keyresp.Content
		$prikey=$keys.keys[0].value
	}Elseif($type -eq 'Classic')
	{
		$Uri="https://management.azure.com{3}/resourceGroups/{2}/providers/Microsoft.ClassicStorage/storageAccounts/{1}/listKeys?api-version={0}"   -f  $ApiVerSaAsm,$storageaccount,$rg,$Subscriptioninfo.id
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
#endregion



$timestamp=(get-date).ToUniversalTime().ToString("yyyy-MM-ddT$($hour):$($min):00.000Z")

"Starting $(get-date)"
#################
#region StorageAccountInv

"$(GEt-date)  Get ARM storage Accounts "

$Uri="https://management.azure.com{1}/providers/Microsoft.Storage/storageAccounts?api-version={0}"   -f  $ApiVerSaArm,$Subscriptioninfo.id
$armresp=Invoke-WebRequest -Uri $uri -Method GET  -Headers $headers -UseBasicParsing
$saArmList=(ConvertFrom-Json -InputObject $armresp.Content).Value

"$(GEt-date)  $($saArmList.count) storage accounts found"

#get Classic SA
"$(GEt-date)  Get Classic storage Accounts "

$Uri="https://management.azure.com{1}/providers/Microsoft.ClassicStorage/storageAccounts?api-version={0}"   -f  $ApiVerSaAsm,$Subscriptioninfo.id

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
		
		SubscriptionId = $subscriptioninfo.subscriptionId
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
			SubscriptionId = $subscriptioninfo.subscriptionId
        AzureSubscription = $subscriptionInfo.displayName
	}
	
	IF ($sa.properties.creationTime){$cu|Add-Member -MemberType NoteProperty -Name CreationTime -Value $sa.properties.creationTime}
	IF ($sa.properties.geoPrimaryRegion){$cu|Add-Member -MemberType NoteProperty -Name PrimaryLocation -Value $sa.properties.geoPrimaryRegion.Replace(' ','')}
	IF ($sa.properties.geoSecondaryRegion ){$cu|Add-Member -MemberType NoteProperty -Name SecondaryLocation-Value $sa.properties.geoSecondaryRegion.Replace(' ','')}
	IF ($sa.properties.statusOfPrimaryRegion){$cu|Add-Member -MemberType NoteProperty -Name statusOfPrimary -Value $sa.properties.statusOfPrimaryRegion}
	IF ($sa.properties.statusOfSecondaryRegion){$cu|Add-Member -MemberType NoteProperty -Name statusOfSecondary -Value $sa.properties.statusOfSecondaryRegion}
	
	$SAInventory+=$cu
}



#endregion




#Check if  API Ream limits reached

Write-output "Starting API Limits collection "


$r = Invoke-WebRequest -Uri "https://management.azure.com$($subscriptionInfo.id)/resourcegroups?api-version=2016-09-01" -Method GET -Headers $Headers -UseBasicParsing
 
$remaining=$r.Headers["x-ms-ratelimit-remaining-subscription-reads"]

" API reads remaining: $remaining"

 $apidatafirst = New-Object PSObject -Property @{
                             MetricName = 'ARMAPILimits';
                            APIReadsRemaining=$r.Headers["x-ms-ratelimit-remaining-subscription-reads"]
                                                   
                            SubscriptionID = $subscriptionInfo.id
                            AzureSubscription = $subscriptionInfo.displayName
      
                            }


"$(get-date)   -  $($apidatafirst.APIReadsRemaining)  request available , collection will continue " 


$uri="https://management.azure.com$($subscriptionInfo.id)/resourceGroups?api-version=$apiverVM"

#$uri


$resultarm = Invoke-WebRequest -Method Get -Uri $uri -Headers $headers -UseBasicParsing

$content=$resultarm.Content
$content= ConvertFrom-Json -InputObject $resultarm.Content


$rglist=$content.value

$uri="https://management.azure.com"+$subscriptionInfo.id+"/providers?api-version=$apiverVM"

$resultarm = Invoke-WebRequest -Method $HTTPVerb -Uri $uri -Headers $headers -UseBasicParsing

$content=$resultarm.Content
$content= ConvertFrom-Json -InputObject $resultarm.Content




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
#Write-Output $object
$providers+=$object
}


}



Write-output "$(get-date) - Starting inventory for VMs "



$vmlist=@()


Foreach ($prvitem in $providers|where{$_.resourcetype -eq 'virtualMachines'})
{

$uri="https://management.azure.com"+$prvitem.id+"/$($prvitem.Resourcetype)?api-version=$($prvitem.apiversion)"

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


$vm=$cu=$cuvm=$cudisk=$null

$allvms=@()
$vmtags=@()
$allvhds=@()
$invendpoints=@()
$invnsg=@()
$invnic=@() 
$invextensions=@()
$colltime=get-date


"{0}  VM found " -f $vmlist.count




Foreach ($vm in $vmsclassic)
{

#vm inventory
#extensions 
$extlist=$null
$vm.properties.extensions|?{$extlist+=$_.extension+";"}

  $cuvm = New-Object PSObject -Property @{
                            Timestamp = $colltime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
                            MetricName = 'VMInventory';
                            ResourceGroup=$vm.id.Split('/')[4]
                            HWProfile=$vm.properties.hardwareProfile.size.ToString()
                            Deploymentname=$vm.properties.hardwareProfile.deploymentName.ToString()
                            Status=$VMstates.get_item($vm.properties.instanceView.status.ToString())
                            fqdn=$vm.properties.instanceView.fullyQualifiedDomainName
                            DeploymentType='Classic'
                            Location=$vm.location
                            VmName=$vm.Name
                            ID=$vm.id
                            OperatingSystem=$vm.properties.storageProfile.operatingSystemDisk.operatingSystem
                            privateIpAddress=$vm.properties.instanceView.privateIpAddress
                            SubscriptionId = $subscriptioninfo.subscriptionId
                             AzureSubscription = $subscriptionInfo.displayName
      
                                   }

                if($vm.properties.networkProfile.virtualNetwork)
                    {
                    $cuvm|Add-Member -MemberType NoteProperty -Name VNETName -Value $vm.properties.networkProfile.virtualNetwork.name -Force
                    $cuvm|Add-Member -MemberType NoteProperty -Name Subnet -Value  $vm.properties.networkProfile.virtualNetwork.subnetNames[0] -Force
                                  
                    }

                 if( $vm.properties.instanceView.publicIpAddresses)
                    {
                    $cuvm|Add-Member -MemberType NoteProperty -Name PublicIP -Value $vm.properties.instanceView.publicIpAddresses[0].tostring()
                    }
                              
                $allvms+=$cuvm

    #inv extensions
    IF(![string]::IsNullOrEmpty($vm.properties.extensions))
    {
    Foreach ($extobj in $vm.properties.extensions)
        {

        $invextensions+=New-Object PSObject -Property @{
                            Timestamp = $colltime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
                            MetricName = 'VMExtensions';
                           VmName=$vm.Name
                          Extension=$extobj.Extension
                          publisher=$extobj.publisher
                        version=$extobj.version
                        state=$extobj.state
                        referenceName=$extobj.referenceName
                        ID=$vm.id+"/extensions/"+$extobj.Extension
                        SubscriptionId = $subscriptioninfo.subscriptionId
                             AzureSubscription = $subscriptionInfo.displayName
                          
                                   }

        }


    }
    

    #inv endpoints

    
    $ep=$null
    IF(![string]::IsNullOrEmpty($vm.properties.networkProfile.inputEndpoints)  -and $getNICandNSG)
    {
        Foreach($ep in $vm.properties.networkProfile.inputEndpoints)
        {
            
             $invendpoints+= New-Object PSObject -Property @{
                            Timestamp = $colltime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
                            MetricName = 'VMEndpoint';
                           VmName=$vm.Name
                           endpointName=$ep.endpointName
                             publicIpAddress=$ep.publicIpAddress
                               privatePort=$ep.privatePort
                            publicPort=$ep.publicPort
                            protocol=$ep.protocol
                            enableDirectServerReturn=$ep.enableDirectServerReturn
                            SubscriptionId = $subscriptioninfo.subscriptionId
                             AzureSubscription = $subscriptionInfo.displayName
      
                                   }

        }

    }









    If($getDiskInfo)
    {
#first get os disk then iterate data disks 



   IF(![string]::IsNullOrEmpty($vm.properties.storageProfile.operatingSystemDisk.storageAccount.Name))
    {	


        $safordisk=$SAInventory|where {$_.StorageAccount -eq $vm.properties.storageProfile.operatingSystemDisk.storageAccount.Name}
        $IOtype=$safordisk.Tier

	    $sizeingb=$null
        $sizeingb=Get-BlobSize -bloburi $([uri]$vm.properties.storageProfile.operatingSystemDisk.vhdUri) -storageaccount $safordisk.StorageAccount -rg $safordisk.ResourceGroup -type Classic



	         $cudisk = New-Object PSObject -Property @{
		Timestamp = $colltime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
		MetricName = 'VMDisk';
        DiskType='Unmanaged'
		Deploymentname=$vm.properties.hardwareProfile.deploymentName.ToString()
		DeploymentType='Classic'

		Location=$vm.location
		VmName=$vm.Name
		VHDUri=$vm.properties.storageProfile.operatingSystemDisk.vhdUri
		DiskIOType=$IOtype
		StorageAccount=$vm.properties.storageProfile.operatingSystemDisk.storageAccount.Name
			SubscriptionId = $subscriptioninfo.subscriptionId
        AzureSubscription = $subscriptionInfo.displayName
		SizeinGB=$sizeingb
		
	}
	

         IF ($IOtype -eq 'Standard' -and $vm.properties.hardwareProfile.size.ToString() -like  'Basic*')
	    {
		    $cudisk|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 300
	    }ElseIf  ($IOtype -eq 'Standard' )
	    {
		    $cudisk|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 500
        }Elseif($IOtype -eq 'Premium')
        {
            $cudisk|Add-Member -MemberType NoteProperty -Name MaxVMIO -Value $vmiolimits.Item($vm.properties.hardwareProfile.size)

              
           if ($cudisk.SizeinGB -le 128 )
           {
                $cudisk|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 500
           }Elseif ($cudisk.SizeinGB -in  129..512 )
           {
                $cudisk|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 2300
           }Elseif ($cudisk.SizeinGB -in  513..1024 )
           {
                $cudisk|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 5000
           }
        }
        
        $allvhds+=$cudisk
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

			        $cudisk = New-Object PSObject -Property @{
				        Timestamp = $timestamp
				        MetricName = 'VMDisk';
                        DiskType='Unmanaged'
				        Deploymentname=$vm.properties.hardwareProfile.deploymentName.ToString()
				        DeploymentType='Classic'
				        Location=$vm.location
				        VmName=$vm.Name
				        VHDUri=$disk.vhdUri
				        DiskIOType=$IOtype
				        StorageAccount=$disk.storageAccount.Name
				        	SubscriptionId = $subscriptioninfo.subscriptionId
        AzureSubscription = $subscriptionInfo.displayName
				        SizeinGB=$disk.diskSize
				
			        }
			

  
                 IF ($IOtype -eq 'Standard' -and $vm.properties.hardwareProfile.size.ToString() -like  'Basic*')
	            {
		            $cudisk|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 300
	            }ElseIf  ($IOtype -eq 'Standard' )
	            {
		            $cudisk|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 500
                }Elseif($IOtype -eq 'Premium')
                {
                   if ($cudisk.SizeinGB -le 128 )
                   {
                        $cudisk|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 500
                   }Elseif ($cudisk.SizeinGB -in  129..512 )
                   {
                        $cudisk|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 2300
                   }Elseif ($cudisk.SizeinGB -in  513..1024 )
                   {
                        $cudisk|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 5000
                   }
                }

			    $allvhds+=$cudisk    
		      }
		   }
	}
    }

	
}


#forarm
$vm=$cuvm=$cudisk=$osdisk=$nic=$nsg=$null
Foreach ($vm in $vmsarm)
{



 #vm inv
 
        
        $cuvm = New-Object PSObject -Property @{
                            Timestamp = $colltime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
                            MetricName = 'VMInventory';
                            ResourceGroup=$vm.id.split('/')[4]
                            HWProfile=$vm.properties.hardwareProfile.vmSize.ToString()
                            DeploymentType='ARM'
                            Location=$vm.location
                            VmName=$vm.Name
                            OperatingSystem=$vm.properties.storageProfile.osDisk.osType
                            ID=$vm.id
                            
                       
                           	SubscriptionId = $subscriptioninfo.subscriptionId
        AzureSubscription = $subscriptionInfo.displayName
      
                            }

              If([int]$remaining -gt [int]$apireadlimit -and $getarmvmstatus)
                {
        $uriinsview="https://management.azure.com"+$vm.id+"/InstanceView?api-version=2015-06-15"

        $resiview = Invoke-WebRequest -Method Get -Uri $uriinsview -Headers $headers -UseBasicParsing
      
        $ivcontent=$resiview.Content
        $ivcontent= ConvertFrom-Json -InputObject $resiview.Content

        $cuvm|Add-Member -MemberType NoteProperty -Name Status  -Value $VMstates.get_item(($ivcontent.statuses|select -Last 1).Code)
                }

                $allvms+=$cuVM

                If($getNICandNSG)
                {
#inventory network interfaces

Foreach ($nicobj in $vm.properties.networkProfile.networkInterfaces)
{
  $urinic="https://management.azure.com"+$nicobj.id+"?api-version=2015-06-15"

        $nicresult = Invoke-WebRequest -Method Get -Uri $urinic -Headers $headers -UseBasicParsing
      
        
        $Nic= ConvertFrom-Json -InputObject $nicresult.Content
        
        $cunic=$null
     
       $cuNic= New-Object PSObject -Property @{
                            Timestamp = $colltime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
                            MetricName = 'VMNIC';
                            VmName=$vm.Name
                            ID=$nic.id
                            NetworkInterface=$nic.name
                            VNetName=$nic.properties.ipConfigurations[0].properties.subnet.id.split('/')[8]
                            ResourceGroup=$nic.id.split('/')[4]
                            Location=$nic.location
                            Primary=$nic.properties.primary
                            enableIPForwarding=$nic.properties.enableIPForwarding
                            macAddress=$nic.properties.macAddress
                            privateIPAddress=$nic.properties.ipConfigurations[0].properties.privateIPAddress
                            privateIPAllocationMethod=$nic.properties.ipConfigurations[0].properties.privateIPAllocationMethod
                            subnet=$nic.properties.ipConfigurations[0].properties.subnet.id.split('/')[10]
                           	SubscriptionId = $subscriptioninfo.subscriptionId
                            AzureSubscription = $subscriptionInfo.displayName
      
                            } 

            IF (![string]::IsNullOrEmpty($cunic.publicIPAddress))
            {
                  $uripip="https://management.azure.com"+$cunic.publicIPAddress+"?api-version=2015-06-15"
                  $pipresult = Invoke-WebRequest -Method Get -Uri $uripip -Headers $headers -UseBasicParsing
                $pip= ConvertFrom-Json -InputObject $pipresult.Content
                If($pip)
                {
                $cuNic|Add-Member -MemberType NoteProperty -Name PublicIp -Value $pip.properties.ipAddress -Force
                $cuNic|Add-Member -MemberType NoteProperty -Name publicIPAllocationMethod -Value $pip.properties.publicIPAllocationMethod -Force
                $cuNic|Add-Member -MemberType NoteProperty -Name fqdn -Value $pip.properties.dnsSettings.fqdn -Force

                }


            }

            $invNic+=$cuNic

        #inventory NSG
        
        IF($nic.properties.networkSecurityGroup)
        {
            Foreach($nsgobj in $nic.properties.networkSecurityGroup)
            {
                 $urinsg="https://management.azure.com"+$nsgobj.id+"?api-version=2015-06-15"
                  $nsgresult = Invoke-WebRequest -Method Get -Uri $urinsg -Headers $headers -UseBasicParsing
                $nsg= ConvertFrom-Json -InputObject $nsgresult.Content
             

                 If($Nsg.properties.securityRules)
                 {
                    foreach($rule in $Nsg.properties.securityRules)
                    {

                      $invnsg+= New-Object PSObject -Property @{
                            Timestamp = $colltime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
                            MetricName = 'VMNSGrule';
                            VmName=$vm.Name
                            ID=$nsg.id
                            NSGName=$nsg.id
                            NetworkInterface=$nic.name
                            ResourceGroup=$nsg.id.split('/')[4]
                            Location=$nsg.location
                            RuleName=$rule.name
                            protocol=$rule.properties.protocol
                            sourcePortRange=$rule.properties.sourcePortRange
                            destinationPortRange=$rule.properties.destinationPortRange
                            sourceAddressPrefix=$rule.properties.sourceAddressPrefix
                            destinationAddressPrefix=$rule.properties.destinationAddressPrefix
                            access=$rule.properties.access
                            priority=$rule.properties.priority
                            direction=$rule.properties.direction
                             	SubscriptionId = $subscriptioninfo.subscriptionId
                             AzureSubscription = $subscriptionInfo.displayName
      
                            } 
                    }
                 }
             }
        }

}

                }
                
# inv  extensions

            IF(![string]::IsNullOrEmpty($vm.resources.id))
            {	
                  Foreach ($extobj in $vm.resources)
                    {
                        if($extobj.id.Split('/')[9] -eq 'extensions')
                        {
                            $invextensions+=New-Object PSObject -Property @{
                                        Timestamp = $colltime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
                                        MetricName = 'VMExtensions';
                           VmName=$vm.Name
                          Extension=$extobj.Extension
                         ID=$extobj.id
                                                     SubscriptionId = $subscriptioninfo.subscriptionId
                             AzureSubscription = $subscriptionInfo.displayName
                          
                                   }
                        }
        }

                

            }
        


        If($vm.tags)
         {

         $tags=$null
         $tags=$vm.tags

            foreach ($tag in $tags)
            {
                $tag.PSObject.Properties | foreach-object {
                
                    #exclude devteslabsUID 
                    $name = $_.Name 
                    $value = $_.value
                
                    IF ($name -match '-LabUId'){Continue}
                
                    Write-Verbose     "Adding tag $name : $value to $($VM.name)"
                    $cutag=$null
                    $cutag=New-Object PSObject
                    $cuVM.psobject.Properties|foreach-object  {
                      $cutag|Add-Member -MemberType NoteProperty -Name  $_.Name   -Value $_.value -Force
                }
                   $cutag|Add-Member -MemberType NoteProperty -Name Tag  -Value "$name : $value"

                }
                $vmtags+=$cutag
                        
                        #End tag processing 
           }

         }
      


      IF($getDiskInfo)
      {

    #INVENTORY DISKS
 
   
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

	     $cudisk = New-Object PSObject -Property @{
		        Timestamp = $colltime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
		        MetricName = 'VMDisk';
		        DiskType='Unmanaged'
		        Deploymentname=$vm.id.split('/')[4]   # !!! consider chnaging this to ResourceGroup here or in query
		        DeploymentType='ARM'
		        Location=$vm.location
		        VmName=$vm.Name
		        VHDUri=$vm.properties.storageProfile.osDisk.vhd.uri
		        #arm does not expose this need to queri it from $colParamsforChild
		        DiskIOType=$IOtype
		        StorageAccount=$saforVM.StorageAccount
		        	SubscriptionId = $subscriptioninfo.subscriptionId
        AzureSubscription = $subscriptionInfo.displayName
		        SizeinGB=$sizeingb
                } -ea 0

	    IF ($cudisk.DiskIOType -eq 'Standard' -and $vm.properties.hardwareProfile.vmSize.ToString() -like  'BAsic*')
	            {
		$cudisk|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 300
	}ElseIf  ($cudisk.DiskIOType -eq 'Standard' -and $vm.properties.hardwareProfile.vmSize.ToString() -like 'Standard*')
	            {
		$cudisk|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 500
	}Elseif($IOtype -eq 'Premium')
        {
            $cudisk|Add-Member -MemberType NoteProperty -Name MaxVMIO -Value $vmiolimits.Item($vm.properties.hardwareProfile.vmSize)
              
           if ($cudisk.SizeinGB -le 128 )
           {
                $cudisk|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 500
                 
           }Elseif ($cudisk.SizeinGB -in  129..512 )
           {
                $cudisk|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 2300
           }Elseif ($cudisk.SizeinGB -in  513..1024 )
           {
                $cudisk|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 5000
           }
        }
        $allvhds+=$cudisk    
    
    }
    Else
    {
    $cudisk=$null

        $cudisk = New-Object PSObject -Property @{
		    Timestamp = $colltime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
		    MetricName = 'VMDisk';
		    DiskType='Unmanaged'
		    Deploymentname=$vm.id.split('/')[4]   # !!! consider chnaging this to ResourceGroup here or in query
		    DeploymentType='ARM'
		    Location=$vm.location
		    VmName=$vm.Name
		    Uri="https://management.azure.com/{0}" -f $vm.properties.storageProfile.osDisk.managedDisk.id
		    StorageAccount=$vm.properties.storageProfile.osDisk.managedDisk.id
		    	SubscriptionId = $subscriptioninfo.subscriptionId
        AzureSubscription = $subscriptionInfo.displayName
		    SizeinGB=128
                } -ea 0

	    IF ($vm.properties.storageProfile.osDisk.managedDisk.storageAccountType -match 'Standard')
	    {
		    $cudisk|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 500
            $cudisk|Add-Member -MemberType NoteProperty -Name DiskIOType -Value 'Standard'

	    }Elseif($vm.properties.storageProfile.osDisk.managedDisk.storageAccountType -match  'Premium')
        {
            $cudisk|Add-Member -MemberType NoteProperty -Name MaxVMIO -Value $vmiolimits.Item($vm.properties.hardwareProfile.vmSize)
                 $cudisk|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 500
                  $cudisk|Add-Member -MemberType NoteProperty -Name DiskIOType -Value 'Premium'

           }
           $allvhds+=$cudisk
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
			        $cudisk = New-Object PSObject -Property @{
				        Timestamp = $colltime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
				        MetricName = 'VMDisk';
				        DiskType='Unmanaged'
				        Deploymentname=$vm.id.split('/')[4] 
				        DeploymentType='ARM'
				        Location=$vm.location
				        VmName=$vm.Name
				        VHDUri=$disk.vhd.uri
				        DiskIOType=$IOtype
				        StorageAccount=$safordisk.StorageAccount
				        	SubscriptionId = $subscriptioninfo.subscriptionId
        AzureSubscription = $subscriptionInfo.displayName
				        SizeinGB=$disk.diskSizeGB
				
			        } -ea 0 
			
			IF ($cudisk.DiskIOType -eq 'Standard' -and $vm.properties.hardwareProfile.vmSize.ToString() -like  'BAsic*')
			{
				$cudisk|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 300
			}ElseIf  ($cudisk.DiskIOType -eq 'Standard' -and $vm.properties.hardwareProfile.vmSize.ToString() -like 'Standard*')
			{
				$cudisk|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 500
			}Elseif($IOtype -eq 'Premium')
            {
                $cudisk|Add-Member -MemberType NoteProperty -Name MaxVMIO -Value $vmiolimits.Item($vm.properties.hardwareProfile.vmSize)
              
               if ($cudisk.SizeinGB -le 128 )
               {
                    $cudisk|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 500
               }Elseif ($cudisk.SizeinGB -in  129..512 )
               {
                    $cudisk|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 2300
               }Elseif ($cudisk.SizeinGB -in  513..1024 )
               {
                    $cudisk|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 5000
               }
           }
                       
			$allvhds+=$cudisk
    		}
            Else
            {
                 $cudisk = New-Object PSObject -Property @{
		            Timestamp = $timestamp
		            MetricName = 'Inventory';
		            DiskType='Managed'
		            Deploymentname=$vm.id.split('/')[4]   # !!! consider chnaging this to ResourceGroup here or in query
		            DeploymentType='ARM'
		            Location=$vm.location
		            VmName=$vm.Name
		            Uri="https://management.azure.com/{0}" -f $disk.manageddisk.id
		            StorageAccount=$disk.managedDisk.id
		            	SubscriptionId = $subscriptioninfo.subscriptionId
        AzureSubscription = $subscriptionInfo.displayNamee
		            SizeinGB=$disk.diskSizeGB
                        } -ea 0

               IF ($vm.properties.storageProfile.osDisk.managedDisk.storageAccountType -match 'Standard')
	            {
		            $cudisk|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 500
                    $cudisk|Add-Member -MemberType NoteProperty -Name DiskIOType -Value 'Standard'

	            }Elseif($vm.properties.storageProfile.osDisk.managedDisk.storageAccountType -match  'Premium')
                {
                    $cudisk|Add-Member -MemberType NoteProperty -Name MaxVMIO -Value $vmiolimits.Item($vm.properties.hardwareProfile.vmSize)
                    $cudisk|Add-Member -MemberType NoteProperty -Name DiskIOType -Value 'Premium'

                     if ($disk.diskSizeGB -le 128 )
               {
                    $cudisk|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 500
               }Elseif ($disk.diskSizeGB -in  129..512 )
               {
                    $cudisk|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 2300
               }Elseif ($disk.diskSizeGB -in  513..1024 )
               {
                    $cudisk|Add-Member -MemberType NoteProperty -Name MaxDiskIO -Value 5000
               }
           }
                $allvhds+=$cudisk
            }


        }
	}

    }


}

# Collect Subscription limits


Write-output "$(get-date) - Starting inventory of Usage data "

$locations=$loclistcontent=$cu=$null

$allvmusage=@()


$loclisturi="https://management.azure.com/"+$subscriptionInfo.id+"/locations?api-version=2016-09-01"


$loclist = Invoke-WebRequest -Uri $loclisturi -Method GET -Headers $Headers -UseBasicParsing

$loclistcontent= ConvertFrom-Json -InputObject $loclist.Content

$locations =$loclistcontent

Foreach($loc in $loclistcontent.value.name)
{

$usgdata=$cu=$usagecontent=$null
$usageuri="https://management.azure.com/"+$subscriptionInfo.id+"/providers/Microsoft.Compute/locations/"+$loc+"/usages?api-version=2015-06-15"

$usageapi = Invoke-WebRequest -Uri $usageuri -Method GET -Headers $Headers  -UseBasicParsing

$usagecontent= ConvertFrom-Json -InputObject $usageapi.Content



Foreach($usgdata in $usagecontent.value)
{


 $cu= New-Object PSObject -Property @{
                              Timestamp = $timestamp
                             MetricName = 'ARMVMUsageStats';
                            Location = $loc
                            currentValue=$usgdata.currentValue
                            limit=$usgdata.limit
                            Usagemetric = $usgdata.name[0].value.ToString()

                                                                              
                            SubscriptionID = $subscriptionInfo.id
                            AzureSubscription = $subscriptionInfo.displayName
      
                            }


$allvmusage+=$cu


}

}



### Send data to OMS


 $jsonvmpool = ConvertTo-Json -InputObject $allvms
 $jsonvmtags = ConvertTo-Json -InputObject $vmtags
  $jsonVHDData= ConvertTo-Json -InputObject $allvhds
  $jsonallvmusage = ConvertTo-Json -InputObject $allvmusage
  $jsoninvnic = ConvertTo-Json -InputObject $invnic
$jsoninvnsg = ConvertTo-Json -InputObject $invnsg
$jsoninvendpoint = ConvertTo-Json -InputObject $invendpoints
$jsoninveextensions = ConvertTo-Json -InputObject $invextensions



If($jsonvmpool){$postres1=Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($jsonvmpool)) -logType $logname}


	If ($postres1 -ge 200 -and $postres1 -lt 300)
	{
		Write-Output " Succesfully uploaded $($allvms.count) vm inventory   to OMS"
	}
	Else
	{
		Write-Warning " Failed to upload  $($allvms.count) vm inventory   to OMS"
	}

If($jsonvmtags){$postres2=Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($jsonvmtags)) -logType $logname}

	If ($postres2 -ge 200 -and $postres2 -lt 300)
	{
		Write-Output " Succesfully uploaded $($vmtags.count) vm tags  to OMS"
	}
	Else
	{
		Write-Warning " Failed to upload  $($vmtags.count) vm tags   to OMS"
	}

If($jsonallvmusage){$postres3=Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($jsonallvmusage)) -logType $logname}
	If ($postres3 -ge 200 -and $postres3 -lt 300)
	{
		Write-Output " Succesfully uploaded $($allvmusage.count) vm core usage  metrics to OMS"
	}
	Else
	{
		Write-Warning " Failed to upload  $($allvmusage.count) vm core usage  metrics to OMS"
	}

If($jsonVHDData){$postres4=Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($jsonVHDData)) -logType $logname}

	If ($postres4 -ge 200 -and $postres4 -lt 300)
	{
		Write-Output " Succesfully uploaded $($allvhds.count) disk usage metrics to OMS"
	}
	Else
	{
		Write-Warning " Failed to upload  $($allvhds.count) Disk metrics to OMS"
	}


If($jsoninvnic){$postres5=Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($jsoninvnic)) -logType $logname}

	If ($postres5 -ge 200 -and $postres5 -lt 300)
	{
		Write-Output " Succesfully uploaded $($invnic.count) NICs to OMS"
	}
	Else
	{
		Write-Warning " Failed to upload  $($invnic.count) NICs to OMS"
	}


If($jsoninvnsg){$postres6=Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($jsoninvnsg)) -logType $logname}

	If ($postres6 -ge 200 -and $postres6 -lt 300)
	{
		Write-Output " Succesfully uploaded $($invnsg.count) NSG metrics to OMS"
	}
	Else
	{
		Write-Warning " Failed to upload  $($invnsg.count) NSG metrics to OMS"
	}


If($jsoninvendpoint){$postres7=Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($jsoninvendpoint)) -logType $logname}

	If ($postres7 -ge 200 -and $postres7 -lt 300)
	{
		Write-Output " Succesfully uploaded $($invendpoints.count) input endpoint metrics to OMS"
	}
	Else
	{
		Write-Warning " Failed to upload  $($invendpoints.count) input endpoint metrics to OMS"
	}


If($jsoninveextensions){$postres8=Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($jsoninveextensions)) -logType $logname}

	If ($postres8 -ge 200 -and $postres8 -lt 300)
	{
		Write-Output " Succesfully uploaded $($invendpoints.count) extensionsto OMS"
	}
	Else
	{
		Write-Warning " Failed to upload  $($invendpoints.count) extensions  to OMS"
	}
#endregion




Write-output "$(get-date) - Uploading all data to OMS  "







