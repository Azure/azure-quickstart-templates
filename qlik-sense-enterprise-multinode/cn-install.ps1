<# Qlik Sense Installation #>

# variables
$adminUser = $Args[0]
$adminPass = $Args[1]
$serviceAccountUser = $Args[2]
$serviceAccountPass = $Args[3]
$dbPass = $Args[4]
$qlikSenseVersion = $($Args[5])
$serviceAccountWithDomain = -join ($($env:ComputerName), '\',$($Args[2]))
$qlikSenseSerial = $Args[6]
$qlikSenseControl = $Args[7]
$qlikSenseOrganization = $($Args[8])
$qlikSenseName = $($Args[9])

function Write-Log
{
    param (
        [Parameter(Mandatory)]
        [string]$Message,
        [Parameter()]
        [ValidateSet('Info','Warn','Error')]
        [string]$Severity = 'Info'
    )
    
    $line = [pscustomobject]@{
        'DateTime' = (Get-Date)
        'Severity' = $Severity
        'Message' = $Message
        
    }
    Write-Host "$($line.DateTime) [$($line.Severity)]: $($line.Message)"
    $line | Export-Csv -Path c:\installation\QlikProvision.log -Append -NoTypeInformation
}

$json = @{
    qliksense = @(
        @{
            name= "Qlik Sense November 2017 Patch 1"
            url= "https://da3hntz84uekx.cloudfront.net/QlikSense/11.24/1/_MSI/Qlik_Sense_update.exe"
            url2= "https://da3hntz84uekx.cloudfront.net/QlikSense/11.24/0/_MSI/Qlik_Sense_setup.exe"
        },
        @{
            name= "Qlik Sense November 2017"
            url= "https://da3hntz84uekx.cloudfront.net/QlikSense/11.24/0/_MSI/Qlik_Sense_setup.exe"
        },
        @{
            name= "Qlik Sense September 2017 Patch 1"
            url= "https://da3hntz84uekx.cloudfront.net/QlikSense/11.14/1/_MSI/Qlik_Sense_update.exe"
            url2= "https://da3hntz84uekx.cloudfront.net/QlikSense/11.14/0/_MSI/Qlik_Sense_setup.exe"
        },
        @{
            name= "Qlik Sense September 2017"
            url= "https://da3hntz84uekx.cloudfront.net/QlikSense/11.14/0/_MSI/Qlik_Sense_setup.exe"
          },
        @{
            name= "Qlik Sense June 2017 Patch 3"
            url= "https://da3hntz84uekx.cloudfront.net/QlikSense/11.11/3/_MSI/Qlik_Sense_update.exe"
            url2= "https://da3hntz84uekx.cloudfront.net/QlikSense/11.11/0/_MSI/Qlik_Sense_setup.exe"
        },
        @{  
            name= "Qlik Sense June 2017 Patch 2"
            url= "https://da3hntz84uekx.cloudfront.net/QlikSense/11.11/2/_MSI/Qlik_Sense_update.exe"
            url2= "https://da3hntz84uekx.cloudfront.net/QlikSense/11.11/0/_MSI/Qlik_Sense_setup.exe"
        },
        @{
            name= "Qlik Sense June 2017 Patch 1"
            url= "https://da3hntz84uekx.cloudfront.net/QlikSense/11.11/1/_MSI/Qlik_Sense_update.exe"
            url2= "https://da3hntz84uekx.cloudfront.net/QlikSense/11.11/0/_MSI/Qlik_Sense_setup.exe"
        },
        @{
            name= "Qlik Sense June 2017"
            url= "https://da3hntz84uekx.cloudfront.net/QlikSense/11.11/0/_MSI/Qlik_Sense_setup.exe"
        },
        @{
            name= "Qlik Sense 3.2 SR5"
            url= "https://da3hntz84uekx.cloudfront.net/QlikSense/3.2.5/205/_MSI/Qlik_Sense_setup.exe"
        },
        @{
            name= "Qlik Sense 3.2 SR4"
            url= "https://da3hntz84uekx.cloudfront.net/QlikSense/3.2.4/204/_MSI/Qlik_Sense_setup.exe"
        }
    )
}

$json | ConvertTo-Json -Compress -Depth 10 | Out-File 'c:\installation\qBinaryDownload.json'

# create qlik sense service account
Write-Log -Message "Creating Service Account $($serviceAccountUser)"
net user "$($serviceAccountUser)" "$($serviceAccountPass)" /add /fullname:"Qlik Sense Service Account" /passwordchg:NO
Write-Log -Message "Adding $($serviceAccountUser) to local administrators"
([ADSI]"WinNT://$($env:computername)/administrators,group").psbase.Invoke("Add",([ADSI]"WinNT://$($env:computername)/$($serviceAccountUser)").path)

# create folder for shared persistence and share folder
Write-Log -Message "Creating directory for shared persistence"
New-Item -ItemType directory -Path C:\Qlik
Write-Log -Message "Creating file share"
New-SmbShare -Name Qlik -Path C:\Qlik -FullAccess everyone

#download installation files
Write-Log -Message "Installing NuGet package provider"
Get-PackageProvider -Name NuGet -ForceBootstrap
Write-Log -Message "Installing Qlik-CLI module"
Install-Module -Name Qlik-CLI -Confirm:$false -Force

# download selected Qlik Sense binary and update if selected
$json = (@{
    name = $qlikSenseVersion;}) 

$json | ConvertTo-Json -Compress -Depth 10 | Out-File 'c:\installation\qsVer.json'

Write-Log -Message "Downloading $qlikSenseVersion"
$qsVer = (Get-Content C:\installation\qsVer.json -raw) | ConvertFrom-Json
$qsBinaryURL = (Get-Content C:\installation\qBinaryDownload.json -raw) | ConvertFrom-Json
$binaryName = $qsBinaryURL.qliksense | where { $_.name -eq $qsVer.name}
$selVer = $qsBinaryURL.qliksense | where { $_.name -eq $qsVer.name }
$path = 'c:\installation'
$url = $selVer.url
$fileName = $url.Substring($url.LastIndexOf("/") + 1)
$dlLoc = join-path $path $fileName
if ($selVer.name -like "*Patch*") {
    (New-Object System.Net.WebClient).DownloadFile($url, $dlLoc)
    $url2 = $selVer.url2
    $fileName = $url2.Substring($url2.LastIndexOf("/") + 1)
    $dlLoc = join-path $path $fileName
    (New-Object System.Net.WebClient).DownloadFile($url2, $dlLoc)
   }
else
   {
   (New-Object System.Net.WebClient).DownloadFile($url, $dlLoc)
   }

# Opening Firewall ports 443/4244, 80/4248
Write-Log -Message "Opening firewall ports 443, 4244, 80, 4248, 4242, 4432, 4444, 5355, 5353"
New-NetFirewallRule -DisplayName "Qlik Sense" -Direction Inbound -LocalPort 443, 4244, 80, 4248, 4242, 4432, 4444, 5355, 5353 -Protocol TCP -Action Allow

# create Shared Persistence XML
@"
<?xml version="1.0"?>
<SharedPersistenceConfiguration xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <DbUserName>qliksenserepository</DbUserName>
  <DbUserPassword>$($dbPass)</DbUserPassword>
  <DbHost>$env:COMPUTERNAME</DbHost>
  <DbPort>4432</DbPort>
  <RootDir>\\$env:COMPUTERNAME\Qlik</RootDir>
  <StaticContentRootDir>\\$env:COMPUTERNAME\Qlik\StaticContent</StaticContentRootDir>
  <CustomDataRootDir>\\$env:COMPUTERNAME\Qlik\CustomData</CustomDataRootDir>
  <ArchivedLogsDir>\\$env:COMPUTERNAME\Qlik\ArchivedLogs</ArchivedLogsDir>
  <AppsDir>\\$env:COMPUTERNAME\Qlik\Apps</AppsDir>
  <CreateCluster>true</CreateCluster>
  <InstallLocalDb>true</InstallLocalDb>
  <ConfigureDbListener>true</ConfigureDbListener>
  <ListenAddresses>*</ListenAddresses>
  <IpRange>0.0.0.0/0</IpRange>
  <!--<JoinCluster>true</JoinCluster>-->
</SharedPersistenceConfiguration>
"@ | Out-File C:\installation\spConfig.xml

# install Qlik Sense
Write-Log -Message "Installing Qlik Sense"
If (Test-Path "C:\installation\Qlik_Sense_setup.exe") 
	{
		Unblock-File -Path C:\installation\Qlik_Sense_setup.exe
		Invoke-Command -ScriptBlock {Start-Process -FilePath "c:\installation\Qlik_Sense_setup.exe" -ArgumentList "-s -log c:\installation\logqlik.txt dbpassword=$($dbPass) hostname=$($env:COMPUTERNAME) userwithdomain=$serviceAccountWithDomain password=$($serviceAccountPass) spc=c:\installation\spConfig.xml" -Wait -PassThru}
	}
# wait for Qlik Sense to respond before continuing
$statusCode = 0
while ($StatusCode -ne 200) 
	{
		write-log -Message "StatusCode is $StatusCode" -Severity "Warn"
		try { $statusCode = (invoke-webrequest  https://$($env:COMPUTERNAME)/qps/user -usebasicParsing).statusCode }
		Catch 
			{ 
				Write-Log -Message "Server down, waiting 20 seconds" -Severity "Warn"
				start-Sleep -s 20
			}
	}
#install Qlik Sense Update
If (Test-Path "c:\installation\Qlik_Sense_update.exe")
	{
		Write-Log -Message "Installing Patch"
        Unblock-File -Path c:\installation\Qlik_Sense_update.exe
		Invoke-Command -ScriptBlock {Start-Process -FilePath "c:\installation\Qlik_Sense_Update.exe" -ArgumentList "install" -Wait -Passthru }
		Get-Service Qlik* | where {$_.Name -ne 'QlikLoggingService'} | Start-Service
		Get-Service Qlik* | where {$_.Name -eq 'QlikSenseServiceDispatcher'} | Stop-Service
		Get-Service Qlik* | where {$_.Name -eq 'QlikSenseServiceDispatcher'} | Start-Service
	}


If (! ( $qlikSenseSerial -eq "defaultValue" ) -or $qlikSenseSerial -eq "") {
$statusCode = 0
    while ($StatusCode -ne 200) 
    {
        write-log "StatusCode is $StatusCode" -Severity "Warn"
        try { $statusCode = (invoke-webrequest  https://$($env:COMPUTERNAME)/qps/user -usebasicParsing).statusCode }
        Catch 
            { 
                Write-Log "Server down, waiting for 20 seconds" -Severity "Warn"
                start-Sleep -s 20
            }
    }
    Write-Log -Message "Connecting to Qlik Sense Repository Service on $env:COMPUTERNAME"
    Write-Log -Message "$($connectResult)"
    $connectResult = Connect-Qlik $env:COMPUTERNAME -UseDefaultCredentials
    Write-Log -Message "Applying Qlik Sense licence $qlikSenseSerial" 
    $licenseResult = Set-QlikLicense -serial $qlikSenseSerial -control $qlikSenseControl -name "$($qlikSenseName)" -organization "$($qlikSenseOrganization)"
    Write-Log -Message "$($licenseResult)"
}
Write-Log "Server provisioning complete"