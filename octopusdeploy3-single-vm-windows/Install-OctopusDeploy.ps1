param (
  [string] $SqlDbConnectionString,
  [string] $LicenseFullName,
  [string] $LicenseOrganisationName,
  [string] $LicenseEmailAddress,
  [string] $OctopusAdminUsername,
  [string] $OctopusAdminPassword
)

$config = @{}
$octopusDeployVersion = "Octopus.3.0.12.2366-x64"
$msiFileName = "Octopus.3.0.12.2366-x64.msi"
$downloadBaseUrl = "https://download.octopusdeploy.com/octopus/"
$downloadUrl = $downloadBaseUrl + $msiFileName
$installBasePath = "D:\Install\"
$msiPath = $installBasePath + $msiFileName
$msiLogPath = $installBasePath + $msiFileName + '.log'
$installerLogPath = $installBasePath + 'Install-OctopusDeploy.ps1.log'
$octopusLicenseUrl = "https://octopusdeploy.com/api/licenses/trial"
$OFS = "`r`n"

function Write-Log
{
  param (
    [string] $message
  )
  
  $timestamp = ([System.DateTime]::UTCNow).ToString("yyyy'-'MM'-'dd'T'HH':'mm':'ss")
  Write-Output "[$timestamp] $message"
}

function Write-CommandOutput 
{
  param (
    [string] $output
  )    
  
  if ($output -eq "") { return }
  
  Write-Output ""
  $output.Trim().Split("`n") |% { Write-Output "`t| $($_.Trim())" }
  Write-Output ""
}

function Get-Config
{
  Write-Log "======================================"
  Write-Log " Get Config"
  Write-Log ""    
  Write-Log "Parsing script parameters ..."
    
  $config.Add("sqlDbConnectionString", [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($SqlDbConnectionString)))
  $config.Add("licenseFullName", [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($LicenseFullName)))
  $config.Add("licenseOrganisationName", [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($LicenseOrganisationName)))
  $config.Add("licenseEmailAddress", [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($LicenseEmailAddress)))
  $config.Add("octopusAdminUsername", [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($OctopusAdminUsername)))
  $config.Add("octopusAdminPassword", [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($OctopusAdminPassword)))
  
  Write-Log "done."
  Write-Log ""
}

function Create-InstallLocation
{
  Write-Log "======================================"
  Write-Log " Create Install Location"
  Write-Log ""
    
  if (!(Test-Path $installBasePath))
  {
    Write-Log "Creating installation folder at '$installBasePath' ..."
    New-Item -ItemType Directory -Path $installBasePath | Out-Null
    Write-Log "done."
  }
  else
  {
    Write-Log "Installation folder at '$installBasePath' already exists."
  }
  
  Write-Log ""
}

function Install-OctopusDeploy
{
  Write-Log "======================================"
  Write-Log " Install Octopus Deploy"
  Write-Log ""
    
  Write-Log "Downloading Octopus Deploy installer '$downloadUrl' to '$msiPath' ..."
  (New-Object Net.WebClient).DownloadFile($downloadUrl, $msiPath)
  Write-Log "done."
  
  Write-Log "Installing via '$msiPath' ..."
  $exe = 'msiexec.exe'
  $args = @(
    '/qn', 
    '/i', $msiPath, 
    '/l*v', $msiLogPath
  )
  $output = .$exe $args
  Write-CommandOutput $output
  Write-Log "done."
    
  Write-Log ""
}

