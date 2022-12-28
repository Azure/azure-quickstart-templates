param (
[Parameter(Mandatory=$false)][string]$Currency   ,
[Parameter(Mandatory=$false)][string]$Locale   ,
[Parameter(Mandatory=$false)][string]$RegionInfo   ,
[Parameter(Mandatory=$false)][string]$OfferDurableId ,
[Parameter(Mandatory=$false)][bool]$propagatetags=$true ,
[Parameter(Mandatory=$false)][string]$syncInterval='Hourly'                
)

#parameters 
$Timestampfield = "Timestamp" 
$log=@()
$ApiVersion = '2015-06-01-preview'
#region Define Ratecard defaults
IF([String]::IsNullOrEmpty($Currency)){  $Currency = 'USD' }
IF([String]::IsNullOrEmpty($Locale)){ $Locale = 'en-US'}
$regionlist=@{}
$regionlist.Add("Australia","AU")
$regionlist.Add("Afghanistan","AF")
$regionlist.Add("Albania","AL")
$regionlist.Add("Algeria","DZ")
$regionlist.Add("Angola","AO")
$regionlist.Add("Argentina","AR")
$regionlist.Add("Armenia","AM")
$regionlist.Add("Austria","AT")
$regionlist.Add("Azerbaijan","AZ")
$regionlist.Add("Bahamas","BS")
$regionlist.Add("Bahrain","BH")
$regionlist.Add("Bangladesh","BD")
$regionlist.Add("Barbados","BB")
$regionlist.Add("Belarus","BY")
$regionlist.Add("Belgium","BE")
$regionlist.Add("Belize","BZ")
$regionlist.Add("Bermuda","BM")
$regionlist.Add("Bolivia","BO")
$regionlist.Add("Bosnia and Herzegovina","BA")
$regionlist.Add("Botswana","BW")
$regionlist.Add("Brazil","BR")
$regionlist.Add("Brunei","BN")
$regionlist.Add("Bulgaria","BG")
$regionlist.Add("Cameroon","CM")
$regionlist.Add("Canada","CA")
$regionlist.Add("Cape Verde","CV")
$regionlist.Add("Cayman Islands","KY")
$regionlist.Add("Chile","CL")
$regionlist.Add("Colombia","CO")
$regionlist.Add("Costa Rica","CR")
$regionlist.Add("Côte D'ivoire","CI")
$regionlist.Add("Croatia","HR")
$regionlist.Add("Curaçao","CW")
$regionlist.Add("Cyprus","CY")
$regionlist.Add("Czech Republic","CZ")
$regionlist.Add("Denmark","DK")
$regionlist.Add("Dominican Republic","DO")
$regionlist.Add("Ecuador","EC")
$regionlist.Add("Egypt","EG")
$regionlist.Add("El Salvador","SV")
$regionlist.Add("Estonia","EE")
$regionlist.Add("Ethiopia","ET")
$regionlist.Add("Faroe Islands","FO")
$regionlist.Add("Fiji","FJ")
$regionlist.Add("Finland","FI")
$regionlist.Add("France","FR")
$regionlist.Add("Georgia","GE")
$regionlist.Add("Germany","DE")
$regionlist.Add("Ghana","GH")
$regionlist.Add("Greece","GR")
$regionlist.Add("Guatemala","GT")
$regionlist.Add("Honduras","HN")
$regionlist.Add("Hong Kong SAR","HK")
$regionlist.Add("Hungary","HU")
$regionlist.Add("Iceland","IS")
$regionlist.Add("India","IN")
$regionlist.Add("Indonesia","ID")
$regionlist.Add("Iraq","IQ")
$regionlist.Add("Ireland","IE")
$regionlist.Add("Israel","IL")
$regionlist.Add("Italy","IT")
$regionlist.Add("Jamaica","JM")
$regionlist.Add("Japan","JP")
$regionlist.Add("Jordan","JO")
$regionlist.Add("Kazakhstan","KZ")
$regionlist.Add("Kenya","KE")
$regionlist.Add("Korea","KR")
$regionlist.Add("Kuwait","KW")
$regionlist.Add("Kyrgyzstan","KG")
$regionlist.Add("Latvia","LV")
$regionlist.Add("Lebanon","LB")
$regionlist.Add("Libya","LY")
$regionlist.Add("Liechtenstein","LI")
$regionlist.Add("Lithuania","LT")
$regionlist.Add("Luxembourg","LU")
$regionlist.Add("Macao SAR","MO")
$regionlist.Add("Macedonia, FYRO","MK")
$regionlist.Add("Malaysia","MY")
$regionlist.Add("Malta","MT")
$regionlist.Add("Mauritius","MU")
$regionlist.Add("Mexico","MX")
$regionlist.Add("Moldova","MD")
$regionlist.Add("Monaco","MC")
$regionlist.Add("Mongolia","MN")
$regionlist.Add("Montenegro","ME")
$regionlist.Add("Morocco","MA")
$regionlist.Add("Namibia","NA")
$regionlist.Add("Nepal","NP")
$regionlist.Add("Netherlands","NL")
$regionlist.Add("New Zealand","NZ")
$regionlist.Add("Nicaragua","NI")
$regionlist.Add("Nigeria","NG")
$regionlist.Add("Norway","NO")
$regionlist.Add("Oman","OM")
$regionlist.Add("Pakistan","PK")
$regionlist.Add("Palestinian Territory","PS")
$regionlist.Add("Panama","PA")
$regionlist.Add("Paraguay","PY")
$regionlist.Add("Peru","PE")
$regionlist.Add("Philippines","PH")
$regionlist.Add("Poland","PL")
$regionlist.Add("Portugal","PT")
$regionlist.Add("Puerto Rico","PR")
$regionlist.Add("Qatar","QA")
$regionlist.Add("Romania","RO")
$regionlist.Add("Russia","RU")
$regionlist.Add("Rwanda","RW")
$regionlist.Add("Saint Kitts and Nevis","KN")
$regionlist.Add("Saudi Arabia","SA")
$regionlist.Add("Senegal","SN")
$regionlist.Add("Serbia","RS")
$regionlist.Add("Singapore","SG")
$regionlist.Add("Slovakia","SK")
$regionlist.Add("Slovenia","SI")
$regionlist.Add("South Africa","ZA")
$regionlist.Add("Spain","ES")
$regionlist.Add("Sri Lanka","LK")
$regionlist.Add("Sweden","SE")
$regionlist.Add("Switzerland","CH")
$regionlist.Add("Taiwan","TW")
$regionlist.Add("Tajikistan","TJ")
$regionlist.Add("Tanzania","TZ")
$regionlist.Add("Thailand","TH")
$regionlist.Add("Trinidad and Tobago","TT")
$regionlist.Add("Tunisia","TN")
$regionlist.Add("Turkey","TR")
$regionlist.Add("Turkmenistan","TM")
$regionlist.Add("U.S. Virgin Islands","VI")
$regionlist.Add("Uganda","UG")
$regionlist.Add("Ukraine","UA")
$regionlist.Add("United Arab Emirates","AE")
$regionlist.Add("United Kingdom","GB")
$regionlist.Add("United States","US")
$regionlist.Add("Uruguay","UY")
$regionlist.Add("Uzbekistan","UZ")
$regionlist.Add("Venezuela","VE")
$regionlist.Add("Vietnam","VN")
$regionlist.Add("Yemen","YE")
$regionlist.Add("Zambia","ZM")
$regionlist.Add("Zimbabwe","ZW")
$RegionIso=$regionlist.item($regioninfo)

