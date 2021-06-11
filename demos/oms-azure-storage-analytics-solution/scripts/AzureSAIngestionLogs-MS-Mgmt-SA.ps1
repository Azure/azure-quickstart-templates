param(
    [Parameter(Mandatory = $false)] [string]$SubscriptionidFilter,
    [Parameter(Mandatory = $false)] [bool] $collectionFromAllSubscriptions = $false,
    [Parameter(Mandatory = $false)] [bool] $getAsmHeader = $true)



$ErrorActionPreference = "Stop"

Write-Output "RB Initial Memory  : $([System.gc]::gettotalmemory('forcefullcollection') /1MB) MB" 

#region Variables definition
# Variables definition
# Common  variables  accross solution 

$StartTime = [dateTime]::Now
$Timestampfield = "Timestamp"

#will use exact time for all inventory 
$timestamp = $StartTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:45:00.000Z")


#Update customer Id to your Operational Insights workspace ID
$customerID = Get-AutomationVariable -Name 'AzureSAIngestion-OPSINSIGHTS_WS_ID-MS-Mgmt-SA'

#For shared key use either the primary or seconday Connected Sources client authentication key   
$sharedKey = Get-AutomationVariable -Name 'AzureSAIngestion-OPSINSIGHTS_WS_KEY-MS-Mgmt-SA'
#define API Versions for REST API  Calls


$ApiVerSaAsm = '2016-04-01'
$ApiVerSaArm = '2016-01-01'
$ApiStorage = '2016-05-31'


# Automation Account and Resource group for automation

$AAAccount = Get-AutomationVariable -Name 'AzureSAIngestion-AzureAutomationAccount-MS-Mgmt-SA'

$AAResourceGroup = Get-AutomationVariable -Name 'AzureSAIngestion-AzureAutomationResourceGroup-MS-Mgmt-SA'

# OMS log analytics custom log name

$logname = 'AzureStorage'

# Runbook specific variables 

$childrunbook = "AzureSAIngestionChild-MS-Mgmt-SA"
$schedulename = "AzureStorageIngestionChild-Schedule-MS-Mgmt-SA"


#Variable to sync between runspaces

$hash = [hashtable]::New(@{})

$Starttimer = get-date
#endregion



#region Define Required Functions

