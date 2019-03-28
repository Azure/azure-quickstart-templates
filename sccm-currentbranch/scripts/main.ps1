function Install-ADDS($DomainFullName,$Password)
{
    $path = "$ProvisionToolPath\InstallADDS.ps1"

    try
    {
        . $path $DomainFullName $Password
    }
    catch
    {
        $ErrorMessage = $_.Exception.Message
        return 1
    }
    return 0
}

function Add-BuiltinPermission
{
    $logpath = $ProvisionToolPath+"\AddBuiltinPermission.txt"
    try
    {
        Start-Sleep -Seconds 240
        "[$(Get-Date -format HH:mm:ss)] Adding Built Permission ..." | Out-File -Append $logpath
        sqlcmd -Q "if not exists(select * from sys.server_principals where name='BUILTIN\administrators') CREATE LOGIN [BUILTIN\administrators] FROM WINDOWS;EXEC master..sp_addsrvrolemember @loginame = N'BUILTIN\administrators', @rolename = N'sysadmin'" | Out-Null

        $returncode = sqlcmd -Q "if not exists(select * from sys.server_principals where name='BUILTIN\administrators') PRINT 1"
        while($returncode -eq 1 -or $returncode -eq $null)
        {
            "[$(Get-Date -format HH:mm:ss)] Failed , will try again ..." | Out-File -Append $logpath
            Start-Sleep -Seconds 60
            sqlcmd -Q "if not exists(select * from sys.server_principals where name='BUILTIN\administrators') CREATE LOGIN [BUILTIN\administrators] FROM WINDOWS;EXEC master..sp_addsrvrolemember @loginame = N'BUILTIN\administrators', @rolename = N'sysadmin'" | Out-Null
            $returncode = sqlcmd -Q "if not exists(select * from sys.server_principals where name='BUILTIN\administrators') PRINT 1"
        }
    }
    catch
    {
        $_.Exception | Out-File -Append $logpath
        Return 1
    }
    Return 0
}

function Set-AutoLogOn($DomainFullName,$Username,$Password)
{
    $path = "$ProvisionToolPath\SetAutoLogOn.ps1"

    try
    {
        . $path $DomainFullName $Username $Password
    }
    catch
    {
        return 1
    }
    return 0
}

function Install-RolesAndFeatures([string[]]$Role)
{
    $path = "$ProvisionToolPath\InstallFeature.ps1"

    try
    {
        . $path $Role
    }
    catch
    {
        return 1
    }
    return 0
}

function Join-Domain($DCIPAddress,$DomainFullName,$DomainAdminName,$Password)
{
    $path = "$ProvisionToolPath\JoinDomain.ps1"

    try
    {
        . $path $DCIPAddress $DomainFullName $DomainAdminName $Password
    }
    catch
    {
        return 1
    }
    return 0
}

function AZCopy($source,$dest,$upload,$isfolder=$false)
{
    $AZCopylogpath = $ProvisionToolPath+"\AZCopy.txt"
    $cmd = "$AzcopyPath\AzCopy.exe"
    $arg1 = "/Source:"+"$source"
    $arg2 = "/Dest:"+"$dest"
    if($upload)
    {
        $arg3 = "/DestKey:" + $sakey
    }
    else
    {
        $arg3 = "/SourceKey:" + $sakey
        $arg8 = "/MT"
    }
    $arg4 = "/Y"
    $arg5 = "/V:"+"$AZCopylogpath"
    $arg6 = "/XO"

    if($isfolder)
    {
        $arg7 = "/s"
        & $cmd $arg1 $arg2 $arg3 $arg4 $arg5 $arg6 $arg7 | out-null
    }
    else
    {
        if($upload)
        {
            & $cmd $arg1 $arg2 $arg3 $arg4 $arg5 $arg6 | out-null
        }
        else
        {
            & $cmd $arg1 $arg2 $arg3 $arg4 $arg5 $arg6 $arg8 | out-null
        }
    }
}