$defaultCurrency=@("Afghanistan;USD",
"Albania;USD",
"Algeria;USD",
"Angola;USD",
"Argentina;ARS",
"Armenia;USD",
"Australia;AUD",
"Austria;EUR",
"Azerbaijan;USD",
"Bahamas;USD",
"Bahrain;USD",
"Bangladesh;USD",
"Barbados;USD",
"Belarus;USD",
"Belgium;EUR",
"Belize;USD",
"Bermuda;USD",
"Bolivia;USD",
"Bosnia and Herzegovina;USD",
"Botswana;USD",
"Brazil;BRL",
"Brazil;USD",
"Brunei Darussalam;USD",
"Bulgaria;EUR",
"Cameroon;USD",
"Canada;CAD",
"Cape Verde;USD",
"Cayman Islands;USD",
"Chile;USD",
"Colombia;USD",
"Congo;USD",
"Costa Rica;USD",
"Côte D'ivoire;USD",
"Croatia;EUR",
"Croatia;USD",
"Curaçao;USD",
"Cyprus;EUR",
"Czech Republic;EUR",
"Denmark;DKK",
"Dominican Republic;USD",
"Ecuador;USD",
"Egypt;USD",
"El Salvador;USD",
"Estonia;EUR",
"Ethiopia;USD",
"Faroe Islands;EUR",
"Fiji;USD",
"Finland;EUR",
"France;EUR",
"Georgia;USD",
"Germany;EUR",
"Ghana;USD",
"Greece;EUR",
"Guatemala;USD",
"Honduras;USD",
"Hong Kong;HKD",
"Hong Kong SAR;USD",
"Hungary;EUR",
"Iceland;EUR",
"India;INR",
"India;USD",
"Indonesia;IDR",
"Iraq;USD",
"Ireland;EUR",
"Israel;USD",
"Italy;EUR",
"Jamaica;USD",
"Japan;JPY",
"Jordan;USD",
"Kazakhstan;USD",
"Kenya;USD",
"Korea;KRW",
"Kuwait;USD",
"Kyrgyzstan;USD",
"Latvia;EUR",
"Lebanon;USD",
"Libya;USD",
"Liechtenstein;CHF",
"Lithuania;EUR",
"Luxembourg;EUR",
"Macao;USD",
"Macedonia;USD",
"Malaysia;MYR",
"Malaysia;USD",
"Malta;EUR",
"Mauritius;USD",
"Mexico;MXN",
"Mexico;USD",
"Moldova;USD",
"Monaco;EUR",
"Mongolia;USD",
"Montenegro;USD",
"Morocco;USD",
"Namibia;USD",
"Nepal;USD",
"Netherlands;EUR",
"New Zealand;NZD",
"Nicaragua;USD",
"Nigeria;USD",
"Norway;NOK",
"Oman;USD",
"Pakistan;USD",
"Palestinian Territory, Occupied;USD",
"Panama;USD",
"Paraguay;USD",
"Peru;USD",
"Philippines;USD",
"Poland;EUR",
"Portugal;EUR",
"Puerto Rico;USD",
"Qatar;USD",
"Romania;EUR",
"Russia;RUB",
"Rwanda;USD",
"Saint Kitts and Nevis;USD",
"Saudi Arabia;SAR",
"Senegal;USD",
"Serbia;USD",
"Singapore;USD",
"Slovakia;EUR",
"Slovenia;EUR",
"South Africa;ZAR",
"Spain;EUR",
"Sri Lanka;USD",
"Sweden;SEK",
"Switzerland;CHF",
"Taiwan;TWD",
"Tajikistan;USD",
"Tanzania;USD",
"Thailand;USD",
"Trinidad and Tobago;USD",
"Tunisia;USD",
"Turkey;TRY",
"Turkmenistan;USD",
"UAE;USD",
"Uganda;USD",
"Ukraine;USD",
"United Kingdom;GBP",
"United States;USD",
"Uruguay;USD",
"Uzbekistan;USD",
"Venezuela;USD",
"Viet Nam;USD",
"Virgin Islands, US;USD",
"Yemen;USD",
"Zambia;USD",
"Zimbabwe;USD")


