Write-Host "Starting script to apply Azure baseline to Windows"

# Set TLS client version for GitHub downloads
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

# Create GuestConfig folder
$gcFolder = New-Item -Path 'c:\ProgramData\' -Name 'GuestConfig' -ItemType 'Directory'

# Resolve latest details about PowerShell releases
$pwshLatestAssets = Invoke-RestMethod (Invoke-RestMethod https://api.github.com/repos/PowerShell/PowerShell/releases/latest).assets_url
$pwshDownloadUrl = ($pwshLatestAssets | Where-Object { $_.browser_download_url -like "*win-x64.zip" }).browser_download_url
$pwshZipFileName = $pwshDownloadUrl.split('/')[-1]

# Download latest stable release of PowerShell
Write-Host "Downloading PowerShell stand-alone binaries"
$pwshZipDownloadPath = Join-Path -Path $gcFolder -ChildPath $pwshZipFileName
$invokeWebParams = @{
    Uri     = $pwshDownloadUrl
    OutFile = $pwshZipDownloadPath
}
Invoke-WebRequest @invokeWebParams

# Extract zip file containing latest version of PowerShell
Write-Host "Extracting PowerShell package"
$ZipDestinationPath = Join-Path -Path $gcFolder -ChildPath $pwshZipFileName.replace('.zip', '')
Expand-Archive -Path $pwshZipDownloadPath -DestinationPath $ZipDestinationPath
$pwshExePath = Join-Path -Path (Join-Path -Path $gcFolder -ChildPath $pwshZipFileName.replace('.zip', '')) -ChildPath 'pwsh.exe'

# Save GuestConfiguration module
Write-Host "Saving GuestConfiguration module"
$modulesFolder = New-Item -Path 'c:\ProgramData\GuestConfig' -Name 'modules' -ItemType 'Directory'
Install-PackageProvider -Name "NuGet" -Scope CurrentUser -Force
Save-Module -Name GuestConfiguration -path $modulesFolder

# Workaround: until GC supports applying modules authored as audit type (with warning)
[scriptblock] $gcModuleDetails = {
    $env:PSModulePath += ';c:\ProgramData\GuestConfig\modules'
    Import-Module 'GuestConfiguration'
    Get-Module 'GuestConfiguration'
}
$gcModule = & $pwshExePath -Command $gcModuleDetails
$gcModulePath = Join-Path -Path $gcModule.ModuleBase -ChildPath $gcModule.RootModule
(Get-Content -Path $gcModulePath).replace('metaConfig.Type', 'true') | Set-Content -Path $gcModulePath

# Start guest config remediation
Write-Host "Applying Azure baseline"
[scriptblock] $remediation = {
    $env:PSModulePath += ';c:\ProgramData\GuestConfig\modules'
    Import-Module 'GuestConfiguration'
    <# Future
    $Parameter = @(
        @{
            ResourceType          = ''
            ResourceId            = 'User Account Control: Admin Approval Mode for the Built-in Administrator account'
            ResourcePropertyName  = 'ExpectedValue'
            ResourcePropertyValue = '0'
        },
        @{
            ResourceType          = ''
            ResourceId            = 'User Account Control: Admin Approval Mode for the Built-in Administrator account'
            ResourcePropertyName  = 'RemediateValue'
            ResourcePropertyValue = '0'
        }
    ) #>
    Start-GuestConfigurationPackageRemediation -Path 'https://oaasguestconfigwcuss1.blob.core.windows.net/builtinconfig/AzureWindowsBaseline/AzureWindowsBaseline_1.2.0.0.zip' # -Parameter $Parameter

    # Workaround: until GC module supports parameters for native code resources
    Start-GuestConfigurationPackageRemediation -Path 'https://oaasguestconfigeaps1.blob.core.windows.net/builtinconfig/FilterAdministratorToken/FilterAdministratorToken_1.10.0.0.zip'
}
& $pwshExePath -Command $remediation

# Workaround: allow admin WinRM connections from Packer but correct the setting on first boot
# Create Scheduled Task to add FilterAdministratorToken first system boot, xml here-string
$command = @'
Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name FilterAdministratorToken -Value 1 -Type DWord;
$schedServiceCom = New-Object -ComObject "Schedule.Service";
$schedServiceCom.Connect();
$rootTaskFolder = $schedServiceCom.GetFolder('\');
$rootTaskFolder.DeleteTask('FilterAdministratorTokenEnablement', 0)
'@
$encodedCommand = [convert]::ToBase64String([System.Text.encoding]::Unicode.GetBytes($command))
$taskDefinition = @'
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <URI>\FilterAdministratorTokenEnablement</URI>
  </RegistrationInfo>
  <Triggers>
    <BootTrigger>
      <Enabled>true</Enabled>
    </BootTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>false</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>false</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <DisallowStartOnRemoteAppSession>false</DisallowStartOnRemoteAppSession>
    <UseUnifiedSchedulingEngine>true</UseUnifiedSchedulingEngine>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT1H</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>C:\Windows\System32\cmd.exe</Command>
      <Arguments>/c PowerShell -ExecutionPolicy Bypass -OutputFormat Text -EncodedCommand #REPLACE</Arguments>
    </Exec>
  </Actions>
</Task>
'@ -replace '#REPLACE',$encodedCommand

$schedServiceCom = New-Object -ComObject "Schedule.Service"
$schedServiceCom.Connect()
$filterAdminTokenTask = $schedServiceCom.NewTask($null)
$filterAdminTokenTask.XmlText = $taskDefinition
$rootTaskFolder = $schedServiceCom.GetFolder('\')
[void] $rootTaskFolder.RegisterTaskDefinition('FilterAdministratorTokenEnablement', $filterAdminTokenTask, 6, 'SYSTEM', $null, 1, $null)

# Cleanup
Remove-Item -Path 'c:\ProgramData\GuestConfig' -Recurse -Force
Remove-Item -Path $env:LOCALAPPDATA\PackageManagement\ProviderAssemblies\NuGet -Recurse -Force
