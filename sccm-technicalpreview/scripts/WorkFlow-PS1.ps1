Param($DCIPAddress,$DomainFullName,$DomainAdminName,$Password,$tempurl,$sakey)

add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

$Role = "PS1"
$RoleList = "Site Server"
$ProvisionToolPath = "$env:windir\temp\ProvisionScript"
if(!(Test-Path $ProvisionToolPath))
{
    New-Item $ProvisionToolPath -ItemType directory | Out-Null
}

$AzcopyPath = "C:\Program Files (x86)\Microsoft SDKs\Azure\AzCopy"

if(!(Test-Path $AzcopyPath))
{
    $path = "$ProvisionToolPath\azcopy.msi"
    if(!(Test-Path $path))
    {
        #Download azcopy
        $url = "http://aka.ms/downloadazcopy"
        Invoke-WebRequest -Uri $url -OutFile $path
    }

    #Install azcopy
    Start-Process msiexec.exe -Wait -ArgumentList "/I $path /quiet"
}

$sourceDirctory = (split-path -parent $MyInvocation.MyCommand.Definition) + "\*"
$destDirctory = "$ProvisionToolPath\"
Copy-item -Force -Recurse $sourceDirctory -Destination $destDirctory

$ConfigurationFile = Join-Path -Path $ProvisionToolPath -ChildPath "$Role.json"

if (Test-Path -Path $ConfigurationFile) 
{
    $Configuration = Get-Content -Path $ConfigurationFile | ConvertFrom-Json
} 
else 
{
    [hashtable]$Actions = @{
        Name = $env:COMPUTERNAME
        SQLInstanceName = ""
        SQLDataFilePath = ""
        SQLLogFilePath = ""
        AddBuiltinPermission = @{
            Status = 'NotStart'
            StartTime = ''
            EndTime = ''
        }
        WaitForDC = @{
            Status = 'NotStart'
            StartTime = ''
            EndTime = ''
        }
        JoinDomain = @{
            Status = 'NotStart'
            StartTime = ''
            EndTime = ''
        }
        SetAutoLogOn = @{
            Status = 'NotStart'
            StartTime = ''
            EndTime = ''
        }
        TurnOnFirewallPort = @{
            Status = 'NotStart'
            StartTime = ''
            EndTime = ''
        }
        InstallRolesAndFeatures = @{
            Status = 'NotStart'
            StartTime = ''
            EndTime = ''
        }
        InstallADK = @{
            Status = 'NotStart'
            StartTime = ''
            EndTime = ''
        }
        ChangeSQLServicesAccount = @{
            Status = 'NotStart'
            StartTime = ''
            EndTime = ''
        }
        InstallSCCM = @{
            Status = 'NotStart'
            StartTime = ''
            EndTime = ''
        }
        UpgradeSCCM = @{
            Status = 'NotStart'
            StartTime = ''
            EndTime = ''
        }
        WaitForSiteServer = @{
            Status = 'NotStart'
            StartTime = ''
            EndTime = ''
        }
        InstallDP = @{
            Status = 'NotStart'
            StartTime = ''
            EndTime = ''
        }
        InstallMP = @{
            Status = 'NotStart'
            StartTime = ''
            EndTime = ''
        }
        CleanUp = @{
            Status = 'NotStart'
            StartTime = ''
            EndTime = ''
        }
    }
    $Configuration = New-Object -TypeName psobject -Property $Actions
}

