$currentPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Write-Debug -Message "CurrentPath: $currentPath"

# Load Common Code
Import-Module $currentPath\..\..\xSQLServerHelper.psm1 -Verbose:$false -ErrorAction Stop

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $InstanceName,

        [parameter(Mandatory = $true)]
        [System.String]
        $RSSQLServer,

        [parameter(Mandatory = $true)]
        [System.String]
        $RSSQLInstanceName,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $SQLAdminCredential
    )

    if(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\RS" -Name $InstanceName -ErrorAction SilentlyContinue)
    {
        $InstanceKey = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\RS" -Name $InstanceName).$InstanceName
        $SQLVersion = ((Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$InstanceKey\Setup" -Name "Version").Version).Split(".")[0]
        $RSConfig = Invoke-Command -ComputerName . -Credential $SQLAdminCredential -ScriptBlock {
            $SQLVersion = $args[0]
            $InstanceName = $args[1]
            $RSConfig = Get-WmiObject -Class MSReportServer_ConfigurationSetting -Namespace "root\Microsoft\SQLServer\ReportServer\RS_$InstanceName\v$SQLVersion\Admin"
            $RSConfig
        } -ArgumentList @($SQLVersion,$InstanceName)
        if($RSConfig.DatabaseServerName.Contains("\"))
        {
            $RSSQLServer = $RSConfig.DatabaseServerName.Split("\")[0]
            $RSSQLInstanceName = $RSConfig.DatabaseServerName.Split("\")[1]
        }
        else
        {
            $RSSQLServer = $RSConfig.DatabaseServerName
            $RSSQLInstanceName = "MSSQLSERVER"
        }
        $IsInitialized = $RSConfig.IsInitialized
    }
    else
    {  
        throw New-TerminatingError -ErrorType SSRSNotFound -FormatArgs @($InstanceName) -ErrorCategory ObjectNotFound
    }

    $returnValue = @{
        InstanceName = $InstanceName
        RSSQLServer = $RSSQLServer
        RSSQLInstanceName = $RSSQLInstanceName
        IsInitialized = $IsInitialized
    }

    $returnValue
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $InstanceName,

        [parameter(Mandatory = $true)]
        [System.String]
        $RSSQLServer,

        [parameter(Mandatory = $true)]
        [System.String]
        $RSSQLInstanceName,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $SQLAdminCredential
    )

    if(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\RS" -Name $InstanceName -ErrorAction SilentlyContinue)
    {
        Invoke-Command -ComputerName . -Credential $SQLAdminCredential -Authentication Credssp -ScriptBlock {
            $InstanceName = $args[0]
            $RSSQLServer = $args[1]
            $RSSQLInstanceName = $args[2]
            $InstanceKey = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\RS" -Name $InstanceName).$InstanceName
            $SQLVersion = ((Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$InstanceKey\Setup" -Name "Version").Version).Split(".")[0]
            $DBCreateFile = [IO.Path]::GetTempFileName()
            $DBRightsFile = [IO.Path]::GetTempFileName()
            if($InstanceName -eq "MSSQLSERVER")
            {
                $RSServiceName = "ReportServer"
                $RSVirtualDirectory = "ReportServer"
                $RMVirtualDirectory = "Reports"
                $RSDatabase = "ReportServer"
            }
            else
            {
                $RSServiceName = "ReportServer`$$InstanceName"
                $RSVirtualDirectory = "ReportServer_$InstanceName"
                $RMVirtualDirectory = "Reports_$InstanceName"
                $RSDatabase = "ReportServer`$$InstanceName"
            }
            if($RSSQLInstanceName -eq "MSSQLSERVER")
            {
                $RSConnection = "$RSSQLServer"
            }
            else
            {
                $RSConnection = "$RSSQLServer\$RSSQLInstanceName"
            }
            $Language = (Get-WMIObject -Class Win32_OperatingSystem -Namespace root/cimv2 -ErrorAction SilentlyContinue).OSLanguage
            $RSConfig = Get-WmiObject -Class MSReportServer_ConfigurationSetting -Namespace "root\Microsoft\SQLServer\ReportServer\RS_$InstanceName\v$SQLVersion\Admin"
            if($RSConfig.VirtualDirectoryReportServer -ne $RSVirtualDirectory)
            {
                $RSConfig.SetVirtualDirectory("ReportServerWebService",$RSVirtualDirectory,$Language)
                $RSConfig.ReserveURL("ReportServerWebService","http://+:80",$Language)
            }
            if($RSConfig.VirtualDirectoryReportManager -ne $RMVirtualDirectory)
            {
                $RSConfig.SetVirtualDirectory("ReportManager",$RMVirtualDirectory,$Language)
                $RSConfig.ReserveURL("ReportManager","http://+:80",$Language)
            }
            $RSScript = $RSConfig.GenerateDatabaseCreationScript($RSDatabase,$Language,$false)
            $RSScript.Script | Out-File $DBCreateFile

            # Determine RS service account
            $RSSvcAccountUsername = (Get-WmiObject -Class Win32_Service | Where-Object {$_.Name -eq $RSServiceName}).StartName
            if(($RSSvcAccountUsername -eq "LocalSystem") -or (($RSSvcAccountUsername.Length -ge 10) -and ($RSSvcAccountUsername.SubString(0,10) -eq "NT Service")))
            {
                $RSSvcAccountUsername = $RSConfig.MachineAccountIdentity
            }
            $RSScript = $RSConfig.GenerateDatabaseRightsScript($RSSvcAccountUsername,$RSDatabase,$false,$true)
            $RSScript.Script | Out-File $DBRightsFile

            # Get path to sqlcmd.exe
            $SQLCmdLocations = @(
                @{
                    Key = "4B5EB208A08862C4C9A0A2924D2613FF"
                    Name = "BAF8FF4572ED7814281FBEEAA6EE68A9"
                }
                @{
                    Key = "4B5EB208A08862C4C9A0A2924D2613FF"
                    Name = "2BE7307A359F21B48B3491F5D489D81A"
                }
                @{
                    Key = "4B5EB208A08862C4C9A0A2924D2613FF"
                    Name = "17E375D97701E7C44BBDE4225A2D4BB8"
                }
                @{
                    Key = "A4A2A5C7B23E40145A6AFA7667643E85"
                    Name = "8B035CCA4B6B6D045BB9514286FC740D"
                }
            )
            $SQLCmdPath = ""
            foreach($SQLCmdLocation in $SQLCmdLocations)
            {
                if($SQLCmdPath -eq "")
                {
                    if(Get-ItemProperty -Path ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\" + $SQLCmdLocation.Key) -Name $SQLCmdLocation.Name -ErrorAction SilentlyContinue)
                    {
                        
                        if(Test-Path -Path (Get-ItemProperty -Path ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\" + $SQLCmdLocation.Key) -Name $SQLCmdLocation.Name).($SQLCmdLocation.Name))
                        {
                            $SQLCmdPath = (Get-ItemProperty -Path ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\" + $SQLCmdLocation.Key) -Name $SQLCmdLocation.Name).($SQLCmdLocation.Name)
                        }
                    }
                }
            }
            if($SQLCmdPath -ne "")
            {
                & "$SQLCmdPath" -S $RSConnection -i $DBCreateFile
                & "$SQLCmdPath" -S $RSConnection -i $DBRightsFile
                $RSConfig.SetDatabaseConnection($RSConnection,$RSDatabase,2,"","")
                $RSConfig.InitializeReportServer($RSConfig.InstallationID)
            }

            Remove-Item -Path $DBCreateFile
            Remove-Item -Path $DBRightsFile
        } -ArgumentList @($InstanceName,$RSSQLServer,$RSSQLInstanceName)
    }

    if(!(Test-TargetResource @PSBoundParameters))
    {
        throw New-TerminatingError -ErrorType TestFailedAfterSet -ErrorCategory InvalidResult
    }
}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $InstanceName,

        [parameter(Mandatory = $true)]
        [System.String]
        $RSSQLServer,

        [parameter(Mandatory = $true)]
        [System.String]
        $RSSQLInstanceName,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $SQLAdminCredential
    )

    $result = (Get-TargetResource @PSBoundParameters).IsInitialized
    
    $result
}


Export-ModuleMember -Function *-TargetResource