function WaitFor-DC
{
    $waitfordclog = $ProvisionToolPath +"\WaitForDCLog.txt"
    $dcconfigpath = $ProvisionToolPath + "\DC.json"
    $source = $tempurl + "/DC.json"
    AZCopy $source $dcconfigpath $false
    while(!(Test-Path $dcconfigpath))
    {
        "[$(Get-Date -format HH:mm:ss)] Waiting for DC config file..." | Out-File -Append $waitfordclog
        Start-Sleep -Seconds 10
        AZCopy $source $dcconfigpath $false | Out-Null
    }
    $dcconfig = gc $dcconfigpath | ConvertFrom-Json

    while(!($dcconfig.TurnOnFirewallPort.Status -eq 'Completed'))
    {
        "[$(Get-Date -format HH:mm:ss)] Waiting for DC..." | Out-File -Append $waitfordclog
        Start-Sleep -Seconds 10
        AZCopy $source $dcconfigpath $false
        $dcconfig = gc $dcconfigpath | ConvertFrom-Json
    }

    return 0
}

function WaitFor-PS
{
    $waitforpslog = $ProvisionToolPath +"\WaitForPSLog.txt"
    $psconfigpath = $ProvisionToolPath + "\PS1.json"
    $source = $tempurl + "/PS1.json"
    AZCopy $source $psconfigpath $false
    while(!(Test-Path $psconfigpath))
    {
        "[$(Get-Date -format HH:mm:ss)] Waiting for PS config file..." | Out-File -Append $waitforpslog
        Start-Sleep -Seconds 10
        AZCopy $source $psconfigpath $false | Out-Null
    }
    $psconfig = gc $psconfigpath | ConvertFrom-Json

    while(!($psconfig.TurnOnFirewallPort.Status -eq 'Completed'))
    {
        "[$(Get-Date -format HH:mm:ss)] Waiting for PS..." | Out-File -Append $waitforpslog
        Start-Sleep -Seconds 10
        AZCopy $source $psconfigpath $false
        $psconfig = gc $psconfigpath | ConvertFrom-Json
    }

    return 0
}

function WaitFor-SiteServer($SiteServerRole)
{
    $waitforsiteserverlog = $ProvisionToolPath +"\WaitForSiteServerLog.txt"
    $siteserverconfigpath = $ProvisionToolPath + "\$SiteServerRole.json"
    $source = $tempurl + "/$SiteServerRole.json"
    AZCopy $source $siteserverconfigpath $false
    while(!(Test-Path $siteserverconfigpath))
    {
        "[$(Get-Date -format HH:mm:ss)] Waiting for Site Server config file..." | Out-File -Append $waitforsiteserverlog
        Start-Sleep -Seconds 10
        AZCopy $source $siteserverconfigpath $false | Out-Null
    }
    $siteserverconfig = gc $siteserverconfigpath | ConvertFrom-Json

    while(!($siteserverconfig.AddPermission.Status -eq 'Completed'))
    {
        "[$(Get-Date -format HH:mm:ss)] Waiting for Site Server..." | Out-File -Append $waitforsiteserverlog
        Start-Sleep -Seconds 10
        AZCopy $source $siteserverconfigpath $false
        $siteserverconfig = gc $siteserverconfigpath | ConvertFrom-Json
    }

    return 0
}

function WaitFor-SQL
{
    $waitforsqllog = $ProvisionToolPath +"\waitforsqllog.txt"
    $sqlconfigpath = $ProvisionToolPath + "\SQL.json"
    $source = $tempurl + "/SQL.json"
    AZCopy $source $sqlconfigpath $false
    while(!(Test-Path $sqlconfigpath))
    {
        "[$(Get-Date -format HH:mm:ss)] Waiting for SQL config file..." | Out-File -Append $waitforsqllog
        Start-Sleep -Seconds 10
        AZCopy $source $sqlconfigpath $false | Out-Null
    }
    $sqlconfig = gc $sqlconfigpath | ConvertFrom-Json

    while(!($sqlconfig.AddPermission.Status -eq 'Completed'))
    {
        "[$(Get-Date -format HH:mm:ss)] Waiting for SQL..." | Out-File -Append $waitforsqllog
        Start-Sleep -Seconds 10
        AZCopy $source $sqlconfigpath $false
        $sqlconfig = gc $sqlconfigpath | ConvertFrom-Json
    }

    return 0
}


