param (
    [switch]$DontPromptPasswordUpdateGPU
    )
    

$host.ui.RawUI.WindowTitle = "Parsec Cloud Preparation Tool"

[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls" 

$logsfolder = "C:\logs"
$logoutput = $logsfolder + '\setup-output-' + (get-date).ToString('MMddyyhhmmss') + '.txt'
New-Item -Path $logsfolder -ItemType directory -Force

Function ProgressWriter {
    param (
    [int]$percentcomplete,
    [string]$status
    )
    $output = "$MessageTime - $percentcomplete - $status"
    Write-Progress -Activity "Setting Up Your Machine" -Status $status -PercentComplete $PercentComplete
    Add-Content -Path $logoutput -Value $output
}

#$path = [Environment]::GetFolderPath("Desktop")
$path = "C:"
# $currentusersid = Get-LocalUser "$env:USERNAME" | Select-Object SID | ft -HideTableHeaders | Out-String | ForEach-Object { $_.Trim() }

#Creating Folders and moving script files into System directories
function setupEnvironment {
    ProgressWriter -Status "Moving files and folders into place" -PercentComplete $PercentComplete
    if((Test-Path -Path C:\Windows\system32\GroupPolicy\Machine\Scripts\Startup) -eq $true) {} Else {New-Item -Path C:\Windows\system32\GroupPolicy\Machine\Scripts\Startup -ItemType directory | Out-Null}
    if((Test-Path -Path C:\Windows\system32\GroupPolicy\Machine\Scripts\Shutdown) -eq $true) {} Else {New-Item -Path C:\Windows\system32\GroupPolicy\Machine\Scripts\Shutdown -ItemType directory | Out-Null}
    if((Test-Path -Path $env:ProgramData\ParsecLoader) -eq $true) {} Else {New-Item -Path $env:ProgramData\ParsecLoader -ItemType directory | Out-Null}
    if((Test-Path C:\Windows\system32\GroupPolicy\Machine\Scripts\psscripts.ini) -eq $true) {} Else {Move-Item -Path $path\ParsecTemp\PreInstall\psscripts.ini -Destination C:\Windows\system32\GroupPolicy\Machine\Scripts}
    if((Test-Path C:\Windows\system32\GroupPolicy\Machine\Scripts\Shutdown\NetworkRestore.ps1) -eq $true) {} Else {Move-Item -Path $path\ParsecTemp\PreInstall\NetworkRestore.ps1 -Destination C:\Windows\system32\GroupPolicy\Machine\Scripts\Shutdown} 
    if((Test-Path $env:ProgramData\ParsecLoader\clear-proxy.ps1) -eq $true) {} Else {Move-Item -Path $path\ParsecTemp\PreInstall\clear-proxy.ps1 -Destination $env:ProgramData\ParsecLoader}
    if((Test-Path $env:ProgramData\ParsecLoader\CreateClearProxyScheduledTask.ps1) -eq $true) {} Else {Move-Item -Path $path\ParsecTemp\PreInstall\CreateClearProxyScheduledTask.ps1 -Destination $env:ProgramData\ParsecLoader}
    if((Test-Path $env:ProgramData\ParsecLoader\Automatic-Shutdown.ps1) -eq $true) {} Else {Move-Item -Path $path\ParsecTemp\PreInstall\Automatic-Shutdown.ps1 -Destination $env:ProgramData\ParsecLoader}
    if((Test-Path $env:ProgramData\ParsecLoader\CreateAutomaticShutdownScheduledTask.ps1) -eq $true) {} Else {Move-Item -Path $path\ParsecTemp\PreInstall\CreateAutomaticShutdownScheduledTask.ps1 -Destination $env:ProgramData\ParsecLoader}
    if((Test-Path $env:ProgramData\ParsecLoader\GPU-Update.ico) -eq $true) {} Else {Move-Item -Path $path\ParsecTemp\PreInstall\GPU-Update.ico -Destination $env:ProgramData\ParsecLoader}
    if((Test-Path $env:ProgramData\ParsecLoader\CreateOneHourWarningScheduledTask.ps1) -eq $true) {} Else {Move-Item -Path $path\ParsecTemp\PreInstall\CreateOneHourWarningScheduledTask.ps1 -Destination $env:ProgramData\ParsecLoader}
    if((Test-Path $env:ProgramData\ParsecLoader\WarningMessage.ps1) -eq $true) {} Else {Move-Item -Path $path\ParsecTemp\PreInstall\WarningMessage.ps1 -Destination $env:ProgramData\ParsecLoader}
    if((Test-Path $env:ProgramData\ParsecLoader\Parsec.png) -eq $true) {} Else {Move-Item -Path $path\ParsecTemp\PreInstall\Parsec.png -Destination $env:ProgramData\ParsecLoader}
    if((Test-Path $env:ProgramData\ParsecLoader\ShowDialog.ps1) -eq $true) {} Else {Move-Item -Path $path\ParsecTemp\PreInstall\ShowDialog.ps1 -Destination $env:ProgramData\ParsecLoader}
    if((Test-Path $env:ProgramData\ParsecLoader\OneHour.ps1) -eq $true) {} Else {Move-Item -Path $path\ParsecTemp\PreInstall\OneHour.ps1 -Destination $env:ProgramData\ParsecLoader}
    if((Test-Path $env:ProgramData\ParsecLoader\TeamMachineSetup.ps1) -eq $true) {} Else {Move-Item -Path $path\ParsecTemp\PreInstall\TeamMachineSetup.ps1 -Destination $env:ProgramData\ParsecLoader}
    }

function cloudprovider { 
    #finds the cloud provider that this VM is hosted by
    $gcp = $(
                try {
                    (Invoke-WebRequest -uri http://metadata.google.internal/computeMetadata/v1/ -Method GET -header @{'metadata-flavor'='Google'} -TimeoutSec 5)
                    }
                catch {
                    }
             )

    $aws = $(
                Try {
                    (Invoke-WebRequest -uri http://169.254.169.254/latest/meta-data/ -TimeoutSec 5)
                    }
                catch {
                    }
             )

    $paperspace = $(
                        Try {
                            (Invoke-WebRequest -uri http://metadata.paperspace.com/meta-data/machine -TimeoutSec 5)
                            }
                        catch {
                            }
                    )

    $azure = $(
                  Try {(Invoke-WebRequest -Uri "http://169.254.169.254/metadata/instance?api-version=2018-10-01" -Headers @{Metadata="true"} -TimeoutSec 5)}
                  catch {}              
               )


    if ($GCP.StatusCode -eq 200) {
        "Google Cloud Instance"
        } 
    Elseif ($AWS.StatusCode -eq 200) {
        "Amazon AWS Instance"
        } 
    Elseif ($paperspace.StatusCode -eq 200) {
        "Paperspace Instance"
        }
    Elseif ($azure.StatusCode -eq 200) {
        "Microsoft Azure Instance"
        }
    Else {
        "Generic Instance"
        }
}


add-type  @"
        using System;
        using System.Collections.Generic;
        using System.Text;
        using System.Runtime.InteropServices;
 
        namespace ComputerSystem
        {
            public class LSAutil
            {
                [StructLayout(LayoutKind.Sequential)]
                private struct LSA_UNICODE_STRING
                {
                    public UInt16 Length;
                    public UInt16 MaximumLength;
                    public IntPtr Buffer;
                }
 
                [StructLayout(LayoutKind.Sequential)]
                private struct LSA_OBJECT_ATTRIBUTES
                {
                    public int Length;
                    public IntPtr RootDirectory;
                    public LSA_UNICODE_STRING ObjectName;
                    public uint Attributes;
                    public IntPtr SecurityDescriptor;
                    public IntPtr SecurityQualityOfService;
                }
 
                private enum LSA_AccessPolicy : long
                {
                    POLICY_VIEW_LOCAL_INFORMATION = 0x00000001L,
                    POLICY_VIEW_AUDIT_INFORMATION = 0x00000002L,
                    POLICY_GET_PRIVATE_INFORMATION = 0x00000004L,
                    POLICY_TRUST_ADMIN = 0x00000008L,
                    POLICY_CREATE_ACCOUNT = 0x00000010L,
                    POLICY_CREATE_SECRET = 0x00000020L,
                    POLICY_CREATE_PRIVILEGE = 0x00000040L,
                    POLICY_SET_DEFAULT_QUOTA_LIMITS = 0x00000080L,
                    POLICY_SET_AUDIT_REQUIREMENTS = 0x00000100L,
                    POLICY_AUDIT_LOG_ADMIN = 0x00000200L,
                    POLICY_SERVER_ADMIN = 0x00000400L,
                    POLICY_LOOKUP_NAMES = 0x00000800L,
                    POLICY_NOTIFICATION = 0x00001000L
                }
 
                [DllImport("advapi32.dll", SetLastError = true, PreserveSig = true)]
                private static extern uint LsaRetrievePrivateData(
                            IntPtr PolicyHandle,
                            ref LSA_UNICODE_STRING KeyName,
                            out IntPtr PrivateData
                );
 
                [DllImport("advapi32.dll", SetLastError = true, PreserveSig = true)]
                private static extern uint LsaStorePrivateData(
                        IntPtr policyHandle,
                        ref LSA_UNICODE_STRING KeyName,
                        ref LSA_UNICODE_STRING PrivateData
                );
 
                [DllImport("advapi32.dll", SetLastError = true, PreserveSig = true)]
                private static extern uint LsaOpenPolicy(
                    ref LSA_UNICODE_STRING SystemName,
                    ref LSA_OBJECT_ATTRIBUTES ObjectAttributes,
                    uint DesiredAccess,
                    out IntPtr PolicyHandle
                );
 
                [DllImport("advapi32.dll", SetLastError = true, PreserveSig = true)]
                private static extern uint LsaNtStatusToWinError(
                    uint status
                );
 
                [DllImport("advapi32.dll", SetLastError = true, PreserveSig = true)]
                private static extern uint LsaClose(
                    IntPtr policyHandle
                );
 
                [DllImport("advapi32.dll", SetLastError = true, PreserveSig = true)]
                private static extern uint LsaFreeMemory(
                    IntPtr buffer
                );
 
                private LSA_OBJECT_ATTRIBUTES objectAttributes;
                private LSA_UNICODE_STRING localsystem;
                private LSA_UNICODE_STRING secretName;
 
                public LSAutil(string key)
                {
                    if (key.Length == 0)
                    {
                        throw new Exception("Key lenght zero");
                    }
 
                    objectAttributes = new LSA_OBJECT_ATTRIBUTES();
                    objectAttributes.Length = 0;
                    objectAttributes.RootDirectory = IntPtr.Zero;
                    objectAttributes.Attributes = 0;
                    objectAttributes.SecurityDescriptor = IntPtr.Zero;
                    objectAttributes.SecurityQualityOfService = IntPtr.Zero;
 
                    localsystem = new LSA_UNICODE_STRING();
                    localsystem.Buffer = IntPtr.Zero;
                    localsystem.Length = 0;
                    localsystem.MaximumLength = 0;
 
                    secretName = new LSA_UNICODE_STRING();
                    secretName.Buffer = Marshal.StringToHGlobalUni(key);
                    secretName.Length = (UInt16)(key.Length * UnicodeEncoding.CharSize);
                    secretName.MaximumLength = (UInt16)((key.Length + 1) * UnicodeEncoding.CharSize);
                }
 
                private IntPtr GetLsaPolicy(LSA_AccessPolicy access)
                {
                    IntPtr LsaPolicyHandle;
 
                    uint ntsResult = LsaOpenPolicy(ref this.localsystem, ref this.objectAttributes, (uint)access, out LsaPolicyHandle);
 
                    uint winErrorCode = LsaNtStatusToWinError(ntsResult);
                    if (winErrorCode != 0)
                    {
                        throw new Exception("LsaOpenPolicy failed: " + winErrorCode);
                    }
 
                    return LsaPolicyHandle;
                }
 
                private static void ReleaseLsaPolicy(IntPtr LsaPolicyHandle)
                {
                    uint ntsResult = LsaClose(LsaPolicyHandle);
                    uint winErrorCode = LsaNtStatusToWinError(ntsResult);
                    if (winErrorCode != 0)
                    {
                        throw new Exception("LsaClose failed: " + winErrorCode);
                    }
                }
 
                public void SetSecret(string value)
                {
                    LSA_UNICODE_STRING lusSecretData = new LSA_UNICODE_STRING();
 
                    if (value.Length > 0)
                    {
                        //Create data and key
                        lusSecretData.Buffer = Marshal.StringToHGlobalUni(value);
                        lusSecretData.Length = (UInt16)(value.Length * UnicodeEncoding.CharSize);
                        lusSecretData.MaximumLength = (UInt16)((value.Length + 1) * UnicodeEncoding.CharSize);
                    }
                    else
                    {
                        //Delete data and key
                        lusSecretData.Buffer = IntPtr.Zero;
                        lusSecretData.Length = 0;
                        lusSecretData.MaximumLength = 0;
                    }
 
                    IntPtr LsaPolicyHandle = GetLsaPolicy(LSA_AccessPolicy.POLICY_CREATE_SECRET);
                    uint result = LsaStorePrivateData(LsaPolicyHandle, ref secretName, ref lusSecretData);
                    ReleaseLsaPolicy(LsaPolicyHandle);
 
                    uint winErrorCode = LsaNtStatusToWinError(result);
                    if (winErrorCode != 0)
                    {
                        throw new Exception("StorePrivateData failed: " + winErrorCode);
                    }
                }
            }
        }
"@

Function TestCredential {
    param
    (
        [PSCredential]$Credential
    )
    try {
        Start-Process -FilePath cmd.exe /c -Credential ($Credential)
        }
    Catch {
        If ($Error[0].Exception.Message) {
        $Error[0].Exception.Message
        Throw
        }
        }
    }

function Set-AutoLogon {
    [CmdletBinding(SupportsShouldProcess)]
    param
    (
        [PSCredential]$Credential
    )
    Try {
        if ($Credential.GetNetworkCredential().Domain) {
            $DefaultDomainName = $Credential.GetNetworkCredential().Domain
            }
        elseif ((Get-WMIObject Win32_ComputerSystem).PartOfDomain) {
            $DefaultDomainName = "."
            }
        else {
            $DefaultDomainName = ""
            }

        if ($PSCmdlet.ShouldProcess(('User "{0}\{1}"' -f $DefaultDomainName, $Credential.GetNetworkCredential().Username), "Set Auto logon")) {
            Write-Verbose ('DomainName: {0} / UserName: {1}' -f $DefaultDomainName, $Credential.GetNetworkCredential().Username)
            Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name "AutoAdminLogon" -Value 1
            Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name "DefaultDomainName" -Value ""
            Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name "DefaultUserName" -Value $Credential.UserName
            Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name "AutoLogonCount" -ErrorAction SilentlyContinue
            Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name "DefaultPassword" -ErrorAction SilentlyContinue
            $private:LsaUtil = New-Object ComputerSystem.LSAutil -ArgumentList "DefaultPassword"
            $LsaUtil.SetSecret($Credential.GetNetworkCredential().Password)
            "Auto Logon Configured"
            Remove-Variable Credential
            }
    }
    Catch {
        $Error[0].Exception.Message
        Throw
        }
}


Function GetInstanceCredential {
    Try {
        $Credential = Get-Credential -Credential $null
        Try {
            TestCredential -Credential $Credential 
            }
        Catch {
                Remove-Variable Credential
                #$Error[0].Exception.Message
                "Retry?"
                $Retry = Read-Host "(Y/N)"
                Switch ($Retry){
                   Y {
                      GetInstanceCredential 
                       }
                   N {
                      Return
                       }
                    }
            }
        }
    Catch {
        if ($Credential) {Remove-Variable Credential}
        "You pressed cancel, retry?"
        $Cancel = Read-Host "(Y/N)"
        Switch ($Cancel){
            Y {
                GetInstanceCredential
                }
            N {
                Return
                }
            }
        }
    if($credential) {Set-AutoLogon -Credential $Credential}
    }
    
Function PromptUserAutoLogon {
param (
[switch]$DontPromptPasswordUpdateGPU
)
$CloudProvider = CloudProvider
    If ($DontPromptPasswordUpdateGPU) {
        }
    ElseIf ($CloudProvider -eq "Paperspace") {
    }
    Else {
        "Detected $CloudProvider"
        Write-Host @"
Do you want this computer to log on to Windows automatically? 
(Y): This is good when you want the cloud computer to boot straight to Parsec but is less secure as the computer will not be protected by a password at start up
(N): If you plan to log into Windows with RDP then connect via Parsec, or have been told you don't need to set this up
"@ -ForegroundColor Black -BackgroundColor Red
        $ReadHost = Read-Host "(Y/N)" 
        Switch ($ReadHost) 
            {
            Y {
                GetInstanceCredential
                }
            N {
                }
            }
        }
    }





#Modifies Local Group Policy to enable Shutdown scrips items
function add-gpo-modifications {
    $querygpt = Get-content C:\Windows\System32\GroupPolicy\gpt.ini
    $matchgpt = $querygpt -match '{42B5FAAE-6536-11D2-AE5A-0000F87571E3}{40B6664F-4972-11D1-A7CA-0000F87571E3}'
    if ($matchgpt -contains "*0000F87571E3*" -eq $false) {
        $gptstring = get-content C:\Windows\System32\GroupPolicy\gpt.ini
        $gpoversion = $gptstring -match "Version"
        $GPO = $gptstring -match "gPCMachineExtensionNames"
        $add = '[{42B5FAAE-6536-11D2-AE5A-0000F87571E3}{40B6664F-4972-11D1-A7CA-0000F87571E3}]'
        $replace = "$GPO" + "$add"
        (Get-Content "C:\Windows\System32\GroupPolicy\gpt.ini").Replace("$GPO","$replace") | Set-Content "C:\Windows\System32\GroupPolicy\gpt.ini"
        [int]$i = $gpoversion.trim("Version=") 
        [int]$n = $gpoversion.trim("Version=")
        $n +=2
        (Get-Content C:\Windows\System32\GroupPolicy\gpt.ini) -replace "Version=$i", "Version=$n" | Set-Content C:\Windows\System32\GroupPolicy\gpt.ini
        }
    else{
        write-output "Not Required"
        }
    }

#Adds Premade Group Policu Item if existing configuration doesn't exist
function addRegItems{
    ProgressWriter -Status "Adding Registry Items and Group Policy" -PercentComplete $PercentComplete
    if (Test-Path ("C:\Windows\system32\GroupPolicy" + "\gpt.ini")) {
        add-gpo-modifications
        }
    Else {
        Move-Item -Path $path\ParsecTemp\PreInstall\gpt.ini -Destination C:\Windows\system32\GroupPolicy -Force | Out-Null
        }
    regedit /s $path\ParsecTemp\PreInstall\NetworkRestore.reg
    regedit /s $path\ParsecTemp\PreInstall\ForceCloseShutDown.reg
    New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS -ErrorAction SilentlyContinue | Out-Null
    }

function Test-RegistryValue {
    # https://www.jonathanmedd.net/2014/02/testing-for-the-presence-of-a-registry-key-and-value.html
    param (

     [parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Path,

    [parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Value
    )

    try {
        Get-ItemProperty -Path $Path | Select-Object -ExpandProperty $Value -ErrorAction Stop | Out-Null
        return $true
        }
    catch {
        return $false
        }

}


#Create ParsecTemp folder in C Drive
function create-directories {
    ProgressWriter -Status "Creating Directories (C:\ParsecTemp)" -PercentComplete $PercentComplete
    if((Test-Path -Path C:\ParsecTemp) -eq $true) {} Else {New-Item -Path C:\ParsecTemp -ItemType directory | Out-Null}
    if((Test-Path -Path C:\ParsecTemp\Apps) -eq $true) {} Else {New-Item -Path C:\ParsecTemp\Apps -ItemType directory | Out-Null}
    if((Test-Path -Path C:\ParsecTemp\DirectX) -eq $true) {} Else {New-Item -Path C:\ParsecTemp\DirectX -ItemType directory | Out-Null}
    if((Test-Path -Path C:\ParsecTemp\Drivers) -eq $true) {} Else {New-Item -Path C:\ParsecTemp\Drivers -ItemType Directory | Out-Null}
    # if((Test-Path -Path C:\ParsecTemp\Devcon) -eq $true) {} Else {New-Item -Path C:\ParsecTemp\Devcon -ItemType Directory | Out-Null}
    }

    #Create ParsecTemp folder in C Drive
function prepare-parsec {
    ProgressWriter -Status "Creating Directories (C:\ParsecTemp)" -PercentComplete $PercentComplete
    Copy-Item ".\parsec" "C:\ParsecTemp\PreInstall"
    }

#disable IE security
function disable-iesecurity {
    ProgressWriter -Status "Disabling Internet Explorer security to enable web browsing" -PercentComplete $PercentComplete
    Set-Itemproperty "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}" -name IsInstalled -value 0 -force | Out-Null
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}" -Name IsInstalled -Value 0 -Force | Out-Null
    # Stop-Process -Name Explorer -Force
    }

#download-files-S3
function download-resources {
    $ProgressPreference = 'SilentlyContinue'

    #ProgressWriter -Status "Downloading DirectX June 2010 Redist" -PercentComplete $PercentComplete
    #Invoke-WebRequest -Uri "https://download.microsoft.com/download/8/4/A/84A35BF1-DAFE-4AE8-82AF-AD2AE20B6B14/directx_Jun2010_redist.exe" -OutFile "C:\ParsecTemp\Apps\directx_Jun2010_redist.exe"
    # ProgressWriter -Status "Downloading Devcon" -PercentComplete $PercentComplete
    # Invoke-WebRequest -Uri "https://s3.amazonaws.com/parsec-files-ami-setup/Devcon/devcon.exe" -OutFile "C:\ParsecTemp\Devcon\devcon.exe"
    ProgressWriter -Status "Downloading Parsec" -PercentComplete $PercentComplete
    Invoke-WebRequest -Uri "https://builds.parsecgaming.com/package/parsec-windows.exe" -OutFile "C:\ParsecTemp\Apps\parsec-windows.exe"
    ProgressWriter -Status "Downloading GPU Updater" -PercentComplete $PercentComplete
    Invoke-WebRequest -Uri "https://s3.amazonaws.com/parseccloud/image/parsec+desktop.png" -OutFile "C:\ParsecTemp\parsec+desktop.png"
    Invoke-WebRequest -Uri "https://s3.amazonaws.com/parseccloud/image/white_ico_agc_icon.ico" -OutFile "C:\ParsecTemp\white_ico_agc_icon.ico"
    #Invoke-WebRequest -Uri "https://raw.githubusercontent.com/parsec-cloud/Cloud-GPU-Updater/master/GPUUpdaterTool.ps1" -OutFile "$env:ProgramData\ParsecLoader\GPUUpdaterTool.ps1"
    #ProgressWriter -Status "Downloading Google Chrome" -PercentComplete $PercentComplete
    #Invoke-WebRequest -Uri "https://dl.google.com/tag/s/dl/chrome/install/googlechromestandaloneenterprise64.msi" -OutFile "C:\ParsecTemp\Apps\googlechromestandaloneenterprise64.msi"
    }

#install-base-files-silently
function install-windows-features {
    ProgressWriter -Status "Installing Chrome" -PercentComplete $PercentComplete
    start-process -filepath "C:\Windows\System32\msiexec.exe" -ArgumentList '/qn /i "C:\ParsecTemp\Apps\googlechromestandaloneenterprise64.msi"' -Wait
    ProgressWriter -Status "Installing DirectX June 2010 Redist" -PercentComplete $PercentComplete
    Start-Process -FilePath "C:\ParsecTemp\Apps\directx_jun2010_redist.exe" -ArgumentList '/T:C:\ParsecTemp\DirectX /Q'-wait
    Start-Process -FilePath "C:\ParsecTemp\DirectX\DXSETUP.EXE" -ArgumentList '/silent' -wait
    ProgressWriter -Status "Installing Direct Play" -PercentComplete $PercentComplete
    Install-WindowsFeature Direct-Play | Out-Null
    ProgressWriter -Status "Installing .net 3.5" -PercentComplete $PercentComplete
    Install-WindowsFeature Net-Framework-Core | Out-Null
    ProgressWriter -Status "Cleaning up" -PercentComplete $PercentComplete
    Remove-Item -Path C:\ParsecTemp\DirectX -force -Recurse 
    }

Function TeamMachineSetupScheduledTask {
$XML = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Description>Attempts to read instance userdata and set up as Team Machine at startup</Description>
    <URI>\Setup Team Machine</URI>
  </RegistrationInfo>
  <Triggers>
    <BootTrigger>
      <Enabled>true</Enabled>
    </BootTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>$(([System.Security.Principal.WindowsIdentity]::GetCurrent()).User.Value)</UserId>
      <LogonType>S4U</LogonType>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>true</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>false</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT72H</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe</Command>
      <Arguments>-file %programdata%\ParsecLoader\TeamMachineSetup.ps1</Arguments>
    </Exec>
  </Actions>
</Task>
"@

    try {
        Get-ScheduledTask -TaskName "Setup Team Machine" -ErrorAction Stop | Out-Null
        Unregister-ScheduledTask -TaskName "Setup Team Machine" -Confirm:$false
        }
    catch {}
    $action = New-ScheduledTaskAction -Execute 'C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe' -Argument '-file %programdata%\ParsecLoader\TeamMachineSetup.ps1'
    $trigger =  New-ScheduledTaskTrigger -AtStartup
    Register-ScheduledTask -XML $XML -TaskName "Setup Team Machine" | Out-Null
    }

#set update policy
function set-update-policy {
    ProgressWriter -Status "Disabling Windows Update" -PercentComplete $PercentComplete
    if((Test-RegistryValue -path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -value 'DoNotConnectToWindowsUpdateInternetLocations') -eq $true) {Set-itemproperty -path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate -Name "DoNotConnectToWindowsUpdateInternetLocations" -Value "1" | Out-Null} else {new-itemproperty -path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate -Name "DoNotConnectToWindowsUpdateInternetLocations" -Value "1" | Out-Null}
    if((Test-RegistryValue -path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -value 'UpdateServiceURLAlternative') -eq $true) {Set-itemproperty -path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate -Name "UpdateServiceURLAlternative" -Value "http://intentionally.disabled" | Out-Null} else {new-itemproperty -path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate -Name "UpdateServiceURLAlternative" -Value "http://intentionally.disabled" | Out-Null}
    if((Test-RegistryValue -path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -value 'WUServer') -eq $true) {Set-itemproperty -path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate -Name "WUServer" -Value "http://intentionally.disabled" | Out-Null} else {new-itemproperty -path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate -Name "WUServer" -Value "http://intentionally.disabled" | Out-Null}
    if((Test-RegistryValue -path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -value 'WUSatusServer') -eq $true) {Set-itemproperty -path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate -Name "WUSatusServer" -Value "http://intentionally.disabled" | Out-Null} else {new-itemproperty -path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate -Name "WUSatusServer" -Value "http://intentionally.disabled" | Out-Null}
    Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU -Name "AUOptions" -Value 1 | Out-Null
    if((Test-RegistryValue -path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -value 'UseWUServer') -eq $true) {Set-itemproperty -path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU -Name "UseWUServer" -Value 1 | Out-Null} else {new-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU -Name "UseWUServer" -Value 1 | Out-Null}
    }

#set automatic time and timezone
function set-time {
    ProgressWriter -Status "Setting computer time to automatic" -PercentComplete $PercentComplete
    Set-ItemProperty -path HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters -Name Type -Value NTP | Out-Null
    Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate -Name Start -Value 00000003 | Out-Null
    }

#disable new network window
function disable-network-window {
    ProgressWriter -Status "Disabling New Network Window" -PercentComplete $PercentComplete
    if((Test-RegistryValue -path HKLM:\SYSTEM\CurrentControlSet\Control\Network -Value NewNetworkWindowOff)-eq $true) {} Else {new-itemproperty -path HKLM:\SYSTEM\CurrentControlSet\Control\Network -name "NewNetworkWindowOff" | Out-Null}
    }

#Enable Pointer Precision 
function enhance-pointer-precision {
    ProgressWriter -Status "Enabling enchanced pointer precision" -PercentComplete $PercentComplete
    Set-Itemproperty -Path 'HKCU:\Control Panel\Mouse' -Name MouseSpeed -Value 1 | Out-Null
    }

#enable Mouse Keys
function enable-mousekeys {
    ProgressWriter -Status "Enabling mouse keys to assist with mouse cursor" -PercentComplete $PercentComplete
    set-Itemproperty -Path 'HKCU:\Control Panel\Accessibility\MouseKeys' -Name Flags -Value 63 | Out-Null
    }

#disable shutdown start menu
function remove-shutdown {
    Write-Output "Disabling Shutdown Option in Start Menu"
    New-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer -Name NoClose -Value 1 | Out-Null
    }

#Sets all applications to force close on shutdown
function force-close-apps {
    ProgressWriter -Status "Setting Windows not to stop shutdown if there are unsaved apps" -PercentComplete $PercentComplete
    if (((Get-Item -Path "HKCU:\Control Panel\Desktop").GetValue("AutoEndTasks") -ne $null) -eq $true) {
        Set-ItemProperty -path "HKCU:\Control Panel\Desktop" -Name "AutoEndTasks" -Value "1"
        }
    Else {
        New-ItemProperty -path "HKCU:\Control Panel\Desktop" -Name "AutoEndTasks" -Value "1"
        }
    }

#show hidden items
function show-hidden-items {
    ProgressWriter -Status "Showing hidden files in Windows Explorer" -PercentComplete $PercentComplete
    set-itemproperty -path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name Hidden -Value 1 | Out-Null
    }

#show file extensions
function show-file-extensions {
    ProgressWriter -Status "Showing file extensions in Windows Explorer" -PercentComplete $PercentComplete
    Set-itemproperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -name HideFileExt -Value 0 | Out-Null
    }

#disable logout start menu
function disable-logout {
    ProgressWriter -Status "Disabling log out button on start menu" -PercentComplete $PercentComplete
    if((Test-RegistryValue -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer -Value StartMenuLogOff )-eq $true) {Set-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer -Name StartMenuLogOff -Value 1 | Out-Null} Else {New-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer -Name StartMenuLogOff -Value 1 | Out-Null}
    }

#disable lock start menu
function disable-lock {
    ProgressWriter -Status "Disabling option to lock your Windows user profile" -PercentComplete $PercentComplete
    if((Test-Path -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System) -eq $true) {} Else {New-Item -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies -Name Software | Out-Null}
    if((Test-RegistryValue -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Value DisableLockWorkstation) -eq $true) {Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name DisableLockWorkstation -Value 1 | Out-Null } Else {New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name DisableLockWorkstation -Value 1 | Out-Null}
    }

#set wallpaper
function set-wallpaper {
    ProgressWriter -Status "Setting the Parsec logo as the computer wallpaper" -PercentComplete $PercentComplete
    New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies" -Name "System" | Out-Null
    New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name Wallpaper -PropertyType String -value "C:\ParsecTemp\parsec+desktop.png" | Out-Null
    New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name WallpaperStyle -PropertyType String -value 2 | Out-Null
    #Stop-Process -ProcessName explorer
    }

#disable recent start menu items
function disable-recent-start-menu {
    New-Item -path HKLM:\SOFTWARE\Policies\Microsoft\Windows -name Explorer
    New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer -PropertyType DWORD -Name HideRecentlyAddedApps -Value 1
    }

#createshortcut
function Create-AutoShutdown-Shortcut{
    ProgressWriter -Status "Creating auto shutdown shortcut" -PercentComplete $PercentComplete
    $Shell = New-Object -ComObject ("WScript.Shell")
    $ShortCut = $Shell.CreateShortcut("$env:PUBLIC\Desktop\Setup Auto Shutdown.lnk")
    $ShortCut.TargetPath="powershell.exe"
    $ShortCut.Arguments='-ExecutionPolicy Bypass -File "C:\ProgramData\ParsecLoader\CreateAutomaticShutdownScheduledTask.ps1"'
    $ShortCut.WorkingDirectory = "$env:ProgramData\ParsecLoader";
    $ShortCut.WindowStyle = 0;
    $ShortCut.Description = "ClearProxy shortcut";
    $ShortCut.Save()
    }

#createshortcut
function Create-One-Hour-Warning-Shortcut{
    ProgressWriter -Status "Creating one hour warning shortcut" -PercentComplete $PercentComplete
    $Shell = New-Object -ComObject ("WScript.Shell")
    $ShortCut = $Shell.CreateShortcut("$env:PUBLIC\Desktop\Setup One Hour Warning.lnk")
    $ShortCut.TargetPath="powershell.exe"
    $ShortCut.Arguments='-ExecutionPolicy Bypass -File "C:\ProgramData\ParsecLoader\CreateOneHourWarningScheduledTask.ps1"'
    $ShortCut.WorkingDirectory = "$env:ProgramData\ParsecLoader";
    $ShortCut.WindowStyle = 0;
    $ShortCut.Description = "OneHourWarning shortcut";
    $ShortCut.Save()
    }

#create shortcut for electron app
#function create-shortcut-app {
#    Copy-Item -Path $path\ParsecTemp\PostInstall\Parsec.lnk -Destination $path
#    }

#Disables Server Manager opening on Startup
function disable-server-manager {
    ProgressWriter -Status "Disabling Windows Server Manager from starting at startup" -PercentComplete $PercentComplete
    Get-ScheduledTask -TaskName ServerManager | Disable-ScheduledTask | Out-Null
    }

#AWS Clean up Desktop Items
function clean-aws {
    remove-item -path "$path\EC2 Feedback.Website"
    Remove-Item -Path "$path\EC2 Microsoft Windows Guide.website"
    }

#Move extracts Razer Surround Files into correct location
Function ExtractRazerAudio {
    cmd.exe /c '"C:\Program Files\7-Zip\7z.exe" x C:\ParsecTemp\Apps\razer-surround-driver.exe -oC:\ParsecTemp\Apps\razer-surround-driver -y' | Out-Null
    }

#modifys the installer manifest to run without interraction
Function ModidifyManifest {
    $InstallerManifest = 'C:\ParsecTemp\Apps\razer-surround-driver\$TEMP\RazerSurroundInstaller\InstallerManifest.xml'
    $regex = '(?<=<SilentMode>)[^<]*'
    (Get-Content $InstallerManifest) -replace $regex, 'true' | Set-Content $InstallerManifest -Encoding UTF8
    }

 #Audio Driver Install
function AudioInstall {
    Invoke-WebRequest -Uri "http://rzr.to/surround-pc-download" -OutFile "C:\ParsecTemp\Apps\razer-surround-driver.exe"
    ExtractRazerAudio
    ModidifyManifest
    $OriginalLocation = Get-Location
    Set-Location -Path 'C:\ParsecTemp\Apps\razer-surround-driver\$TEMP\RazerSurroundInstaller\'
    Start-Process RzUpdateManager.exe
    Set-Location $OriginalLocation
    Set-Service -Name audiosrv -StartupType Automatic
    }

#Creates shortcut for the GPU Updater tool
function gpu-update-shortcut {
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/parsec-cloud/Cloud-GPU-Updater/master/GPUUpdaterTool.ps1" -OutFile "$env:ProgramData\ParsecLoader\GPUUpdaterTool.ps1"
    Unblock-File -Path "$env:ProgramData\ParsecLoader\GPUUpdaterTool.ps1"
    ProgressWriter -Status "Creating GPU Updater icon on Desktop" -PercentComplete $PercentComplete
    $Shell = New-Object -ComObject ("WScript.Shell")
    $ShortCut = $Shell.CreateShortcut("$path\GPU Updater.lnk")
    $ShortCut.TargetPath="powershell.exe"
    $ShortCut.Arguments='-ExecutionPolicy Bypass -File "C:\ProgramData\ParsecLoader\GPUUpdaterTool.ps1"'
    $ShortCut.WorkingDirectory = "$env:ProgramData\ParsecLoader";
    $ShortCut.IconLocation = "$env:ProgramData\ParsecLoader\GPU-Update.ico, 0";
    $ShortCut.WindowStyle = 0;
    $ShortCut.Description = "GPU Updater shortcut";
    $ShortCut.Save()
    }

#Provider specific driver install and setup
Function provider-specific {
    ProgressWriter -Status "Installing Audio Driver if required and removing system information from appearing on Google Cloud Desktops" -PercentComplete $PercentComplete
    #Device ID Query 
    $gputype = get-wmiobject -query "select DeviceID from Win32_PNPEntity Where (deviceid Like '%PCI\\VEN_10DE%') and (PNPClass = 'Display' or Name = '3D Video Controller')" | Select-Object DeviceID -ExpandProperty DeviceID
    if ($gputype -eq $null) {
        }
    Else {
            if($gputype.substring(13,8) -eq "DEV_13F2") {
            #AWS G3.4xLarge M60
            #AudioInstall
            }
        ElseIF($gputype.Substring(13,8) -eq "DEV_118A"){
            #AWS G2.2xLarge K520
            #AudioInstall
            }
        ElseIF($gputype.Substring(13,8) -eq "DEV_1BB1") {
            #Paperspace P4000
            } 
        Elseif($gputype.Substring(13,8) -eq "DEV_1BB0") {
            #Paperspace P5000
            }
        Elseif($gputype.substring(13,8) -eq "DEV_15F8") {
            #Tesla P100
            if((Test-Path "C:\Program Files\Google\Compute Engine\tools\BGInfo.exe") -eq $true) {remove-item -path "C:\Program Files\Google\Compute Engine\tools\BGInfo.exe"} Else {}
            if((Test-Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\BGinfo.lnk") -eq $true) {Remove-Item -path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\BGinfo.lnk"} Else {}
            #AudioInstall
            }
        Elseif($gputype.substring(13,8) -eq "DEV_1BB3") {
            #Tesla P4
            if((Test-Path "C:\Program Files\Google\Compute Engine\tools\BGInfo.exe") -eq $true) {remove-item -path "C:\Program Files\Google\Compute Engine\tools\BGInfo.exe"} Else {}
            if((Test-Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\BGinfo.lnk") -eq $true) {Remove-Item -path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\BGinfo.lnk"} Else {}
            #AudioInstall
            }
        Elseif($gputype.substring(13,8) -eq "DEV_1EB8") {
            #Tesla T4
            if((Test-Path "C:\Program Files\Google\Compute Engine\tools\BGInfo.exe") -eq $true) {remove-item -path "C:\Program Files\Google\Compute Engine\tools\BGInfo.exe"} Else {}
            if((Test-Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\BGinfo.lnk") -eq $true) {Remove-Item -path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\BGinfo.lnk"} Else {}
            #AudioInstall
            }
        Elseif($gputype.substring(13,8) -eq "DEV_1430") {
            #Quadro M2000
            #AudioInstall
            }
        Else {
            }
        }
    }

#7Zip is required to extract the Parsec-Windows.exe File
function Install7Zip {
    Invoke-WebRequest "https://7-zip.org/a/7z2107-x64.exe" -OutFile "C:\ParsecTemp\Apps\7zip.exe"
    Start-Process C:\ParsecTemp\Apps\7zip.exe -ArgumentList '/S /D="C:\Program Files\7-Zip"' -Wait
    }

#Move Parsec Files into correct location
#Function ExtractInstallFiles {
#    cmd.exe /c '"C:\Program Files\7-Zip\7z.exe" x C:\ParsecTemp\Apps\parsec-windows.exe -oC:\ParsecTemp\Apps\Parsec-Windows -y' | Out-Null
#    if((Test-Path -Path 'C:\Program Files\Parsec')-eq $true) {} Else {New-Item -Path 'C:\Program Files\Parsec' -ItemType Directory | Out-Null}
#    if((Test-Path -Path "C:\Program Files\Parsec\skel") -eq $true) {} Else {Move-Item -Path C:\ParsecTemp\Apps\Parsec-Windows\skel -Destination 'C:\Program Files\Parsec' | Out-Null} 
#    if((Test-Path -Path "C:\Program Files\Parsec\vigem") -eq $true) {} Else  {Move-Item -Path C:\ParsecTemp\Apps\Parsec-Windows\vigem -Destination 'C:\Program Files\Parsec' | Out-Null} 
#    if((Test-Path -Path "C:\Program Files\Parsec\wscripts") -eq $true) {} Else  {Move-Item -Path C:\ParsecTemp\Apps\Parsec-Windows\wscripts -Destination 'C:\Program Files\Parsec' | Out-Null} 
#    if((Test-Path -Path "C:\Program Files\Parsec\parsecd.exe") -eq $true) {} Else {Move-Item -Path C:\ParsecTemp\Apps\Parsec-Windows\parsecd.exe -Destination 'C:\Program Files\Parsec' | Out-Null} 
#    if((Test-Path -Path "C:\Program Files\Parsec\pservice.exe") -eq $true) {} Else {Move-Item -Path C:\ParsecTemp\Apps\Parsec-Windows\pservice.exe -Destination 'C:\Program Files\Parsec' | Out-Null} 
#    Start-Sleep 1
#    }

#Checks for Server 2019 and asks user to install Windows Xbox Accessories in order to let their controller work
Function Server2019Controller {
    ProgressWriter -Status "Adding Xbox 360 Controller driver to Windows Server 2019" -PercentComplete $PercentComplete
    if ((gwmi win32_operatingsystem | % caption) -like '*Windows Server 2019*') {
        Invoke-WebRequest -Uri "http://www.download.windowsupdate.com/msdownload/update/v3-19990518/cabpool/2060_8edb3031ef495d4e4247e51dcb11bef24d2c4da7.cab" -OutFile "C:\ParsecTemp\Drivers\Xbox360_64Eng.cab"
        if((Test-Path -Path C:\ParsecTemp\Drivers\Xbox360_64Eng) -eq $true) {} Else {New-Item -Path C:\ParsecTemp\Drivers\Xbox360_64Eng -ItemType directory | Out-Null}
        cmd.exe /c "C:\Windows\System32\expand.exe C:\ParsecTemp\Drivers\Xbox360_64Eng.cab -F:* C:\ParsecTemp\Drivers\Xbox360_64Eng" | Out-Null
        cmd.exe /c '"C:\Program Files\Parsec\vigem\10\x64\devcon.exe" dp_add "C:\ParsecTemp\Drivers\Xbox360_64Eng\xusb21.inf"' | Out-Null
        }
    }

#Function InstallViGEmBus {
    #Required for Controller Support.
    #$Vigem = @{}
    #$Vigem.DriverFile = "C:\Program Files\Parsec\Vigem\ViGEmBus.cat";
    #$Vigem.CertName = 'C:\Program Files\Parsec\Vigem\Wohlfeil_IT_e_U_.cer';
    #$Vigem.ExportType = [System.Security.Cryptography.X509Certificates.X509ContentType]::Cert;
    #$Vigem.Cert = (Get-AuthenticodeSignature -filepath $vigem.DriverFile).SignerCertificate; 
    #$Vigem.CertInstalled = if ((Get-ChildItem -Path Cert:\CurrentUser\TrustedPublisher | Where-Object Subject -Like "*CN=Wohlfeil.IT e.U., O=Wohlfeil.IT e.U.*" ) -ne $null) {$True}
    #Else {$false}
    #if ($vigem.CertInstalled -eq $true) {
    #cmd.exe /c '"C:\Program Files\Parsec\vigem\10\x64\devcon.exe" install "C:\Program Files\Parsec\vigem\10\ViGEmBus.inf" Nefarius\ViGEmBus\Gen1' | Out-Null
    #} 
    #Else {[System.IO.File]::WriteAllBytes($Vigem.CertName, $Vigem.Cert.Export($Vigem.ExportType));
    #Import-Certificate -CertStoreLocation Cert:\LocalMachine\TrustedPublisher -FilePath 'C:\Program Files\Parsec\Vigem\Wohlfeil_IT_e_U_.cer' | Out-Null
    #Start-Sleep 5
    #cmd.exe /c '"C:\Program Files\Parsec\vigem\devcon.exe" install "C:\Program Files\Parsec\vigem\ViGEmBus.inf" Root\ViGEmBus' | Out-Null
    #}
    #}

#Creates Parsec Firewall Rule in Windows Firewall
#Function CreateFireWallRule {
#    New-NetFirewallRule -DisplayName "Parsec" -Direction Inbound -Program "C:\Program Files\Parsec\Parsecd.exe" -Profile Private,Public -Action Allow -Enabled True | Out-Null
#    }

#Creates Parsec Service
#Function CreateParsecService {
#    cmd.exe /c 'sc.exe Create "Parsec" binPath= "\"C:\Program Files\Parsec\pservice.exe\"" start= "auto"' | Out-Null
#    sc.exe Start 'Parsec' | Out-Null
#    }


Function InstallParsec {
    Start-Process "C:\ParsecTemp\Apps\parsec-windows.exe" -ArgumentList "/silent", "/shared" -wait
#    ExtractInstallFiles
#    InstallViGEmBus
#    CreateFireWallRule
#    CreateParsecService
#    create-shortcut-app
    }

#Apps that require human intervention
function Install-Gaming-Apps {
    ProgressWriter -Status "Installing Parsec, ViGEm https://github.com/ViGEm/ViGEmBus and 7Zip" -PercentComplete $PercentComplete
    #Install7Zip
    InstallParsec
    #if((Test-RegistryValue -path HKCU:\Software\Microsoft\Windows\CurrentVersion\Run -value "Parsec.App.0") -eq $true) {Set-ItemProperty -path HKCU:\Software\Microsoft\Windows\CurrentVersion\Run -Name "Parsec.App.0" -Value "C:\Program Files\Parsec\parsecd.exe" | Out-Null} Else {New-ItemProperty -path HKCU:\Software\Microsoft\Windows\CurrentVersion\Run -Name "Parsec.App.0" -Value "C:\Program Files\Parsec\parsecd.exe" | Out-Null}
    #Start-Process -FilePath "C:\Program Files\Parsec\parsecd.exe"
    Start-Sleep -s 1
    }

#Disable Devices
function disable-devices {
    ProgressWriter -Status "Disabling Microsoft Basic Display Adapter, Generic Non PNP Monitor and other devices" -PercentComplete $PercentComplete
    Start-Process -FilePath "C:\Program Files\Parsec\vigem\10\x64\devcon.exe" -ArgumentList '/r disable "HDAUDIO\FUNC_01&VEN_10DE&DEV_0083&SUBSYS_10DE11A3*"'
    Get-PnpDevice | where {$_.friendlyname -like "Generic Non-PNP Monitor" -and $_.status -eq "OK"} | Disable-PnpDevice -confirm:$false
    Get-PnpDevice | where {$_.friendlyname -like "Microsoft Basic Display Adapter" -and $_.status -eq "OK"} | Disable-PnpDevice -confirm:$false
    Get-PnpDevice | where {$_.friendlyname -like "Google Graphics Array (GGA)" -and $_.status -eq "OK"} | Disable-PnpDevice -confirm:$false
    Start-Process -FilePath "C:\Program Files\Parsec\vigem\10\x64\devcon.exe" -ArgumentList '/r disable "PCI\VEN_1013&DEV_00B8*"'
    Start-Process -FilePath "C:\Program Files\Parsec\vigem\10\x64\devcon.exe" -ArgumentList '/r disable "PCI\VEN_1D0F&DEV_1111*"'
    Start-Process -FilePath "C:\Program Files\Parsec\vigem\10\x64\devcon.exe" -ArgumentList '/r disable "PCI\VEN_1AE0&DEV_A002*"'
    }

#Cleanup
function clean-up {
    ProgressWriter -Status "Deleting temporary files from C:\ParsecTemp" -PercentComplete $PercentComplete
    Remove-Item -Path C:\ParsecTemp\Drivers -force -Recurse
    Remove-Item -Path $path\ParsecTemp -force -Recurse
    }

#cleanup recent files
function clean-up-recent {
    ProgressWriter -Status "Delete recently accessed files list from Windows Explorer" -PercentComplete $PercentComplete
    remove-item "$env:AppData\Microsoft\Windows\Recent\*" -Recurse -Force | Out-Null
    }

#stopping all parsec services
function stop-parsec {
    ProgressWriter -Status "Stopping all Parsec Services and restarting" -PercentComplete $PercentComplete
    Stop-Process -Name pservice -Force
    Stop-Process -Name parsecd -Force

    Start-Service -Name Parsec
}

function register-team-computer {
    ProgressWriter -Status "Registering Team Computer" -PercentComplete $PercentComplete
    $Output = Start-Process powershell.exe -argument "-file $env:ProgramData\ParsecLoader\TeamMachineSetup.ps1" -PassThru -Wait
    if ($Output.ExitCode -ne 0) {
        ProgressWriter -Status "Problem registering" -PercentComplete $PercentComplete
        $errMsg = "There was a problem registering your team computer with the team ID and key provided."
        Add-Content 'C:\Users\Public\Desktop\INSTALLED_SOFTWARE.txt' "ERROR: $($errMsg)"
        throw $errMsg
    }
}
    
#Start GPU Update Tool
Function StartGPUUpdate {
    param(
    [switch]$DontPromptPasswordUpdateGPU
    )
    if ($DontPromptPasswordUpdateGPU) {
        }
    Else {
      start-process powershell.exe -verb RunAS -argument "-file $env:ProgramData\ParsecLoader\GPUUpdaterTool.ps1"
        }
    }
Write-Host -foregroundcolor red "
                               ((//////                                
                             #######//////                             
                             ##########(/////.                         
                             #############(/////,                      
                             #################/////*                   
                             #######/############////.                 
                             #######/// ##########////                 
                             #######///    /#######///                 
                             #######///     #######///                 
                             #######///     #######///                 
                             #######////    #######///                 
                             ########////// #######///                 
                             ###########////#######///                 
                               ####################///                 
                                   ################///                 
                                     *#############///                 
                                         ##########///                 
                                            ######(*                   
                                                           
                           
                                       
                    ~Parsec Self Hosted Cloud Setup Script~

                    This script sets up your cloud computer
                    with a bunch of settings and drivers
                    to make your life easier.  
                    
                    It's provided with no warranty, 
                    so use it at your own risk.
                    
                    Check out the README.md for more
                    information.

                    This tool supports:

                    OS:
                    Server 2016
                    Server 2019
                    
                    CLOUD SKU:
                    AWS G3.4xLarge    (Tesla M60)
                    AWS G2.2xLarge    (GRID K520)
                    AWS G4dn.xLarge   (Tesla T4 with vGaming driver)
                    Azure NV6         (Tesla M60)
                    Paperspace P4000  (Quadro P4000)
                    Paperspace P5000  (Quadro P5000)
                    Google P100 VW    (Tesla P100 Virtual Workstation)
                    Google P4  VW    (Tesla P4 Virtual Workstation)
                    Google T4  VW    (Tesla T4 Virtual Workstation)

"   
#PromptUserAutoLogon -DontPromptPasswordUpdateGPU:$DontPromptPasswordUpdateGPU
$ScripttaskList = @(
"prepare-parsec";
"setupEnvironment";
"addRegItems";
"create-directories";
# "disable-iesecurity";
"download-resources";
#"install-windows-features";
"force-close-apps";
"disable-network-window";
"disable-logout";
"disable-lock";
#"show-hidden-items";
#"show-file-extensions";
#"enhance-pointer-precision";
#"enable-mousekeys";
"set-time";
#"set-wallpaper";
#"Create-AutoShutdown-Shortcut";
#"Create-One-Hour-Warning-Shortcut";
#"disable-server-manager";
"Install-Gaming-Apps";
"Server2019Controller";
#"gpu-update-shortcut";
"disable-devices";
#"clean-up";
#"clean-up-recent";
"provider-specific";
# "TeamMachineSetupScheduledTask";
"register-team-computer";
"stop-parsec"
)

foreach ($func in $ScripttaskList) {
    $PercentComplete =$($ScriptTaskList.IndexOf($func) / $ScripttaskList.Count * 100)
    & $func $PercentComplete
    }

#StartGPUUpdate -DontPromptPasswordUpdateGPU:$DontPromptPasswordUpdateGPU
ProgressWriter -status "Done" -percentcomplete 100
Write-Host "1. Open Parsec and sign in" -ForegroundColor black -BackgroundColor Green 
Write-Host "2. Use GPU Updater to update your GPU Drivers!" -ForegroundColor black -BackgroundColor Green 
Write-Host "You don't need to sign into Razer Synapse, the login box will stop appearing after a couple of reboots" -ForegroundColor black -BackgroundColor Green 
Write-Host "You may want to change your Windows password to something simpler if the password your cloud provider gave you is super long" -ForegroundColor black -BackgroundColor Green 
Write-host "DONE!" -ForegroundColor black -BackgroundColor Green
#pause