IF(!($defaultCurrency|where{$_ -match $RegionInfo -and $_ -match $Currency}))
{

$Currency=@($defaultCurrency|where{$_ -match $RegionInfo})[0].Split(';')[1]

}



IF([String]::IsNullOrEmpty($RegionIso)){ $RegionIso= 'US'}
IF([String]::IsNullOrEmpty($OfferDurableId)){ $OfferDurableId = 'MS-AZR-0003P' }Else
{
	$OfferDurableId=$OfferDurableId.Split(':')[0].trim()
}

#endregion


#Update customer Id to your Operational Insights workspace ID
$customerID = Get-AutomationVariable -Name  "AzureUsage-OPSINSIGHTS_WS_ID"
#For shared key use either the primary or seconday Connected Sources client authentication key   
$sharedKey = Get-AutomationVariable -Name  "AzureUsage-OPSINSIGHTS_WS_KEY"
#log analytics custom log name
$logname='AzureUsage'
#variable to store the output from runspaces 
[Collections.Arraylist]$instanceResults = @()
$colltime=(get-date).ToUniversalTime().ToString("yyyy-MM-ddThh:00:00.000Z")
#region define  functions
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
	$response = Invoke-WebRequest -Uri $uri -Method $method -ContentType $contentType -Headers $OMSheaders -Body $body -UseBasicParsing
	return $response.StatusCode
	$log+= "$(get-date)   -  OMS Data Upload ststus code $($response.StatusCod) " 
}
function Calculate-rate ($meter,[double]$quantity)
{
#"Quantitiy $quantity "
	$i=0
	$calcCost=$calcSaving=$calcLowestCost=0
	$meterArr=@()
	$meterArr=[array]$meter.MeterRates.psobject.Properties
	If($meterArr.Count -eq 1)
	{
		$calcCost=[double]$meterArr[0].Value*$quantity
	}
	Else
	{
		$i=0
		$remaining=$quantity
		$calcCost=0
		$meter.MeterRates.psobject.Properties|Foreach-object{
			[long]$curname=$_.name
			[double]$curval=$_.value
			"$curname  $curval  -$i"
			IF ($i -gt 0 -and $quantity -gt 0 )
			{
				IF($quantity -le $curname )
				{
					$calcCost+=$lastval*$quantity
					"cost =  $lastval * $quantity  =$calcCost"
					$quantity=$quantity-$curname
				}
				Else
				{
					$calcCost+=($curname-$lastname)*$lastval
					$quantity=$quantity-$curname
					"cost =  ($curname - $lastname) * $lastval  , total cost: $calcCost"
					"Reamining $quantity"
					
				}
				
			}
			
			$i++
			$lastname=$curname
			$lastval=$curval
		}
	}
	$calcBillItem = New-Object PSObject -Property @{
		calcCost=[double]$calcCost
	}
	Return $calcBillItem
}
Function find-lowestcost ($meter)
{
#get lowest cost region 
	$filteredMEters=$meters|where{$_.MeterCategory -eq $meter.MeterCategory -and $_.MeterName -eq $Meter.MeterName -and $_.MeterSubCategory -eq $meter.MeterSubCategory -and ![string]::IsNullOrEmpty($_.MeterREgion)}
	$sortedMEter=@()
	Foreach($billRegion in $filteredMEters)
	{
		$sortedMeter+=new-object PSobject -Property @{
			MeterRegion=$billRegion.MeterRegion
			Meterrates=$billRegion.MeterRates.0
			Rates=$billRegion.MeterRates
			MeterID=$billRegion.MeterId
		}
	}
	$resultarr=@()
	$sortedMEter|where {$_.Meterrates -eq $($sortedMEter|Sort-Object -Property Meterrates |select -First 1).Meterrates}|?{
		$lowestregion+="$($_.MEterregion),"
		$resultarr+=New-Object PSObject -Property @{
			Lowcostregion=$_.MEterregion
			LowcostregionCost=[double]$_.MeterRates
			Meterid=$_.MeterId
		}
	}
	return $resultarr
}
#endregion
#region connect to Azure
# Get the connection "AzureRunAsConnection "
$ArmConn = Get-AutomationConnection -Name AzureRunAsConnection       
Write-Output  "Logging in to Azure..."
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
	Write-Output   "Successfully connected to Azure ARM REST"
}
#endregion 
$ScriptBlock = {
	Param ($hash,$meters,$metrics)
	$start=get-date
#region define  functions
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
		$response = Invoke-WebRequest -Uri $uri -Method $method -ContentType $contentType -Headers $OMSheaders -Body $body -UseBasicParsing
		return $response.StatusCode
		$log+= "$(get-date)   -  OMS Data Upload ststus code $($response.StatusCod) " 
	}
	function Calculate-rate ($meter,[double]$quantity)
	{
#"Quantitiy $quantity "
		$i=0
		$calcCost=$calcSaving=$calcLowestCost=0
		$meterArr=@()
		$meterArr=[array]$meter.MeterRates.psobject.Properties
		If($meterArr.Count -eq 1)
		{
			$calcCost=[double]$meterArr[0].Value*$quantity
		}
		Else
		{
			$i=0
			$remaining=$quantity
			$calcCost=0
			$meter.MeterRates.psobject.Properties|Foreach-object{
				[long]$curname=$_.name
				[double]$curval=$_.value
				"$curname  $curval  -$i"
				IF ($i -gt 0 -and $quantity -gt 0 )
				{
					IF($quantity -le $curname )
					{
						$calcCost+=$lastval*$quantity
						"cost =  $lastval * $quantity  =$calcCost"
						$quantity=$quantity-$curname
					}
					Else
					{
						$calcCost+=($curname-$lastname)*$lastval
						$quantity=$quantity-$curname
						"cost =  ($curname - $lastname) * $lastval  , total cost: $calcCost"
						"Reamining $quantity"
						
					}
					
				}
				
				$i++
				$lastname=$curname
				$lastval=$curval
			}
		}

		$filteredMEters=$meters|where{$_.MeterCategory -eq $meter.MeterCategory -and $_.MeterName -eq $Meter.MeterName -and $_.MeterSubCategory -eq $meter.MeterSubCategory -and ![string]::IsNullOrEmpty($_.MeterREgion)}
		$sortedMEter=@()
		Foreach($billRegion in $filteredMEters)
		{
			$sortedMeter+=new-object PSobject -Property @{
				MeterRegion=$billRegion.MeterRegion
				Meterrates=$billRegion.MeterRates.0
				Rates=$billRegion.MeterRates
			}
		}
		$sortedMEter|where {$_.Meterrates -eq $($sortedMEter|Sort-Object -Property Meterrates |select -First 1).Meterrates}|?{$lowestregion+="$($_.MEterregion),"}
		If ($lowestregion -match $meter.MeterRegion)
		{
			$calcLowestCost=$calcCost
			$calcSaving=0
		}
		Else
		{
			$calcLowestCost=0
			$lowestRate=($sortedMEter|Sort-Object -Property Meterrates |select -First 1).Rates
			$meterArr=[array]$lowestRate.psobject.Properties
			If($meterArr.Count -eq 1)
			{
				$calcLowestCost=[double]$meterArr[0].Value*$quantity
			}
			Else
			{
				$i=0
				$remaining=$quantity
				$calcLowestCost=0
				$lowestRate.psobject.Properties|Foreach-object{
					[long]$curname=$_.name
					[double]$curval=$_.value
					"$curname  $curval  -$i"
					IF ($i -gt 0 -and $quantity -gt 0 )
					{
						IF($quantity -le $curname )
						{
							$calcLowestCost+=$lastval*$quantity
							"cost =  $lastval * $quantity  =$calcLowestCost"
							$quantity=$quantity-$curname
						}
						Else
						{
							$calcLowestCost+=($curname-$lastname)*$lastval
							$quantity=$quantity-$curname
							"cost =  ($curname - $lastname) * $lastval  , total cost: $calcLowestCost"
							"Remaining $quantity"
							
						}
						
					}
					
					$i++
					$lastname=$curname
					$lastval=$curval
				}
			}
			$calcSaving=$calcCost-$calcLowestCost
		}
#>
		$calcBillItem = New-Object PSObject -Property @{
			calcCost=[double]$calcCost
		}
		Return $calcBillItem
	}
	Function find-lowestcost ($meter)
	{
		$filteredMEters=$meters|where{$_.MeterCategory -eq $meter.MeterCategory -and $_.MeterName -eq $Meter.MeterName -and $_.MeterSubCategory -eq $meter.MeterSubCategory -and ![string]::IsNullOrEmpty($_.MeterREgion)}
		$sortedMEter=@()
		Foreach($billRegion in $filteredMEters)
		{
			$sortedMeter+=new-object PSobject -Property @{
				MeterRegion=$billRegion.MeterRegion
				Meterrates=$billRegion.MeterRates.0
				Rates=$billRegion.MeterRates
				MeterID=$billRegion.MeterId
			}
		}
		$resultarr=@()
		$sortedMEter|where {$_.Meterrates -eq $($sortedMEter|Sort-Object -Property Meterrates |select -First 1).Meterrates}|?{
			$lowestregion+="$($_.MEterregion),"
			$resultarr+=New-Object PSObject -Property @{
				Lowcostregion=$_.MEterregion
				LowcostregionCost=[double]$_.MeterRates
				Meterid=$_.MeterId
			}
		}
		return $resultarr
	}