Function Build-tableSignature ($customerId, $sharedKey, $date, $method, $resource, $uri) {
    $stringToHash = $method + "`n" + "`n" + "`n" + $date + "`n" + "/" + $resource + $uri.AbsolutePath
    Add-Type -AssemblyName System.Web
    $query = [System.Web.HttpUtility]::ParseQueryString($uri.query)  
    $querystr = ''
    $bytesToHash = [Text.Encoding]::UTF8.GetBytes($stringToHash)
    $keyBytes = [Convert]::FromBase64String($sharedKey)
    $sha256 = New-Object System.Security.Cryptography.HMACSHA256
    $sha256.Key = $keyBytes
    $calculatedHash = $sha256.ComputeHash($bytesToHash)
    $encodedHash = [Convert]::ToBase64String($calculatedHash)
    $authorization = 'SharedKey {0}:{1}' -f $resource, $encodedHash
    return $authorization
	
}
# Create the function to create the authorization signature
Function Build-StorageSignature ($sharedKey, $date, $method, $bodylength, $resource, $uri , $service) {
    Add-Type -AssemblyName System.Web
    $str = New-Object -TypeName "System.Text.StringBuilder";
    $builder = [System.Text.StringBuilder]::new("/")
    $builder.Append($resource) |out-null
    $builder.Append($uri.AbsolutePath) | out-null
    $str.Append($builder.ToString()) | out-null
    $values2 = @{}
    IF ($service -eq 'Table') {
        $values = [System.Web.HttpUtility]::ParseQueryString($uri.query)  
        #    NameValueCollection values = HttpUtility.ParseQueryString(address.Query);
        foreach ($str2 in $values.Keys) {
            [System.Collections.ArrayList]$list = $values.GetValues($str2)
            $list.sort()
            $builder2 = [System.Text.StringBuilder]::new()
			
            foreach ($obj2 in $list) {
                if ($builder2.Length -gt 0) {
                    $builder2.Append(",");
                }
                $builder2.Append($obj2.ToString()) |Out-Null
            }
            IF ($str2 -ne $null) {
                $values2.add($str2.ToLowerInvariant(), $builder2.ToString())
            } 
        }
		
        $list2 = [System.Collections.ArrayList]::new($values2.Keys)
        $list2.sort()
        foreach ($str3 in $list2) {
            IF ($str3 -eq 'comp') {
                $builder3 = [System.Text.StringBuilder]::new()
                $builder3.Append($str3) |out-null
                $builder3.Append("=") |out-null
                $builder3.Append($values2[$str3]) |out-null
                $str.Append("?") |out-null
                $str.Append($builder3.ToString())|out-null
            }
        }
    }
    Else {
        $values = [System.Web.HttpUtility]::ParseQueryString($uri.query)  
        #    NameValueCollection values = HttpUtility.ParseQueryString(address.Query);
        foreach ($str2 in $values.Keys) {
            [System.Collections.ArrayList]$list = $values.GetValues($str2)
            $list.sort()
            $builder2 = [System.Text.StringBuilder]::new()
			
            foreach ($obj2 in $list) {
                if ($builder2.Length -gt 0) {
                    $builder2.Append(",");
                }
                $builder2.Append($obj2.ToString()) |Out-Null
            }
            IF ($str2 -ne $null) {
                $values2.add($str2.ToLowerInvariant(), $builder2.ToString())
            } 
        }
		
        $list2 = [System.Collections.ArrayList]::new($values2.Keys)
        $list2.sort()
        foreach ($str3 in $list2) {
			
            $builder3 = [System.Text.StringBuilder]::new()
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
    $xHeaders = "x-ms-date:" + $date + "`n" + "x-ms-version:$ApiStorage"
    if ($service -eq 'Table') {
        $stringToHash = $method + "`n" + "`n" + "`n" + $date + "`n" + $str.ToString()
    }
    Else {
        IF ($method -eq 'GET' -or $method -eq 'HEAD') {
            $stringToHash = $method + "`n" + "`n" + "`n" + "`n" + "`n" + "application/xml" + "`n" + "`n" + "`n" + "`n" + "`n" + "`n" + "`n" + $xHeaders + "`n" + $str.ToString()
        }
        Else {
            $stringToHash = $method + "`n" + "`n" + "`n" + $bodylength + "`n" + "`n" + "application/xml" + "`n" + "`n" + "`n" + "`n" + "`n" + "`n" + "`n" + $xHeaders + "`n" + $str.ToString()
        }     
    }
    ##############
	

    $bytesToHash = [Text.Encoding]::UTF8.GetBytes($stringToHash)
    $keyBytes = [Convert]::FromBase64String($sharedKey)
    $sha256 = New-Object System.Security.Cryptography.HMACSHA256
    $sha256.Key = $keyBytes
    $calculatedHash = $sha256.ComputeHash($bytesToHash)
    $encodedHash = [Convert]::ToBase64String($calculatedHash)
    $authorization = 'SharedKey {0}:{1}' -f $resource, $encodedHash
    return $authorization
	
}
# Create the function to create and post the request
Function invoke-StorageREST($sharedKey, $method, $msgbody, $resource, $uri, $svc, $download) {

    $rfc1123date = [DateTime]::UtcNow.ToString("r")

	
    If ($method -eq 'PUT') {
        $signature = Build-StorageSignature `
            -sharedKey $sharedKey `
            -date  $rfc1123date `
            -method $method -resource $resource -uri $uri -bodylength $msgbody.length -service $svc
    }
    Else {

        $signature = Build-StorageSignature `
            -sharedKey $sharedKey `
            -date  $rfc1123date `
            -method $method -resource $resource -uri $uri -body $body -service $svc
    } 

    If ($svc -eq 'Table') {
        $headersforsa = @{
            'Authorization'         = "$signature"
            'x-ms-version'          = "$apistorage"
            'x-ms-date'             = " $rfc1123date"
            'Accept-Charset'        = 'UTF-8'
            'MaxDataServiceVersion' = '3.0;NetFx'
            #      'Accept'='application/atom+xml,application/json;odata=nometadata'
            'Accept'                = 'application/json;odata=nometadata'
        }
    }
    Else { 
        $headersforSA = @{
            'x-ms-date'     = "$rfc1123date"
            'Content-Type'  = 'application\xml'
            'Authorization' = "$signature"
            'x-ms-version'  = "$ApiStorage"
        }
    }
	




    IF ($download) {
        $resp1 = Invoke-WebRequest -Uri $uri -Headers $headersforsa -Method $method -ContentType application/xml -UseBasicParsing -Body $msgbody  -OutFile "$($env:TEMP)\$resource.$($uri.LocalPath.Replace('/','.').Substring(7,$uri.LocalPath.Length-7))"

		
        #$xresp=Get-Content "$($env:TEMP)\$resource.$($uri.LocalPath.Replace('/','.').Substring(7,$uri.LocalPath.Length-7))"
        return "$($env:TEMP)\$resource.$($uri.LocalPath.Replace('/','.').Substring(7,$uri.LocalPath.Length-7))"


    }
    Else {
        If ($svc -eq 'Table') {
            IF ($method -eq 'PUT') {  
                $resp1 = Invoke-WebRequest -Uri $uri -Headers $headersforsa -Method $method  -UseBasicParsing -Body $msgbody  
                return $resp1
            }
            Else {
                $resp1 = Invoke-WebRequest -Uri $uri -Headers $headersforsa -Method $method   -UseBasicParsing -Body $msgbody 

                $xresp = $resp1.Content.Substring($resp1.Content.IndexOf("<")) 
            } 
            return $xresp

        }
        Else {
            IF ($method -eq 'PUT') {  
                $resp1 = Invoke-WebRequest -Uri $uri -Headers $headersforsa -Method $method -ContentType application/xml -UseBasicParsing -Body $msgbody 
                return $resp1
            }
            Elseif ($method -eq 'GET') {
                $resp1 = Invoke-WebRequest -Uri $uri -Headers $headersforsa -Method $method -ContentType application/xml -UseBasicParsing -Body $msgbody -ea 0

                $xresp = $resp1.Content.Substring($resp1.Content.IndexOf("<")) 
                return $xresp
            }
            Elseif ($method -eq 'HEAD') {
                $resp1 = Invoke-WebRequest -Uri $uri -Headers $headersforsa -Method $method -ContentType application/xml -UseBasicParsing -Body $msgbody 

				
                return $resp1
            }
        }
    }
}
#get blob file size in gb 

function Get-BlobSize ($bloburi, $storageaccount, $rg, $type) {

    If ($type -eq 'ARM') {
        $Uri = "https://management.azure.com/subscriptions/{3}/resourceGroups/{2}/providers/Microsoft.Storage/storageAccounts/{1}/listKeys?api-version={0}" -f $ApiVerSaArm, $storageaccount, $rg, $SubscriptionId 
        $keyresp = Invoke-WebRequest -Uri $uri -Method POST  -Headers $headers -UseBasicParsing
        $keys = ConvertFrom-Json -InputObject $keyresp.Content
        $prikey = $keys.keys[0].value
    }
    Elseif ($type -eq 'Classic') {
        $Uri = "https://management.azure.com/subscriptions/{3}/resourceGroups/{2}/providers/Microsoft.ClassicStorage/storageAccounts/{1}/listKeys?api-version={0}" -f $ApiVerSaAsm, $storageaccount, $rg, $SubscriptionId 
        $keyresp = Invoke-WebRequest -Uri $uri -Method POST  -Headers $headers -UseBasicParsing
        $keys = ConvertFrom-Json -InputObject $keyresp.Content
        $prikey = $keys.primaryKey
    }
    Else {
        "Could not detect storage account type, $storageaccount will not be processed"
        Continue
    }





    $vhdblob = invoke-StorageREST -sharedKey $prikey -method HEAD -resource $storageaccount -uri $bloburi
	
    Return [math]::round($vhdblob.Headers.'Content-Length' / 1024 / 1024 / 1024, 0)



}		
# Create the function to create the authorization signature
Function Build-OMSSignature ($customerId, $sharedKey, $date, $contentLength, $method, $contentType, $resource) {
    $xHeaders = "x-ms-date:" + $date
    $stringToHash = $method + "`n" + $contentLength + "`n" + $contentType + "`n" + $xHeaders + "`n" + $resource
    $bytesToHash = [Text.Encoding]::UTF8.GetBytes($stringToHash)
    $keyBytes = [Convert]::FromBase64String($sharedKey)
    $sha256 = New-Object System.Security.Cryptography.HMACSHA256
    $sha256.Key = $keyBytes
    $calculatedHash = $sha256.ComputeHash($bytesToHash)
    $encodedHash = [Convert]::ToBase64String($calculatedHash)
    $authorization = 'SharedKey {0}:{1}' -f $customerId, $encodedHash
    return $authorization
}
# Create the function to create and post the request
Function Post-OMSData($customerId, $sharedKey, $body, $logType) {


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
        "Authorization"        = $signature;
        "Log-Type"             = $logType;
        "x-ms-date"            = $rfc1123date;
        "time-generated-field" = $TimeStampField;
    }

    Try {
        $response = Invoke-WebRequest -Uri $uri -Method POST  -ContentType $contentType -Headers $OMSheaders -Body $body -UseBasicParsing
    }catch [Net.WebException] {
        $ex = $_.Exception
        If ($_.Exception.Response.StatusCode.value__) {
            $exrespcode = ($_.Exception.Response.StatusCode.value__ ).ToString().Trim();
            #Write-Output $crap;
        }
        If ($_.Exception.Message) {
            $exMessage = ($_.Exception.Message).ToString().Trim();
            #Write-Output $crapMessage;
        }
        $errmsg = "$exrespcode : $exMessage"
    }

    if ($errmsg) {return $errmsg }
    Else {	return $response.StatusCode }
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

# try to authenticate woth ASM 

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

$SubscriptionsURI = "https://management.azure.com/subscriptions?api-version=2016-06-01" 
$Subscriptions = Invoke-RestMethod -Uri  $SubscriptionsURI -Method GET  -Headers $headers -UseBasicParsing 
$Subscriptions = @($Subscriptions.value)


IF ($collectionFromAllSubscriptions -and $Subscriptions.count -gt 1 ) {
    Write-Output "$($Subscriptions.count) Subscription found , additonal runbook jobs will be created to collect data "
    $AAResourceGroup = Get-AutomationVariable -Name 'AzureSAIngestion-AzureAutomationResourceGroup-MS-Mgmt-SA'
    $AAAccount = Get-AutomationVariable -Name 'AzureSAIngestion-AzureAutomationAccount-MS-Mgmt-SA'
    $LogsRunbookName = "AzureSAIngestionLogs-MS-Mgmt-SA"

    #we will process first subscription with this runbook and  pass the rest to additional jobs

    #$n=$Subscriptions.count-1
    #$subslist=$Subscriptions[-$n..-1]
	
    $subslist = $subscriptions|where {$_.subscriptionId -ne $subscriptionId}
    Foreach ($item in $subslist) {

        $params1 = @{"SubscriptionidFilter" = $item.subscriptionId; "collectionFromAllSubscriptions" = $false; "getAsmHeader" = $false}
        Start-AzureRmAutomationRunbook -AutomationAccountName $AAAccount -Name $LogsRunbookName -ResourceGroupName $AAResourceGroup -Parameters $params1 | out-null
    }
}



#endregion



#region Get Storage account list

"$(GEt-date) - Get ARM storage Accounts "

$Uri = "https://management.azure.com/subscriptions/{1}/providers/Microsoft.Storage/storageAccounts?api-version={0}" -f $ApiVerSaArm, $SubscriptionId 
$armresp = Invoke-RestMethod -Uri $uri -Method GET  -Headers $headers -UseBasicParsing
$saArmList = $armresp.Value
"$(GEt-date)  $($saArmList.count) classic storage accounts found"

#get Classic SA
"$(GEt-date)  Get Classic storage Accounts "

$Uri = "https://management.azure.com/subscriptions/{1}/providers/Microsoft.ClassicStorage/storageAccounts?api-version={0}" -f $ApiVerSaAsm, $SubscriptionId 

$asmresp = Invoke-RestMethod -Uri $uri -Method GET  -Headers $headers -UseBasicParsing
$saAsmList = $asmresp.value

"$(GEt-date)  $($saAsmList.count) storage accounts found"
#endregion

#region Cache Storage Account Name , RG name and Build paramter array

$colParamsforChild = @()

foreach ($sa in $saArmList|where {$_.Sku.tier -ne 'Premium'}) {

    $rg = $sku = $null

    $rg = $sa.id.Split('/')[4]

    $colParamsforChild += "$($sa.name);$($sa.id.Split('/')[4]);ARM;$($sa.sku.tier);$($sa.Kind)"
	
}

#Add Classic SA
$sa = $rg = $null

foreach ($sa in $saAsmList|where {$_.properties.accounttype -notmatch 'Premium'}) {

    $rg = $sa.id.Split('/')[4]
    $tier = $null

    # array  wth SAName,ReouceGroup,Prikey,Tier 

    If ( $sa.properties.accountType -notmatch 'premium') {
        $tier = 'Standard'
        $colParamsforChild += "$($sa.name);$($sa.id.Split('/')[4]);Classic;$tier;$($sa.Kind)"
    }

	

}

#clean up variables which is not needed 
Write-Output "Core Count  $([System.Environment]::ProcessorCount)"
#endregion

#check if there are Storage accounts to process if not  then exit
if ($colParamsforChild.count -eq 0) {
    Write-Output " No Storage account found under subscription $subscriptionid , please note that Premium storage does not support metrics and excluded from the collection!"
    exit
}


$sa = $null
$logTracker = @()
$blobdate = (Get-date).AddHours(-1).ToUniversalTime().ToString("yyyy/MM/dd/HH00")

#region parallel with RS 


$hash['Host'] = $host
$hash['subscriptionInfo'] = $subscriptionInfo
$hash['ArmConn'] = $ArmConn
$hash['AsmConn'] = $AsmConn
$hash['headers'] = $headers
$hash['headerasm'] = $headers
$hash['AzureCert'] = $AzureCert
$hash['Timestampfield'] = $Timestampfield

$hash['customerID'] = $customerID
$hash['syncInterval'] = $syncInterval
$hash['sharedKey'] = $sharedKey 
$hash['Logname'] = $logname

$hash['ApiVerSaAsm'] = $ApiVerSaAsm
$hash['ApiVerSaArm'] = $ApiVerSaArm
$hash['ApiStorage'] = $ApiStorage
$hash['AAAccount'] = $AAAccount
$hash['AAResourceGroup'] = $AAResourceGroup

$hash['debuglog'] = $true

$hash['logTracker'] = @()



$SAInfo = @()
$hash.'SAInfo' = $sainfo



$Throttle = [int][System.Environment]::ProcessorCount + 1  #threads

$sessionstate = [system.management.automation.runspaces.initialsessionstate]::CreateDefault()
$runspacepool = [runspacefactory]::CreateRunspacePool(1, $Throttle, $sessionstate, $Host)
$runspacepool.Open() 
[System.Collections.ArrayList]$Jobs = @()

#script to cache storage account keys 
$scriptBlock = {

    Param ($hash, [array]$Sa, $rsid)

    $subscriptionInfo = $hash.subscriptionInfo
    $ArmConn = $hash.ArmConn
    $headers = $hash.headers
    $AsmConn = $hash.AsmConn
    $headerasm = $hash.headerasm
    $AzureCert = $hash.AzureCert

    $Timestampfield = $hash.Timestampfield

    $Currency = $hash.Currency
    $Locale = $hash.Locale
    $RegionInfo = $hash.RegionInfo
    $OfferDurableId = $hash.OfferDurableId
    $syncInterval = $Hash.syncInterval
    $customerID = $hash.customerID 
    $sharedKey = $hash.sharedKey
    $logname = $hash.Logname
    $StartTime = [dateTime]::Now
    $ApiVerSaAsm = $hash.ApiVerSaAsm
    $ApiVerSaArm = $hash.ApiVerSaArm
    $ApiStorage = $hash.ApiStorage
    $AAAccount = $hash.AAAccount
    $AAResourceGroup = $hash.AAResourceGroup
    $debuglog = $hash.deguglog



    #Inventory variables
    $varQueueList = "AzureSAIngestion-List-Queues"
    $varFilesList = "AzureSAIngestion-List-Files"

    $subscriptionId = $subscriptionInfo.subscriptionId


    #region Define Required Functions

    Function Build-tableSignature ($customerId, $sharedKey, $date, $method, $resource, $uri) {
        $stringToHash = $method + "`n" + "`n" + "`n" + $date + "`n" + "/" + $resource + $uri.AbsolutePath
        Add-Type -AssemblyName System.Web
        $query = [System.Web.HttpUtility]::ParseQueryString($uri.query)  
        $querystr = ''
        $bytesToHash = [Text.Encoding]::UTF8.GetBytes($stringToHash)
        $keyBytes = [Convert]::FromBase64String($sharedKey)
        $sha256 = New-Object System.Security.Cryptography.HMACSHA256
        $sha256.Key = $keyBytes
        $calculatedHash = $sha256.ComputeHash($bytesToHash)
        $encodedHash = [Convert]::ToBase64String($calculatedHash)
        $authorization = 'SharedKey {0}:{1}' -f $resource, $encodedHash
        return $authorization
		
    }
    # Create the function to create the authorization signature
    Function Build-StorageSignature ($sharedKey, $date, $method, $bodylength, $resource, $uri , $service) {
        Add-Type -AssemblyName System.Web
        $str = New-Object -TypeName "System.Text.StringBuilder";
        $builder = [System.Text.StringBuilder]::new("/")
        $builder.Append($resource) |out-null
        $builder.Append($uri.AbsolutePath) | out-null
        $str.Append($builder.ToString()) | out-null
        $values2 = @{}
        IF ($service -eq 'Table') {
            $values = [System.Web.HttpUtility]::ParseQueryString($uri.query)  
            #    NameValueCollection values = HttpUtility.ParseQueryString(address.Query);
            foreach ($str2 in $values.Keys) {
                [System.Collections.ArrayList]$list = $values.GetValues($str2)
                $list.sort()
                $builder2 = [System.Text.StringBuilder]::new()
				
                foreach ($obj2 in $list) {
                    if ($builder2.Length -gt 0) {
                        $builder2.Append(",");
                    }
                    $builder2.Append($obj2.ToString()) |Out-Null
                }
                IF ($str2 -ne $null) {
                    $values2.add($str2.ToLowerInvariant(), $builder2.ToString())
                } 
            }
			
            $list2 = [System.Collections.ArrayList]::new($values2.Keys)
            $list2.sort()
            foreach ($str3 in $list2) {
                IF ($str3 -eq 'comp') {
                    $builder3 = [System.Text.StringBuilder]::new()
                    $builder3.Append($str3) |out-null
                    $builder3.Append("=") |out-null
                    $builder3.Append($values2[$str3]) |out-null
                    $str.Append("?") |out-null
                    $str.Append($builder3.ToString())|out-null
                }
            }
        }
        Else {
            $values = [System.Web.HttpUtility]::ParseQueryString($uri.query)  
            #    NameValueCollection values = HttpUtility.ParseQueryString(address.Query);
            foreach ($str2 in $values.Keys) {
                [System.Collections.ArrayList]$list = $values.GetValues($str2)
                $list.sort()
                $builder2 = [System.Text.StringBuilder]::new()
				
                foreach ($obj2 in $list) {
                    if ($builder2.Length -gt 0) {
                        $builder2.Append(",");
                    }
                    $builder2.Append($obj2.ToString()) |Out-Null
                }
                IF ($str2 -ne $null) {
                    $values2.add($str2.ToLowerInvariant(), $builder2.ToString())
                } 
            }
			
            $list2 = [System.Collections.ArrayList]::new($values2.Keys)
            $list2.sort()
            foreach ($str3 in $list2) {
				
                $builder3 = [System.Text.StringBuilder]::new()
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
        $xHeaders = "x-ms-date:" + $date + "`n" + "x-ms-version:$ApiStorage"
        if ($service -eq 'Table') {
            $stringToHash = $method + "`n" + "`n" + "`n" + $date + "`n" + $str.ToString()
        }
        Else {
            IF ($method -eq 'GET' -or $method -eq 'HEAD') {
                $stringToHash = $method + "`n" + "`n" + "`n" + "`n" + "`n" + "application/xml" + "`n" + "`n" + "`n" + "`n" + "`n" + "`n" + "`n" + $xHeaders + "`n" + $str.ToString()
            }
            Else {
                $stringToHash = $method + "`n" + "`n" + "`n" + $bodylength + "`n" + "`n" + "application/xml" + "`n" + "`n" + "`n" + "`n" + "`n" + "`n" + "`n" + $xHeaders + "`n" + $str.ToString()
            }     
        }
        ##############
		

        $bytesToHash = [Text.Encoding]::UTF8.GetBytes($stringToHash)
        $keyBytes = [Convert]::FromBase64String($sharedKey)
        $sha256 = New-Object System.Security.Cryptography.HMACSHA256
        $sha256.Key = $keyBytes
        $calculatedHash = $sha256.ComputeHash($bytesToHash)
        $encodedHash = [Convert]::ToBase64String($calculatedHash)
        $authorization = 'SharedKey {0}:{1}' -f $resource, $encodedHash
        return $authorization
		
    }
    # Create the function to create and post the request
    Function invoke-StorageREST($sharedKey, $method, $msgbody, $resource, $uri, $svc, $download) {

        $rfc1123date = [DateTime]::UtcNow.ToString("r")

		
        If ($method -eq 'PUT') {
            $signature = Build-StorageSignature `
                -sharedKey $sharedKey `
                -date  $rfc1123date `
                -method $method -resource $resource -uri $uri -bodylength $msgbody.length -service $svc
        }
        Else {

            $signature = Build-StorageSignature `
                -sharedKey $sharedKey `
                -date  $rfc1123date `
                -method $method -resource $resource -uri $uri -body $body -service $svc
        } 

        If ($svc -eq 'Table') {
            $headersforsa = @{
                'Authorization'         = "$signature"
                'x-ms-version'          = "$apistorage"
                'x-ms-date'             = " $rfc1123date"
                'Accept-Charset'        = 'UTF-8'
                'MaxDataServiceVersion' = '3.0;NetFx'
                #      'Accept'='application/atom+xml,application/json;odata=nometadata'
                'Accept'                = 'application/json;odata=nometadata'
            }
        }
        Else { 
            $headersforSA = @{
                'x-ms-date'     = "$rfc1123date"
                'Content-Type'  = 'application\xml'
                'Authorization' = "$signature"
                'x-ms-version'  = "$ApiStorage"
            }
        }
		




        IF ($download) {
            $resp1 = Invoke-WebRequest -Uri $uri -Headers $headersforsa -Method $method -ContentType application/xml -UseBasicParsing -Body $msgbody  -OutFile "$($env:TEMP)\$resource.$($uri.LocalPath.Replace('/','.').Substring(7,$uri.LocalPath.Length-7))"

			
            #$xresp=Get-Content "$($env:TEMP)\$resource.$($uri.LocalPath.Replace('/','.').Substring(7,$uri.LocalPath.Length-7))"
            return "$($env:TEMP)\$resource.$($uri.LocalPath.Replace('/','.').Substring(7,$uri.LocalPath.Length-7))"


        }
        Else {
            If ($svc -eq 'Table') {
                IF ($method -eq 'PUT') {  
                    $resp1 = Invoke-WebRequest -Uri $uri -Headers $headersforsa -Method $method  -UseBasicParsing -Body $msgbody  
                    return $resp1
                }
                Else {
                    $resp1 = Invoke-WebRequest -Uri $uri -Headers $headersforsa -Method $method   -UseBasicParsing -Body $msgbody 

                    $xresp = $resp1.Content.Substring($resp1.Content.IndexOf("<")) 
                } 
                return $xresp

            }
            Else {
                IF ($method -eq 'PUT') {  
                    $resp1 = Invoke-WebRequest -Uri $uri -Headers $headersforsa -Method $method -ContentType application/xml -UseBasicParsing -Body $msgbody 
                    return $resp1
                }
                Elseif ($method -eq 'GET') {
                    $resp1 = Invoke-WebRequest -Uri $uri -Headers $headersforsa -Method $method -ContentType application/xml -UseBasicParsing -Body $msgbody -ea 0

                    $xresp = $resp1.Content.Substring($resp1.Content.IndexOf("<")) 
                    return $xresp
                }
                Elseif ($method -eq 'HEAD') {
                    $resp1 = Invoke-WebRequest -Uri $uri -Headers $headersforsa -Method $method -ContentType application/xml -UseBasicParsing -Body $msgbody 

					
                    return $resp1
                }
            }
        }
    }
    #get blob file size in gb 

    function Get-BlobSize ($bloburi, $storageaccount, $rg, $type) {

        If ($type -eq 'ARM') {
            $Uri = "https://management.azure.com/subscriptions/{3}/resourceGroups/{2}/providers/Microsoft.Storage/storageAccounts/{1}/listKeys?api-version={0}" -f $ApiVerSaArm, $storageaccount, $rg, $SubscriptionId 
            $keyresp = Invoke-WebRequest -Uri $uri -Method POST  -Headers $headers -UseBasicParsing
            $keys = ConvertFrom-Json -InputObject $keyresp.Content
            $prikey = $keys.keys[0].value
        }
        Elseif ($type -eq 'Classic') {
            $Uri = "https://management.azure.com/subscriptions/{3}/resourceGroups/{2}/providers/Microsoft.ClassicStorage/storageAccounts/{1}/listKeys?api-version={0}" -f $ApiVerSaAsm, $storageaccount, $rg, $SubscriptionId 
            $keyresp = Invoke-WebRequest -Uri $uri -Method POST  -Headers $headers -UseBasicParsing
            $keys = ConvertFrom-Json -InputObject $keyresp.Content
            $prikey = $keys.primaryKey
        }
        Else {
            "Could not detect storage account type, $storageaccount will not be processed"
            Continue
        }





        $vhdblob = invoke-StorageREST -sharedKey $prikey -method HEAD -resource $storageaccount -uri $bloburi
		
        Return [math]::round($vhdblob.Headers.'Content-Length' / 1024 / 1024 / 1024, 0)



    }		
    # Create the function to create the authorization signature
    Function Build-OMSSignature ($customerId, $sharedKey, $date, $contentLength, $method, $contentType, $resource) {
        $xHeaders = "x-ms-date:" + $date
        $stringToHash = $method + "`n" + $contentLength + "`n" + $contentType + "`n" + $xHeaders + "`n" + $resource
        $bytesToHash = [Text.Encoding]::UTF8.GetBytes($stringToHash)
        $keyBytes = [Convert]::FromBase64String($sharedKey)
        $sha256 = New-Object System.Security.Cryptography.HMACSHA256
        $sha256.Key = $keyBytes
        $calculatedHash = $sha256.ComputeHash($bytesToHash)
        $encodedHash = [Convert]::ToBase64String($calculatedHash)
        $authorization = 'SharedKey {0}:{1}' -f $customerId, $encodedHash
        return $authorization
    }
    # Create the function to create and post the request
    Function Post-OMSData($customerId, $sharedKey, $body, $logType) {


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
            "Authorization"        = $signature;
            "Log-Type"             = $logType;
            "x-ms-date"            = $rfc1123date;
            "time-generated-field" = $TimeStampField;
        }

        Try {
            $response = Invoke-WebRequest -Uri $uri -Method POST  -ContentType $contentType -Headers $OMSheaders -Body $body -UseBasicParsing
        }catch [Net.WebException] {
            $ex = $_.Exception
            If ($_.Exception.Response.StatusCode.value__) {
                $exrespcode = ($_.Exception.Response.StatusCode.value__ ).ToString().Trim();
                #Write-Output $crap;
            }
            If ($_.Exception.Message) {
                $exMessage = ($_.Exception.Message).ToString().Trim();
                #Write-Output $crapMessage;
            }
            $errmsg = "$exrespcode : $exMessage"
        }

        if ($errmsg) {return $errmsg }
        Else {	return $response.StatusCode }
        #write-output $response.StatusCode
        Write-error $error[0]
    }



    #endregion



    $prikey = $storageaccount = $rg = $type = $null
    $storageaccount = $sa.Split(';')[0]
    $rg = $sa.Split(';')[1]
    $type = $sa.Split(';')[2]
    $tier = $sa.Split(';')[3]
    $kind = $sa.Split(';')[4]


    If ($type -eq 'ARM') {
        $Uri = "https://management.azure.com/subscriptions/{3}/resourceGroups/{2}/providers/Microsoft.Storage/storageAccounts/{1}/listKeys?api-version={0}" -f $ApiVerSaArm, $storageaccount, $rg, $SubscriptionId 
        $keyresp = Invoke-WebRequest -Uri $uri -Method POST  -Headers $headers -UseBasicParsing
        $keys = ConvertFrom-Json -InputObject $keyresp.Content
        $prikey = $keys.keys[0].value


    }
    Elseif ($type -eq 'Classic') {
        $Uri = "https://management.azure.com/subscriptions/{3}/resourceGroups/{2}/providers/Microsoft.ClassicStorage/storageAccounts/{1}/listKeys?api-version={0}" -f $ApiVerSaAsm, $storageaccount, $rg, $SubscriptionId 
        $keyresp = Invoke-WebRequest -Uri $uri -Method POST  -Headers $headers -UseBasicParsing
        $keys = ConvertFrom-Json -InputObject $keyresp.Content
        $prikey = $keys.primaryKey


    }
    Else {
		
        "Could not detect storage account type, $storageaccount will not be processed"
        Continue
		

    }

    #check if metrics are enabled
    IF ($kind -eq 'BlobStorage') {
        $svclist = @('blob', 'table')
    }
    Else {
        $svclist = @('blob', 'table', 'queue')
    }


    $logging = $false

    Foreach ($svc in $svclist) {


		
        [uri]$uriSvcProp = "https://{0}.{1}.core.windows.net/?restype=service&comp=properties	" -f $storageaccount, $svc

        IF ($svc -eq 'table') {
            [xml]$SvcPropResp = invoke-StorageREST -sharedKey $prikey -method GET -resource $storageaccount -uri $uriSvcProp -svc Table
			
        }
        else {
            [xml]$SvcPropResp = invoke-StorageREST -sharedKey $prikey -method GET -resource $storageaccount -uri $uriSvcProp 
			
        }

        IF ($SvcPropResp.StorageServiceProperties.Logging.Read -eq 'true' -or $SvcPropResp.StorageServiceProperties.Logging.Write -eq 'true' -or $SvcPropResp.StorageServiceProperties.Logging.Delete -eq 'true') {
            $msg = "Logging is enabled for {0} in {1}" -f $svc, $storageaccount
            #Write-output $msg

            $logging = $true

			

			
        }
        Else {
            $msg = "Logging is not  enabled for {0} in {1}" -f $svc, $storageaccount

        }


    }


    $hash.SAInfo += New-Object PSObject -Property @{
        StorageAccount = $storageaccount
        Key            = $prikey
        Logging        = $logging
        Rg             = $rg
        Type           = $type
        Tier           = $tier
        Kind           = $kind

    }


}


write-output "$($colParamsforChild.count) objects will be processed "

$i = 1 

$Starttimer = get-date



$colParamsforChild|foreach {

    $splitmetrics = $null
    $splitmetrics = $_
    $Job = [powershell]::Create().AddScript($ScriptBlock).AddArgument($hash).AddArgument($splitmetrics).Addargument($i)
    $Job.RunspacePool = $RunspacePool
    $Jobs += New-Object PSObject -Property @{
        RunNum = $i
        Pipe   = $Job
        Result = $Job.BeginInvoke()

    }
	
    $i++
}

write-output  "$(get-date)  , started $i Runspaces "
Write-Output "After dispatching runspaces $([System.gc]::gettotalmemory('forcefullcollection') /1MB) MB"
$jobsClone = $jobs.clone()
Write-Output "Waiting.."



$s = 1
Do {

    Write-Output "  $(@($jobs.result.iscompleted|where{$_  -match 'False'}).count)  jobs remaining"

    foreach ($jobobj in $JobsClone) {

        if ($Jobobj.result.IsCompleted -eq $true) {
            $jobobj.Pipe.Endinvoke($jobobj.Result)
            $jobobj.pipe.dispose()
            $jobs.Remove($jobobj)
        }
    }


    IF ($([System.gc]::gettotalmemory('forcefullcollection') / 1MB) -gt 200) {
        [gc]::Collect()
    }


    IF ($s % 10 -eq 0) {
        Write-Output "Job $s - Mem: $([System.gc]::gettotalmemory('forcefullcollection') /1MB) MB"
    }  
    $s++
	
    Start-Sleep -Seconds 15


} While ( @($jobs.result.iscompleted|where {$_ -match 'False'}).count -gt 0)
Write-output "All jobs completed!"



$jobs|foreach {$_.Pipe.Dispose()}
Remove-Variable Jobs -Force -Scope Global
Remove-Variable Job -Force -Scope Global
Remove-Variable Jobobj -Force -Scope Global
Remove-Variable Jobsclone -Force -Scope Global

$runspacepool.Close()

[gc]::Collect()

#save Script Variables

$startupVariables = ””

new-variable -force -name startupVariables -value ( Get-Variable |

    % { $_.Name } )

Write-Output "Memory After Initial pool for keys : $([System.gc]::gettotalmemory('forcefullcollection') /1MB) MB" 




$sa = $null
$logTracker = @()
$blobdate = (Get-date).AddHours(-1).ToUniversalTime().ToString("yyyy/MM/dd/HH00")

$s = 1

#testing
write-output $hash.SAInfo|select Logging , storageaccount


foreach ($sa in @($hash.SAInfo|Where {$_.Logging -eq 'True' -and $_.key -ne $null})) {

    $prikey = $sa.key
    $storageaccount = $sa.StorageAccount
    $rg = $sa.rg
    $type = $sa.Type
    $tier = $sa.Tier
    $kind = $sa.Kind





    $logArray = @()
    $Logcount = 0
    $LogSize = 0

    Foreach ($svc in @('blob', 'table', 'queue')) {

        $blobs = @()
        $prefix = $svc + "/" + $blobdate
		
        [uri]$uriLBlobs = "https://{0}.blob.core.windows.net/`$logs`?restype=container&comp=list&prefix={1}&maxresults=1000" -f $storageaccount, $prefix
        [xml]$fresponse = invoke-StorageREST -sharedKey $prikey -method GET -resource $storageaccount -uri $uriLBlobs
		
        $content = $null
        $content = $fresponse.EnumerationResults
        $blobs += $content.Blobs.blob

        REmove-Variable -Name fresponse
		
        IF (![string]::IsNullOrEmpty($content.NextMarker)) {
            do {
                [uri]$uriLogs2 = "https://{0}.blob.core.windows.net/`$logs`?restype=container&comp=list&maxresults=1000&marker={1}" -f $storageaccount, $content.NextMarker

                $content = $null
                [xml]$Logresp2 = invoke-StorageREST -sharedKey $prikey -method GET -resource $storageaccount -uri $uriLogs2 

                $content = $Logresp2.EnumerationResults

                $blobs += $content.Blobs.Blob
                # $blobsall+=$blobs

                $uriLogs2 = $null

            }While (![string]::IsNullOrEmpty($content.NextMarker))
        }

		
        $fresponse = $logresp2 = $null


        IF ($blobs) {
            Foreach ($blob in $blobs) {

                [uri]$uriLogs3 = "https://{0}.blob.core.windows.net/`$logs/{1}" -f $storageaccount, $blob.Name

                $content = $null
                $auditlog = invoke-StorageREST -sharedKey $prikey -method GET -resource $storageaccount -uri $uriLogs3 -download $true 

                if (Test-Path $auditlog) {
                    $file = New-Object System.IO.StreamReader -Arg $auditlog
					
                    while ($line = $file.ReadLine()) {
						

                        $splitline = [regex]::Split( $line , ';(?=(?:[^"]|"[^"]*")*$)' )

                        $logArray += New-Object PSObject -Property @{
                            Timestamp          = $splitline[1]
                            MetricName         = 'AuditLogs'
                            StorageAccount     = $storageaccount
                            StorageService     = $splitline[10]
                            Operation          = $splitline[2]
                            Status             = $splitline[3]
                            StatusCode         = $splitline[4]
                            E2ELatency         = [int]$splitline[5]
                            ServerLatency      = [int]$splitline[6]
                            AuthenticationType = $splitline[7]	 
                            Requesteraccount   = $splitline[8]
                            Resource           = $splitline[12].Replace('"', '')
                            RequesterIP        = $splitline[15].Split(':')[0]
                            UserAgent          = $splitline[27].Replace('"', '')
                            SubscriptionId     = $ArmConn.SubscriptionId;
                            AzureSubscription  = $subscriptionInfo.displayName;
                        }
						
                    }
                    $file.close()

                    $file = get-item $auditlog 
                    $Logcount++
                    $LogSize += [Math]::Round($file.Length / 1024, 0)
                    Remove-Item  $auditlog -Force


                    #push data into oms if specific thresholds are reached 
                    IF ($logArray.count -gt 5000 -or $([System.gc]::gettotalmemory('forcefullcollection') / 1MB) -gt 150) {
                        write-output "$($logArray.count)  logs consumed $([System.gc]::gettotalmemory('forcefullcollection') /1MB) , uploading data  to OMS"

                        $jsonlogs = ConvertTo-Json -InputObject $logArray
                        $logarray = @()

                        Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($jsonlogs)) -logType $logname

                        remove-variable jsonlogs -force 
                        [gc]::Collect()
						
                    }



                }
				
            }
            $auditlog = $file = $null
        }
        write-output "$($blobs.count)  log file processed for $storageaccount. $($logarray.count) records wil be uploaded"
    }
    Remove-Variable -Name Blobs
    $logTracker += New-Object PSObject -Property @{
        StorageAccount = $storageaccount
        Logcount       = $Logcount
        LogSizeinKB    = $LogSize            
    }
	
}




If ($logArray) {
    $splitSize = 5000
    If ($logArray.count -gt $splitSize) {
        $spltlist = @()
        $spltlist += for ($Index = 0; $Index -lt $logArray.count; $Index += $splitSize) {
            , ($logArray[$index..($index + $splitSize - 1)])
        }
		
		
        $spltlist|foreach {
            $splitLogs = $null
            $splitLogs = $_
            $jsonlogs = ConvertTo-Json -InputObject $splitLogs
            Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($jsonlogs)) -logType $logname

        }



    }
    Else {

        $jsonlogs = ConvertTo-Json -InputObject $logArray

        Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($jsonlogs)) -logType $logname

    }
}


IF ($s % 10 -eq 0) {
    Write-Output "Job $s - SA $storageaccount -Logsize : $logsize - Mem: $([System.gc]::gettotalmemory('forcefullcollection') /1MB) MB"
}  
$s++


Remove-Variable -Name  logArray -ea 0
Remove-Variable -Name  fresponse -ea 0
Remove-Variable -Name  auditlog -ea 0
Remove-Variable -Name  jsonlogs  -ea 0
[gc]::Collect()

# Write-Output "After $storageaccount OMS upload : $([System.gc]::gettotalmemory('forcefullcollection') /1MB) MB"