function Configure-OctopusDeploy
{
  Write-Log "======================================"
  Write-Log " Configure Octopus Deploy"
  Write-Log ""
    
  $exe = 'C:\Program Files\Octopus Deploy\Octopus\Octopus.Server.exe'
    
  $count = 0
  while(!(Test-Path $exe) -and $count -lt 5)
  {
    Write-Log "$exe - not available yet ... waiting 10s ..."
    Start-Sleep -s 10
    $count = $count + 1
  }
    
  Write-Log "Creating Octopus Deploy instance ..."
  $args = @(
    'create-instance', 
    '--console', 
    '--instance', 'OctopusServer', 
    '--config', 'C:\Octopus\OctopusServer.config'     
  )
  $output = .$exe $args
  Write-CommandOutput $output
  Write-Log "done."
  
  Write-Log "Configuring Octopus Deploy instance ..."
  $args = @(
    'configure', 
    '--console',
    '--instance', 'OctopusServer', 
    '--home', 'C:\Octopus', 
    '--storageConnectionString', $($config.sqlDbConnectionString), 
    '--upgradeCheck', 'True', 
    '--upgradeCheckWithStatistics', 'True', 
    '--webAuthenticationMode', 'UsernamePassword', 
    '--webForceSSL', 'False', 
    '--webListenPrefixes', 'http://localhost:80/', 
    '--commsListenPort', '10943'     
  )
  $output = .$exe $args
  Write-CommandOutput $output
  Write-Log "done."
    
  Write-Log "Creating Octopus Deploy database ..."
  $args = @(
    'database', 
    '--console',
    '--instance', 'OctopusServer', 
    '--create'
  )
  $output = .$exe $args
  Write-CommandOutput $output
  Write-Log "done."
    
  Write-Log "Stopping Octopus Deploy instance ..."
  $args = @(
    'service', 
    '--console',
    '--instance', 'OctopusServer', 
    '--stop'
  )
  $output = .$exe $args
  Write-CommandOutput $output
  Write-Log "done."
    
  Write-Log "Creating Admin User for Octopus Deploy instance ..."
  $args = @(
    'admin', 
    '--console',
    '--instance', 'OctopusServer', 
    '--username', $($config.octopusAdminUserName), 
    '--password', $($config.octopusAdminPassword)
  )
  $output = .$exe $args
  Write-CommandOutput $output
  Write-Log "done."  

  Write-Log "Obtaining a trial license for Full Name: $($config.licenseFullName), Organisation Name: $($config.licenseOrganisationName), Email Address: $($config.licenseEmailAddress) ..."
  $postParams = @{ FullName="$($config.licenseFullName)";Organization="$($config.licenseOrganisationName)";EmailAddress="$($config.licenseEmailAddress)" }
  $response = Invoke-WebRequest -UseBasicParsing -Uri "$octopusLicenseUrl" -Method POST -Body $postParams
  $utf8NoBOM = New-Object System.Text.UTF8Encoding($false)
  $bytes  = $utf8NoBOM.GetBytes($response.Content)
  $licenseBase64 = [System.Convert]::ToBase64String($bytes)
  Write-Log "done."
    
  Write-Log "Installing license for Octopus Deploy instance ..."
  $args = @(
    'license', 
    '--console',
    '--instance', 'OctopusServer', 
    '--licenseBase64', $licenseBase64
  )
  $output = .$exe $args
  Write-CommandOutput $output
  Write-Log "done."
    
  Write-Log "Reconfigure and start Octopus Deploy instance ..."
  $args = @(
    'service',
    '--console', 
    '--instance', 'OctopusServer', 
    '--install', 
    '--reconfigure', 
    '--start'
  )
  $output = .$exe $args
  Write-CommandOutput $output
  Write-Log "done."
    
  Write-Log ""
} 

function Configure-Firewall
{
  Write-Log "======================================"
  Write-Log " Configure Firewall"
  Write-Log ""
    
  $firewallRuleName = "Allow_Port80_HTTP"
    
  if ((Get-NetFirewallRule -Name $firewallRuleName -ErrorAction Ignore) -eq $null)
  {
    Write-Log "Creating firewall rule to allow port 80 HTTP traffic ..."
    $firewallRule = @{
      Name=$firewallRuleName
      DisplayName ="Allow Port 80 (HTTP)"
      Description="Port 80 for HTTP traffic"
      Direction='Inbound'
      Protocol='TCP'
      LocalPort=80
      Enabled='True'
      Profile='Any'
      Action='Allow'
    }
    $output = (New-NetFirewallRule @firewallRule | Out-String)
    Write-CommandOutput $output
    Write-Log "done."
  }
  else
  {
    Write-Log "Firewall rule to allow port 80 HTTP traffic already exists."
  }
  
  Write-Log ""
}

try
{
  Write-Log "======================================"
  Write-Log " Installing '$octopusDeployVersion'"
  Write-Log "======================================"
  Write-Log ""
  
  Get-Config
  Create-InstallLocation
  Install-OctopusDeploy
  Configure-OctopusDeploy
  Configure-Firewall
  
  Write-Log "Installation successful."
  Write-Log ""
}
catch
{
  Write-Log $_
}