#endregion
	$subscriptionInfo=$hash.subscriptionInfo
	$ArmConn=$hash.ArmConn
	$headers=$hash.headers
	$Timestampfield = $hash.Timestampfield
	$ApiVersion = $hash.ApiVersion 
	$Currency=$hash.Currency
	$Locale=$hash.Locale
	$RegionInfo=$hash.RegionInfo
	$OfferDurableId=$hash.OfferDurableId
	$syncInterval=$Hash.syncInterval
	$allrg=$hash.allrg
	$resmap=$hash.resmap
#Update customer Id to your Operational Insights workspace ID
	$customerID =$hash.customerID 
#For shared key use either the primary or seconday Connected Sources client authentication key   
	$sharedKey = $hash.sharedKey
#log analytics custom log name
	$logname=$hash.Logname
#region calculate and upload
	$colbilldata=@()
	$colTaggedbilldata=@()
	$ratescache=@{}
	$count=1
	$metrics|Foreach{
		$metricitem=$null
		$metricitem=$_
		$obj=$resid=$location=$resource=$null
		IF($metricitem.instanceData)
		{
			$insdata=$cu=$null
			$insdata=(convertfrom-json $metricitem.instanceData).'Microsoft.Resources'
			$resid=$insdata.resourceUri
			$rg=$allrg|where {$_.Name -eq $resid.Split('/')[4]}
			$tag=$null
			$tags=$null
			$tags=@{}
			$restag=$null
			$restag=(convertfrom-json $metricitem.instanceData).'Microsoft.Resources'.tags
			If ($restag)
			{
				$restag.PSObject.Properties | foreach-object {
					
					# add the tag if not  in the list already 
					$tags.add($_.Name,$_.value)
					# $tags|add-member -MemberType NoteProperty -Name -ea 0
				}   
			}
			$UsageType=$insdata.additionalInfo.UsageType
			$Meter=($meters|where {$_.meterid -eq $metricitem.meterId})
			$price=Calculate-rate -meter $meter -quantity $metricitem.quantity
			$cu = New-Object PSObject -Property @{
				Timestamp = $metricitem.usageStartTime
				Collectiontime=$colltime 
				meterCategory= $Meter.meterCategory
				meterSubCategory= $Meter.meterSubCategory
				meterName= $Meter.meterName 
				unit=$metricitem.unit
				quantity=$metricitem.quantity
				Location=$insdata.location
				ResourceGroup=$insdata.resourceUri.Split('/')[4]
				Cost=$price.calcCost
				SubscriptionId = $ArmConn.SubscriptionID;
				AzureSubscription = $subscriptionInfo.displayname;
				usageEndTime=$metricitem.usageEndTime 
				UsageType=$insdata.additionalInfo.UsageType
				Resource=$insdata.resourceUri.Split('/')[$insdata.resourceUri.Split('/').count-1]
				Aggregation=$syncInterval
				CostTag='Overall'
				OfferDurableId=$OfferDurableId
				Currency=$Currency
				Locale=$Locale
				RegionInfo=$RegionInfo
			}
			#adding to array
			$colbilldata+=$cu
			#  Write-verbose $cu -Verbose
			IF($propagatetags -eq $true -and ![string]::IsNullOrEmpty($rg.tags) )
			{ 
				$rg.tags.PSObject.Properties | foreach-object {
					
					# add the tag if not  in the list already 
					$tags.add($_.Name,$_.value)
				}        
			}
			
			If($tags)
			{
				foreach ($tag in $tags.Keys)
				{
					
					$cu = New-Object PSObject -Property @{
						Timestamp = $metricitem.usageStartTime
						Collectiontime=$colltime 
						meterCategory= $meter.meterCategory
						meterSubCategory= $meter.meterSubCategory
						meterName= $meter.meterName 
						unit=$metricitem.unit
						quantity=$metricitem.quantity
						Location=$insdata.location
						ResourceGroup=$insdata.resourceUri.Split('/')[4]
						TaggedCost=$price.calcCost
						SubscriptionId = $ArmConn.SubscriptionID;
						AzureSubscription = $subscriptionInfo.displayname;
						usageEndTime=$metricitem.usageEndTime 
						
						UsageType=$insdata.additionalInfo.UsageType
						Resource=$insdata.resourceUri.Split('/')[$insdata.resourceUri.Split('/').count-1]
						Aggregation=$syncInterval
						Tag="$tag : $($tags.item($tag))"
						OfferDurableId=$OfferDurableId
						Currency=$Currency
						Locale=$Locale
						RegionInfo=$RegionInfo
					}
					$cu|add-member -MemberType NoteProperty -Name $tag  -Value $tags.item($tag) -ea 0
					#adding to array
					$colTaggedbilldata+=$cu
					
					#End tag processing 
				}
			}
		}
		Else{
			$obj=$resid=$meteredRegion=$meteredService=$project=$cu1=$null
			$meteredRegion=$metricitem.infoFields.meteredRegion
			$meteredServiceType=$metricitem.infoFields.meteredServiceType
			$rgcls=$null
			$rg=$null
			IF ($metricitem.infoFields.meteredservice -eq 'Compute')
			{
				$rgcls=$metricitem.infoFields.project.Split('(')[0]
				$rg=$allrg|where {$_.Name -eq $rgcls}
			}Else
			{
				$rgcls=($resmap|where{$_.Resource -eq "$($metricitem.infoFields.project)"}).Resourcegroup
				$rg=$allrg|where {$_.Name -eq $rgcls}
			}
			$project=$metricitem.infoFields.project
			$price=$null
			$Meter=($meters|where {$_.meterid -eq $metricitem.meterId})
			$price=Calculate-rate -meter $meter -quantity $metricitem.quantity
			$cu1 = New-Object PSObject -Property @{
				
				Timestamp = $metricitem.usageStartTime
				Collectiontime=$colltime 
				meterCategory= $meter.meterCategory
				meterSubCategory= $meter.meterSubCategory
				meterName= $meter.meterName 
				unit=$metricitem.unit
				quantity=$metricitem.quantity
				Location=$metricitem.infoFields.meteredRegion
				ResourceGroup=$Rgcls
				Cost=$price.calcCost
				SubscriptionId = $ArmConn.SubscriptionID;
				AzureSubscription = $subscriptionInfo.displayname;
				usageEndTime=$metricitem.usageEndTime 
				Resource= $metricitem.infoFields.project
				Aggregation=$syncInterval
				CostTag="Overall"
				OfferDurableId=$OfferDurableId
				Currency=$Currency
				Locale=$Locale
				RegionInfo=$RegionInfo
			}
			#adding to array
			$colbilldata+=$cu1
			#  Write-Verbose $cu1 -Verbose
			IF($propagatetags -eq $true -and ![string]::IsNullOrEmpty($rg.Tags) )
			{
				"tags $($rg.Tags) added to classic res"
				
				
				$rg.tags.PSObject.Properties | foreach-object {
					
					# add the tag if not  in the list already 
					$tags.add($_.Name,$_.value)
					# $tags|add-member -MemberType NoteProperty -Name -ea 0
				}   
				foreach ($tag in $tags.Keys)
				{
					
					
					$cu1=$null
					$cu1 = New-Object PSObject -Property @{
						Timestamp = $metricitem.usageStartTime
						Collectiontime=$colltime                                     
						meterCategory= $meter.meterCategory
						meterSubCategory= $meter.meterSubCategory
						meterName= $meter.meterName 
						unit=$metricitem.unit
						quantity=$metricitem.quantity
						Location=$metricitem.infoFields.meteredRegion
						ResourceGroup=$Rgcls
						TaggedCost=$price.calcCost
						SubscriptionId = $ArmConn.SubscriptionID;
						AzureSubscription = $subscriptionInfo.displayname;
						usageEndTime=$metricitem.usageEndTime 
						Resource= $metricitem.infoFields.project
						Aggregation=$syncInterval
						Tag="$tag : $($tags.item($tag))" 
						OfferDurableId=$OfferDurableId
						Currency=$Currency
						Locale=$Locale
						RegionInfo=$RegionInfo
						
					}
					$cu1|add-member -MemberType NoteProperty -Name $tag  -Value $tags.item($tag) -ea 0
					#adding to array
					$colTaggedbilldata+=$cu1  
					
					
					#End tag processing 
				}
			}
		}
		$count++
	}
	$jsoncolbill = ConvertTo-Json -InputObject $colbilldata