$Configuration | Add-Member -MemberType ScriptMethod -Name SetRebootConfig -Value {
    try 
    {
        $Invocation = (Get-Variable MyInvocation -Scope 1).Value
        $Path =  $Invocation.MyCommand.Path
        $BatchFilePath = Join-Path -Path $ProvisionToolPath -ChildPath "Resume_$($env:COMPUTERNAME).ps1"
        $Command = ""
        if($this.AddBuiltinPermission.Status -eq "Running")
        {
            $command = @'
Start-Sleep -Second 240
sqlcmd -Q "if not exists(select * from sys.server_principals where name='BUILTIN\administrators') CREATE LOGIN [BUILTIN\administrators] FROM WINDOWS;EXEC master..sp_addsrvrolemember @loginame = N'BUILTIN\administrators', @rolename = N'sysadmin'"
$retrycount = 0
$sqlpermission = sqlcmd -Q "if exists(select * from sys.server_principals where name='BUILTIN\administrators') Print 1"
while($sqlpermission -eq $null)
{
    if($retrycount -eq 3)
    {
        $sqlpermission = 1
    }
    else
    {
        $retrycount++
        Start-Sleep -Second 240
        sqlcmd -Q "if not exists(select * from sys.server_principals where name='BUILTIN\administrators') CREATE LOGIN [BUILTIN\administrators] FROM WINDOWS;EXEC master..sp_addsrvrolemember @loginame = N'BUILTIN\administrators', @rolename = N'sysadmin'"
        $sqlpermission = sqlcmd -Q "if exists(select * from sys.server_principals where name='BUILTIN\administrators') Print 1"
    }
}
'@
        }
        $Command | Out-File -FilePath $BatchFilePath -Encoding ascii
        $Command = ". $Path $DCIPAddress $DomainFullName $DomainAdminName $Password $tempurl `"$sakey`""
        $Command | Out-File -FilePath $BatchFilePath -Encoding ascii -Append

        $BatchFile = "cmd /k powershell -ExecutionPolicy Unrestricted -file " + $BatchFilePath
        
        $RunOnceRegKey = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce'
        $KeyValueName = 'Workflow Reboot'
        $KeyType = [Microsoft.Win32.RegistryValueKind]::String
        $null = [Microsoft.Win32.Registry]::SetValue($RunOnceRegKey,$KeyValueName,$BatchFile,$KeyType)
        $this | ConvertTo-Json | Out-File -FilePath $ConfigurationFile -Force

        $configfile = $ConfigurationFile
        $uploadurl = $tempurl + "/$Role.json"
        AZCopy -source $configfile -dest $uploadurl -upload $true

        return 0
    }
    catch 
    {
        return 1
    }
}

$Mainscript = $ProvisionToolPath + "\main.ps1"
. $Mainscript

if ($Configuration.AddBuiltinPermission.Status -eq 'NotStart') {
    $Configuration.AddBuiltinPermission.Status = 'Running'
    $Configuration.AddBuiltinPermission.StartTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
    Get-SQLInformation
    $Result = $Configuration.SetRebootConfig()
    if ($Result -eq 0) {
        $Result = Set-AutoLogOn "" $DomainAdminName $Password
        shutdown -r -t 10
        exit 0
    }
}

if ($Configuration.AddBuiltinPermission.Status -eq 'Running') {
    $Configuration.AddBuiltinPermission.Status = 'Completed'
    $Configuration.AddBuiltinPermission.EndTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
    UploadConfigFile
}

if ($Configuration.WaitForDC.Status -eq 'NotStart') {
    $Configuration.WaitForDC.Status = 'Running'
    $Configuration.WaitForDC.StartTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
    UploadConfigFile
    $Result = WaitFor-DC
    if ($Result -eq 0)  {
        $Configuration.WaitForDC.Status = 'Completed'
        $Configuration.WaitForDC.EndTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
    }
    else
    {
        $Configuration.WaitForDC.Status = 'Error'
        $Configuration.WaitForDC.EndTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
    }
    UploadConfigFile
}

if($Configuration.WaitForDC.Status -eq 'Completed')
{
    if ($Configuration.JoinDomain.Status -eq 'NotStart') {
        $Configuration.JoinDomain.Status = 'Running'
        $Configuration.JoinDomain.StartTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
        UploadConfigFile
        $Result = Join-Domain $DCIPAddress $DomainFullName $DomainAdminName $Password
        if ($Result -eq 0)  {
            $Configuration.JoinDomain.Status = 'Completed'
            $Configuration.JoinDomain.EndTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
        }
        else
        {
            $Configuration.JoinDomain.Status = 'Error'
            $Configuration.JoinDomain.EndTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
        }
        UploadConfigFile
    }

    if ($Configuration.JoinDomain.Status -eq 'Completed') {
       if ($Configuration.SetAutoLogOn.Status -eq 'NotStart') {
            $Configuration.SetAutoLogOn.Status = 'Running'
            $Configuration.SetAutoLogOn.StartTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
            UploadConfigFile
            $Result = Set-AutoLogOn $DomainFullName $DomainAdminName $Password
            if ($Result -eq 0)  {
                $Configuration.SetAutoLogOn.Status = 'Completed'
                $Configuration.SetAutoLogOn.EndTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"

                UploadConfigFile

                $Result = $Configuration.SetRebootConfig()
                if ($Result -eq 0) {
                    shutdown -r -t 0
                    exit 0
                }
            }
            else
            {
                $Configuration.SetAutoLogOn.Status = 'Error'
                $Configuration.SetAutoLogOn.EndTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"

                UploadConfigFile
            }
        }

        Enable-RDP
    
        if ($Configuration.TurnOnFirewallPort.Status -eq 'NotStart') {
            $Configuration.TurnOnFirewallPort.Status = 'Running'
            $Configuration.TurnOnFirewallPort.StartTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
            UploadConfigFile
            $Result = TurnOn-FirewallPort $RoleList
            if ($Result[-1] -eq 0)  {
                $Configuration.TurnOnFirewallPort.Status = 'Completed'
                $Configuration.TurnOnFirewallPort.EndTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
            }
            UploadConfigFile
        }

        if ($Configuration.InstallRolesAndFeatures.Status -eq 'NotStart') {
            $Configuration.InstallRolesAndFeatures.Status = 'Running'
            $Configuration.InstallRolesAndFeatures.StartTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
            UploadConfigFile
            $Result = Install-RolesAndFeatures $RoleList
            if ($Result[-1] -eq 0)  {
                $Configuration.InstallRolesAndFeatures.Status = 'Completed'
                $Configuration.InstallRolesAndFeatures.EndTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
                $Result = $Configuration.SetRebootConfig()
                $Result = Set-AutoLogOn $DomainFullName $DomainAdminName $Password
                if ($Result -eq 0) {
                    shutdown -r -t 10
                    exit 0
                }
            }
        }

        ##Insall ADK

        if ($Configuration.InstallADK.Status -eq 'NotStart') {
            $Configuration.InstallADK.Status = 'Running'
            $Configuration.InstallADK.StartTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
            UploadConfigFile
            $Result = Install-ADK
            if ($Result[-1] -eq 0)  {
                $Configuration.InstallADK.Status = 'Completed'
                $Configuration.InstallADK.EndTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
            }
            UploadConfigFile
        }
        
        if ($Configuration.ChangeSQLServicesAccount.Status -eq 'NotStart') {
            $Configuration.ChangeSQLServicesAccount.Status = 'Running'
            $Configuration.ChangeSQLServicesAccount.StartTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
            UploadConfigFile
            $Result = Update-SQLServicesAccount $DomainFullName $DomainAdminName $Password
            if ($Result[-1] -eq 0)  {
                $Configuration.ChangeSQLServicesAccount.Status = 'Completed'
                $Configuration.ChangeSQLServicesAccount.EndTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
            }
            UploadConfigFile
        }

        ##Install CM
        if ($Configuration.InstallSCCM.Status -eq 'NotStart') {
            $Configuration.InstallSCCM.Status = 'Running'
            $Configuration.InstallSCCM.StartTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
            UploadConfigFile
            $Result = Install-SCCM $DomainFullName $DomainAdminName $Password $Role "CMTP"
            if ($Result[-1] -eq 0)  {
                $Configuration.InstallSCCM.Status = 'Completed'
                $Configuration.InstallSCCM.EndTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"

                $Result = $Configuration.SetRebootConfig()
                $Result = Set-AutoLogOn $DomainFullName $DomainAdminName $Password
                if ($Result -eq 0) {
                    shutdown -r -t 120
                }
            }
            else
            {
                $Configuration.InstallSCCM.Status = 'Error'
                $Configuration.InstallSCCM.EndTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
            }
            UploadConfigFile
            exit 0
        }

        if($Configuration.InstallSCCM.Status -eq 'Completed')
        {
            if ($Configuration.UpgradeSCCM.Status -eq 'NotStart') 
            {
                $Configuration.UpgradeSCCM.Status = 'Running'
                $Configuration.UpgradeSCCM.StartTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
                UploadConfigFile
                $Result = Upgrade-SCCM $DomainFullName
                if ($Result[-1] -eq 0)  {
                    $Configuration.UpgradeSCCM.Status = 'Completed'
                    $Configuration.UpgradeSCCM.EndTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
                }
                else
                {
                    $Configuration.UpgradeSCCM.Status = 'Error'
                    $Configuration.UpgradeSCCM.EndTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
                }
                UploadConfigFile
            }

            if ($Configuration.WaitForSiteServer.Status -eq 'NotStart') {
                $Configuration.WaitForSiteServer.Status = 'Running'
                $Configuration.WaitForSiteServer.StartTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
                UploadConfigFile
                $Result = WaitFor-SiteServer "DP_MP"
                if ($Result[-1] -eq 0)  {
                    $Configuration.WaitForSiteServer.Status = 'Completed'
                    $Configuration.WaitForSiteServer.EndTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
                }
                UploadConfigFile
            }

            if ($Configuration.InstallDP.Status -eq 'NotStart') {
                $Configuration.InstallDP.Status = 'Running'
                $Configuration.InstallDP.StartTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
                UploadConfigFile
                $Result = Install-DP $DomainFullName
                if ($Result[-1] -eq 0)  {
                    $Configuration.InstallDP.Status = 'Completed'
                    $Configuration.InstallDP.EndTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
                }
                else
                {
                    $Configuration.InstallDP.Status = 'Error'
                    $Configuration.InstallDP.EndTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
                }
                UploadConfigFile
            }

            if ($Configuration.InstallMP.Status -eq 'NotStart') {
                $Configuration.InstallMP.Status = 'Running'
                $Configuration.InstallMP.StartTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
                UploadConfigFile
                $Result = Install-MP $DomainFullName $Role $DomainAdminName $Password
                if ($Result[-1] -eq 0)  {
                    $Configuration.InstallMP.Status = 'Completed'
                    $Configuration.InstallMP.EndTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
                }
                else
                {
                    $Configuration.InstallMP.Status = 'Error'
                    $Configuration.InstallMP.EndTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
                }
                UploadConfigFile
            }
        }

        if ($Configuration.CleanUp.Status -eq 'NotStart') {
            $Configuration.CleanUp.Status = 'Running'
            $Configuration.CleanUp.StartTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
            UploadConfigFile
            $Result = Clean-Up
            if ($Result[-1] -eq 0)  {
                $Configuration.CleanUp.Status = 'Completed'
                $Configuration.CleanUp.EndTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
            }
            UploadConfigFile
        }
    }
}

exit 0
