<# Qlik Sense Installation #>

# variables
$adminUser = $Args[0]
$adminPass = $Args[1]
$serviceAccountUser = $Args[2]
$serviceAccountPass = $Args[3]
$dbPass = $Args[4]
$qlikSenseVersion = $($Args[5])
$qlikSenseCentralNode = $($Args[6])
$serviceAccountWithDomain = -join ($($env:ComputerName), '\',$($Args[2]))

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

# Opening Firewall ports 443/4244, 80/4248, 4242, 4432, 4444, 5355, 5353
Write-Log -Message "Opening firewall ports 443, 4244, 80, 4248, 4242, 4432, 4444, 5355, 5353"
New-NetFirewallRule -DisplayName "Qlik Sense" -Direction Inbound -LocalPort 443, 4244, 80, 4248, 4242, 4432, 4444, 5355, 5353 -Protocol TCP -Action Allow

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

# create Shared Persistence XML
@"
<?xml version="1.0"?>
<SharedPersistenceConfiguration xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <DbUserName>qliksenserepository</DbUserName>
  <DbUserPassword>$($dbPass)</DbUserPassword>
  <DbHost>$qlikSenseCentralNode</DbHost>
  <DbPort>4432</DbPort>
  <RootDir>\\$qlikSenseCentralNode\Qlik</RootDir>
  <StaticContentRootDir>\\$qlikSenseCentralNode\Qlik\StaticContent</StaticContentRootDir>
  <CustomDataRootDir>\\$qlikSenseCentralNode\Qlik\CustomData</CustomDataRootDir>
  <ArchivedLogsDir>\\$qlikSenseCentralNode\Qlik\ArchivedLogs</ArchivedLogsDir>
  <AppsDir>\\$qlikSenseCentralNode\Qlik\Apps</AppsDir>
  <!--<CreateCluster>true</CreateCluster> -->
  <InstallLocalDb>false</InstallLocalDb>
  <JoinCluster>true</JoinCluster>
</SharedPersistenceConfiguration>
"@ | Out-File C:\installation\spConfig.xml

Write-Log -Message "Installing Chocolatey package manager"
powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))"

Write-Log -Message "Installing PSExec"
c:\programdata\chocolatey\bin\cinst psexec -y > c:\installation\InstallPSexec.txt 2>&1

# install Qlik Sense
If (Test-Path "C:\installation\Qlik_Sense_setup.exe") 
	{
		Write-Log -Message "Installing Qlik Sense"
        Unblock-File -Path C:\installation\Qlik_Sense_setup.exe
		Invoke-Command -ScriptBlock {Start-Process -FilePath "c:\installation\Qlik_Sense_setup.exe" -ArgumentList "-s -log c:\installation\logqlik.txt dbpassword=$($dbPass) hostname=$($env:COMPUTERNAME) userwithdomain=$serviceAccountWithDomain password=$($serviceAccountPass) spc=c:\installation\spConfig.xml" -Wait -PassThru}
	}

# install Qlik Sense Update
If (Test-Path "c:\installation\Qlik_Sense_update.exe")
	{
		Write-Log -Message "Installing Patch"
        Unblock-File -Path c:\installation\Qlik_Sense_update.exe
		Invoke-Command -ScriptBlock {Start-Process -FilePath "c:\installation\Qlik_Sense_Update.exe" -ArgumentList "install" -Wait -Passthru }
		Get-Service Qlik* | where {$_.Name -ne 'QlikLoggingService'} | Start-Service
		Get-Service Qlik* | where {$_.Name -eq 'QlikSenseServiceDispatcher'} | Stop-Service
		Get-Service Qlik* | where {$_.Name -eq 'QlikSenseServiceDispatcher'} | Start-Service
	}

start-sleep 30

# PSExec allows elevation which stops the script from connecting to the central node
Write-Log -Message "Connecting to Qlik Sense on $qlikSenseCentralNode"
$hostNameRim = $env:COMPUTERNAME
c:\programdata\chocolatey\bin\psexec.exe -h -u $env:COMPUTERNAME\$adminUser -p $adminPass /accepteula cmd /c "powershell -command Connect-Qlik $($qlikSenseCentralNode) -TrustAllCerts -UseDefaultCredentials; register-qliknode -hostname $hostNameRim -name Rim -nodePurpose 2 -engineEnabled -proxyEnabled" >c:\installation\registerQlik.txt 2>&1

Write-Log "Server provisioning complete"