# Submit the data to the API endpoint
	If($jsoncolbill){$postres=Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($jsoncolbill)) -logType $logname}
	If ($postres -ge 200 -and $postres -lt 300)
	{
		#Write-Output " Succesfully uploaded $($colbilldata.count) usage metrics to OMS"
	}
	Else
	{
		Write-Warning " Failed to upload  $($colbilldata.count)  metrics to OMS"
	}
	IF($colTaggedbilldata)
	{
		$jsoncolbill = ConvertTo-Json -InputObject $colTaggedbilldata
# Submit the data to the API endpoint
		If($jsoncolbill){$postres=Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($jsoncolbill)) -logType $logname}
		If ($postres -ge 200 -and $postres -lt 300)
		{
			#Write-Output " Succesfully uploaded $($colTaggedbilldata.count) tagged usage metrics to OMS"
		}
		Else
		{
			Write-Warning " Failed to upload  $($colTaggedbilldata.count) tagged usage metrics to OMS"
		}
	}
#endregion
	$end=get-date
	$timetaken = ($end-$start).Totalseconds
	Write-Information "$timetaken   seconds ..." -Verbose
}
#region MAin
#region Get Meter  data
Write-Output " Getting all available rates... "
$uri= "https://management.azure.com/subscriptions/{5}/providers/Microsoft.Commerce/RateCard?api-version={0}&`$filter=OfferDurableId eq '{1}' and Currency eq '{2}' and Locale eq '{3}' and RegionInfo eq '{4}'" -f $ApiVersion, $OfferDurableId, $Currency, $Locale, $RegionIso, $SubscriptionId
$resp=Invoke-WebRequest -Uri $uri -Method GET  -Headers $headers -UseBasicParsing -Timeout 180
$res=ConvertFrom-Json -InputObject $resp.Content
$Meters=$res.meters
If([string]::IsNullOrEmpty($Meters))
{
	Write-warning "Rates are not available ,  runbook will try again after 15 minutes"
	$rescheduleRB=$true 
# add new automation job  and exit
	exit
}
#endregion
#region cache resource groups  
$Uri="https://management.azure.com/subscriptions/$subscriptionid/resourcegroups?api-version=2016-09-01"
$resp=Invoke-WebRequest -Uri $uri -Method GET  -Headers $headers -UseBasicParsing -TimeoutSec 180
$res=@()
$content=ConvertFrom-Json -InputObject $resp.Content
$res+=$content
IF(![string]::IsNullOrEmpty($res.nextLink))
{
	do 
	{
		$uri2=$content.nextLink
		$content=$null
		$resultarm = Invoke-WebRequest -Method $HTTPVerb -Uri $uri2 -Headers $headers -UseBasicParsing
		$content=$resultarm.Content
		$content= ConvertFrom-Json -InputObject $resultarm.Content
		$res+=$content
		$uri2=$null
	}While (![string]::IsNullOrEmpty($content.nextLink))
}
$allRg=$res.value
$Uriresources="https://management.azure.com/subscriptions/$subscriptionid/resources?api-version=2016-09-01" 
$respresources=Invoke-WebRequest -Uri $uriresources -Method GET  -Headers $headers -UseBasicParsing -TimeoutSec 180
$resresources=@()
$resresources+=ConvertFrom-Json -InputObject $respresources.Content
IF(![string]::IsNullOrEmpty($resresources.nextLink))
{
	do 
	{
		
		$uri2=$resresources.nextLink
		$content=$null
		$resultarm = Invoke-WebRequest -Method $HTTPVerb -Uri $uri2 -Headers $headers -UseBasicParsing
		$content=$resultarm.Content
		$content= ConvertFrom-Json -InputObject $resultarm.Content
		$resresources+=$content
		$uri2=$null
	}While (![string]::IsNullOrEmpty($content.nextLink))
}
write-output "$($resresources.value.count) resources found"
$resmap=@()   
foreach($azres in $resresources.value)
{
	$resgrp=$null
	$resgrp=$azres.id.split('/')[4]
	$resmap+=New-Object PSObject -Property @{
		
		Resource=$azres.name
		REsourceGroup=$resgrp
		Type=$azres.type
	}
}
#endregion
IF($syncInterval -eq 'Hourly')
{
	$end=(get-date).AddHours(-1).ToUniversalTime().ToString("yyyy-MM-dd'T'HH:00:00")
	$start=(get-date).AddHours(-2).ToUniversalTime().ToString("yyyy-MM-dd'T'HH:00:00")
	$Uri="https://management.azure.com/subscriptions/$subscriptionid/providers/Microsoft.Commerce/UsageAggregates?api-version=2015-06-01-preview&reportedStartTime=$start&reportedEndTime=$end&aggregationGranularity=$syncInterval&showDetails=true"
}
Else
{
	$end=(get-date).ToUniversalTime().ToString("yyyy-MM-dd'T'00:00:00")
	$start=(get-date).Adddays(-1).ToUniversalTime().ToString("yyyy-MM-dd'T'00:00:00")
	$Uri="https://management.azure.com/subscriptions/$subscriptionid/providers/Microsoft.Commerce/UsageAggregates?api-version=2015-06-01-preview&reportedStartTime=$start&reportedEndTime=$end&aggregationGranularity=$syncInterval&showDetails=true"
}
Write-Output "Fetching Usage data for  $start (UTC) and $end (UTC) , Currency :$Currency Locate : $Locale ,Region: $RegionIso , Azure Subs Type : $OfferDurableId "
$resp=Invoke-WebRequest -Uri $uri -Method GET  -Headers $headers -UseBasicParsing  -TimeoutSec 180
$res=@()
$content=ConvertFrom-Json -InputObject $resp.Content
$res+=$content
IF(![string]::IsNullOrEmpty($res.nextLink))
{
	do 
	{
		$uri2=$content.nextLink
		$content=$null
		$resultarm = Invoke-WebRequest -Method $HTTPVerb -Uri $uri2 -Headers $headers -UseBasicParsing
		$content=$resultarm.Content
		$content= ConvertFrom-Json -InputObject $resultarm.Content
		$res+=$content
		$uri2=$null
	}While (![string]::IsNullOrEmpty($content.nextLink))
}
$metrics=$res.value.Properties
$metrics=$metrics|Sort-Object -Property metercategory -Descending 
#split into chunks to speed up data ingestion
Write-output "$($metrics.count) usage metrics  found "
$spltlist=@()
If($metrics.count -gt 200)
{
	$splitSize=200
	$spltlist+=for ($Index = 0; $Index -lt  $metrics.Count; $Index += $splitSize)
	{
		,($metrics[$index..($index+$splitSize-1)])
	}
}Elseif($metrics.count -gt 100)
{
	$splitSize=100
	$spltlist+=for ($Index = 0; $Index -lt  $metrics.Count; $Index += $splitSize)
	{
		,($metrics[$index..($index+$splitSize-1)])
	}
}Else{
	$spltlist+=,($metrics)
}
#main 
$hash = [hashtable]::New(@{})
## define  synced variable GetValues
$hash['Host']=$host
$hash['subscriptionInfo']=$subscriptionInfo
$hash['ArmConn']=$ArmConn
$hash['headers']=$headers
$hash['Timestampfield']=$Timestampfield
$hash['ApiVersion'] =$ApiVersion 
$hash['Currency']=$Currency
$hash['Locale']=$Locale
$hash['RegionInfo']=$RegionInfo
$hash['OfferDurableId']=$OfferDurableId
$hash['allrg']=$allrg
$hash['resmap']=$resmap
$hash['customerID'] =$customerID
$hash['syncInterval']=$syncInterval
$hash['sharedKey']=$sharedKey 
$hash['Logname']=$logname
$Throttle = 6 #threads
$sessionstate = [system.management.automation.runspaces.initialsessionstate]::CreateDefault()
$runspacepool = [runspacefactory]::CreateRunspacePool(1, $Throttle, $sessionstate, $Host)
$runspacepool.Open() 
$Jobs = @()
write-output "$($metrics.count) objects will be processed "
$i=1 
$spltlist|foreach{
	$splitmetrics=$null
	$splitmetrics=$_
	$Job = [powershell]::Create().AddScript($ScriptBlock).AddArgument($hash).AddArgument($meters).AddArgument($splitmetrics)
	$Job.RunspacePool = $RunspacePool
	$Jobs += New-Object PSObject -Property @{
		RunNum = $_
		Pipe = $Job
		Result = $Job.BeginInvoke()
	}
	write-output  "$(get-date)  , started Runsapce $i "
	$i++
}
Write-Output "Waiting.."
Do {
	Start-Sleep -Seconds 60
} While ( $Jobs.Result.IsCompleted -contains $false)
Write-Host "All jobs completed!"
$Results = @()
ForEach ($Job in $Jobs)
{
	$Results += $Job.Pipe.EndInvoke($Job.Result)
	if($jobs[0].Pipe.HadErrors)
	{
		write-warning "$($jobs.Pipe.Streams.Error.exception)"
	}
}
#$Results
$jobs|foreach{$_.Pipe.Dispose()}
$runspacepool.Close()
[gc]::Collect()
