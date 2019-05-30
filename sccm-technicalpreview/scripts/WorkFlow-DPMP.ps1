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

$Role = "DP_MP"
[string[]]$rolelist = "Distribution point","Management Point"
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
        WaitForPS = @{
            Status = 'NotStart'
            StartTime = ''
            EndTime = ''
        }
        AddPermission = @{
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
    try {
        $Invocation = (Get-Variable MyInvocation -Scope 1).Value
        $Path =  $Invocation.MyCommand.Path
        $command = ". $Path $DCIPAddress $DomainFullName $DomainAdminName `"$Password`" $tempurl `"$sakey`""
        $BatchFilePath = Join-Path -Path $ProvisionToolPath -ChildPath "Resume_$($env:COMPUTERNAME).ps1"
        $BatchFile = "cmd /c powershell -ExecutionPolicy Unrestricted -file " + $BatchFilePath
        $Command | Out-File -FilePath $BatchFilePath -Encoding ascii -Append

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
    catch {
        return 1
    }
}

$Mainscript = $ProvisionToolPath + "\main.ps1"
. $Mainscript

if ($Configuration.WaitForDC.Status -eq 'NotStart') {
    $Configuration.WaitForDC.Status = 'Running'
    $Configuration.WaitForDC.StartTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
    UploadConfigFile
    Start-Sleep -Seconds 600
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
                    shutdown -r -t 10
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
            $Result = TurnOn-FirewallPort $rolelist
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
            $Result = Install-RolesAndFeatures $rolelist
            if ($Result[-1] -eq 0)  {
                $Configuration.InstallRolesAndFeatures.Status = 'Completed'
                $Configuration.InstallRolesAndFeatures.EndTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
            }
            UploadConfigFile
        }

        if ($Configuration.WaitForPS.Status -eq 'NotStart') {
            $Configuration.WaitForPS.Status = 'Running'
            $Configuration.WaitForPS.StartTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
            UploadConfigFile
            $Result = WaitFor-PS
            if ($Result[-1] -eq 0)  {
                $Configuration.WaitForPS.Status = 'Completed'
                $Configuration.WaitForPS.EndTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
            }
            UploadConfigFile
        }

        if ($Configuration.AddPermission.Status -eq 'NotStart') {
            $Configuration.AddPermission.Status = 'Running'
            $Configuration.AddPermission.StartTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
            UploadConfigFile
            $Result = Add-Permission $DomainFullName
            if ($Result -eq 0)  {
                $Configuration.AddPermission.Status = 'Completed'
                $Configuration.AddPermission.EndTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
            }
            UploadConfigFile
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