function UploadConfigFile
{
    $Configuration | ConvertTo-Json | Out-File -FilePath $ConfigurationFile -Force;
    $configfile = $ConfigurationFile
    $uploadurl = $tempurl + "/$Role.json"

    AZCopy $configfile $uploadurl $true
}

function Enable-RDP
{
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name fDenyTSConnections -Value 0
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name UserAuthentication -Value 1
    Set-NetFirewallRule -DisplayGroup 'Remote Desktop' -Enabled True
}

function Extend-ADSchema
{
    $url = "https://cmsetoolstorage.blob.core.windows.net/work/tools/extadsch.exe"
    $path = "C:\extadsch.exe"
    Invoke-WebRequest -Uri $url -OutFile $path

    & 'C:\extadsch.exe' | out-null
}

function TurnOn-FirewallPort([string[]]$Role)
{
    $path = "$ProvisionToolPath\OpenFirewallPort.ps1"

    try
    {
        . $path $Role
    }
    catch
    {
        return 1
    }
    return 0
}

function Delegate-Control($DomainFullName,[string[]]$RoleList)
{
    $logpath = $ProvisionToolPath+"\DelegateControlLog.txt"
    $RoleList | %{
        "[$(Get-Date -format HH:mm:ss)] Add permission for $_ ..." | Out-File -Append $logpath
        $psconfigpath = $ProvisionToolPath + "\$_.json"
        $source = $tempurl + "/$_.json"
        AZCopy $source $psconfigpath $false
        $psconfig = gc $psconfigpath | ConvertFrom-Json

        $currentmachine = $psconfig.Name

        try
        {
            $root = ConfigContainer
            $DomainName = $DomainFullName.split('.')[0]
            #Delegate Control
            $cmd = "dsacls.exe"
            $arg1 = "CN=System Management,CN=System,$root"
            $arg2 = "/G"
            $arg3 = ""+$DomainName+"\"+$currentmachine+"`$:GA;;"
            $arg4 = "/I:T"

            & $cmd $arg1 $arg2 $arg3 $arg4
            "[$(Get-Date -format HH:mm:ss)] Finished." | Out-File -Append $logpath
        }
        catch
        {
            return 1
        }
    }
    
    Return 0
}

function Extend-ADSchema
{
    $url = "https://cmsetoolstorage.blob.core.windows.net/work/tools/extadsch.exe"
    $path = "C:\extadsch.exe"
    Invoke-WebRequest -Uri $url -OutFile $path

    & 'C:\extadsch.exe' | out-null

    return 0
}

function Install-ADK
{
    $path = "$ProvisionToolPath\InstallADK.ps1"

    try
    {
        . $path
    }
    catch
    {
        return 1
    }
    return 0
}

function Install-SQL($DomainFullName,$Username,$Password)
{
    $path = "$ProvisionToolPath\InstallSQL.ps1"

    try
    {
        . $path $DomainFullName $Username $Password
    }
    catch
    {
        return 1
    }
    return 0
}

function Install-SCCM($DomainFullName,$Username,$Password,$SQLRole,$CM)
{
    $path = "$ProvisionToolPath\InstallSCCM.ps1"

    #GetSQLInfo
    $configpath = $ProvisionToolPath + "\$SQLRole.json"
    $source = $tempurl + "/$SQLRole.json"
    AZCopy $source $configpath $false
    $config = gc $configpath | ConvertFrom-Json
    $SQLVMName = $config.Name
    $SQLInstanceName = $config.SQLInstanceName
    $SQLDataFilePath = $config.SQLDataFilePath
    $SQLLogFilePath = $config.SQLLogFilePath

    try
    {
        . $path $DomainFullName $Username $Password $CM $SQLVMName $SQLInstanceName $SQLDataFilePath $SQLLogFilePath
    }
    catch
    {
        return 1
    }
    return 0
}

function Upgrade-SCCM($DomainFullName)
{
    $path = "$ProvisionToolPath\UpgradeSCCM.ps1"

    try
    {
        . $path $DomainFullName
    }
    catch
    {
        return 1
    }
    return 0
}

function Update-SQLServicesAccount($DomainFullName,$Username,$Password)
{
    if($DomainFullName)
    {
        $NetBIOSName = $DomainFullName.split('.')[0]
        $Username = $NetBIOSName + '\' + $Username
    }
    $DomainPassword = $Password
    $DomainUserName = $Username

    $SQLInstanceName = $Configuration.SQLInstanceName
    $logpath = $ProvisionToolPath + "\UpdateSQLServicesAccount.log"
    #Get SQL Server Services account
    $query = "Name = '"+ $SQLInstanceName.ToUpper() +"'"
    $services = Get-WmiObject win32_service -Filter $query
    if($services -ne $null)
    {
        "[$(Get-Date -format HH:mm:ss)] Verify if SQL Server services account need to be changed" | Out-File -Append $logpath
        if($services.StartName -ne $DomainUserName)
        {
            "[$(Get-Date -format HH:mm:ss)] SQL Server services account need to be changed" | Out-File -Append $logpath
            #change services account 
            if($services.State -eq 'Running')
            {
                #Check if SQLSERVERAGENT is running
                $sqlserveragentflag = 0
                $sqlserveragentservices = Get-WmiObject win32_service -Filter "Name = 'SQLSERVERAGENT'"
                if($sqlserveragentservices -ne $null)
                {
                    if($sqlserveragentservices.State -eq 'Running')
                    {
                        "[$(Get-Date -format HH:mm:ss)] SQLSERVERAGENT need to be stopped first" | Out-File -Append $logpath
                        $Result = $sqlserveragentservices.StopService()
                        "[$(Get-Date -format HH:mm:ss)] Stopping SQLSERVERAGENT.." | Out-File -Append $logpath
                        if ($Result.ReturnValue -eq '0')
                        {
                            $sqlserveragentflag = 1
                            "[$(Get-Date -format HH:mm:ss)] Stopped" | Out-File -Append $logpath
                        }
                    }
                }
                $Result = $services.StopService()
                "[$(Get-Date -format HH:mm:ss)] Stopping SQL Server services.." | Out-File -Append $logpath
                if ($Result.ReturnValue -eq '0')
                {
                    "[$(Get-Date -format HH:mm:ss)] Stopped" | Out-File -Append $logpath
                }

                "[$(Get-Date -format HH:mm:ss)] Changing the services account..." | Out-File -Append $logpath
            
                $Result = $services.change($null,$null,$null,$null,$null,$null,$DomainUserName,$Password,$null,$null,$null) 
                if ($Result.ReturnValue -eq '0')
                {
                    "[$(Get-Date -format HH:mm:ss)] Successfully Change the services account" | Out-File -Append $logpath
                    if($sqlserveragentflag -eq 1)
                    {
                        "[$(Get-Date -format HH:mm:ss)] Starting SQLSERVERAGENT.." | Out-File -Append $logpath
                        $Result = $sqlserveragentservices.StartService()
                        if($Result.ReturnValue -eq '0')
                        {
                            "[$(Get-Date -format HH:mm:ss)] Started" | Out-File -Append $logpath
                        }
                    }
                    $Result =  $services.StartService()
                    "[$(Get-Date -format HH:mm:ss)] Starting SQL Server services.." | Out-File -Append $logpath
                    while($Result.ReturnValue -ne '0') 
                    {
                        $returncode = $Result.ReturnValue
                        "[$(Get-Date -format HH:mm:ss)] Return $returncode , will try again" | Out-File -Append $logpath
                        Start-Sleep -Seconds 10
                        $Result =  $services.StartService()
                    }
                    "[$(Get-Date -format HH:mm:ss)] Started" | Out-File -Append $logpath
                }
            }
        }
        else
        {
            "[$(Get-Date -format HH:mm:ss)] No need to be changed" | Out-File -Append $logpath
        }
    }
    Return 0
}

function Install-DP($DomainFullName)
{
    $path = "$ProvisionToolPath\InstallDP.ps1"

    $configpath = $ProvisionToolPath + "\DP_MP.json"
    $source = $tempurl + "/DP_MP.json"
    AZCopy $source $configpath $false
    $config = gc $configpath | ConvertFrom-Json
    $currentmachine = $config.Name

    try
    {
        . $path "PS1" $currentmachine $DomainFullName
    }
    catch
    {
        return 1
    }
    return 0
}

function Clean-Up
{
    $BatchFilePath = Join-Path -Path $ProvisionToolPath -ChildPath "Resume_$($env:COMPUTERNAME).ps1"
    Remove-Item $BatchFilePath

    return 0
}

function Install-MP($DomainFullName,$SQLRole,$DomainAdminName,$Password)
{
    $path = "$ProvisionToolPath\InstallMP.ps1"
    $configpath = $ProvisionToolPath + "\DP_MP.json"
    $source = $tempurl + "/DP_MP.json"
    AZCopy $source $configpath $false
    $config = gc $configpath | ConvertFrom-Json
    $currentmachine = $config.Name

    #GetSQLInfo
    $configpath = $ProvisionToolPath + "\$SQLRole.json"
    $source = $tempurl + "/$SQLRole.json"
    AZCopy $source $configpath $false
    $config = gc $configpath | ConvertFrom-Json
    $SQLVMName = $config.Name
    $SQLInstanceName = $config.SQLInstanceName
    $SQLDataFilePath = $config.SQLDataFilePath
    $SQLLogFilePath = $config.SQLLogFilePath

    try
    {
         . $path "PS1" $currentmachine $DomainFullName $SQLVMName $SQLInstanceName $DomainAdminName $Password
    }
    catch
    {
        return 1
    }
    return 0
}

function ConfigContainer
{
    # Get or create the System Management container
    $root = (Get-ADRootDSE).defaultNamingContext
    $ou = $null 
    try 
    { 
        $ou = Get-ADObject "CN=System Management,CN=System,$root"
    } 
    catch 
    { 
        Write-Verbose "System Management container does not currently exist."
    }
    if ($ou -eq $null) 
    { 
        $ou = New-ADObject -Type Container -name "System Management" -Path "CN=System,$root" -Passthru 
    }

    return $root

}

function Add-Permission($DomainFullName)
{
    $logpath = $ProvisionToolPath+"\AddPermissionLog.txt"
    $DomainName = $DomainFullName.split('.')[0]
    $psconfigpath = $ProvisionToolPath + "\PS1.json"
    $source = $tempurl + "/PS1.json"
    AZCopy $source $psconfigpath $false
    $psconfig = gc $psconfigpath | ConvertFrom-Json

    $currentmachine = $psconfig.Name
    $psname = $currentmachine +"$"

    $GroupObj = [ADSI]"WinNT://$env:COMPUTERNAME/Administrators"
    if($GroupObj.IsMember("WinNT://$DomainName/$psname") -eq $false)
    {
        "[$(Get-Date -format HH:mm:ss)] add $psname to administrators group" | Out-File -Append $logpath
        $GroupObj.Add("WinNT://$DomainName/$psname") | out-null
    }
    else
    {
        "[$(Get-Date -format HH:mm:ss)] $psname is already in administrators group" | Out-File -Append $logpath
    }

    return 0
}

function Get-SQLInformation
{
    $inst = (get-itemproperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server').InstalledInstances[0]
    $p = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL').$inst

    $sqlinfo = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$p\$inst"

    $Configuration.SQLInstanceName = $inst
    $Configuration.SQLDataFilePath = $sqlinfo.DefaultData
    $Configuration.SQLLogFilePath = $sqlinfo.DefaultLog
}