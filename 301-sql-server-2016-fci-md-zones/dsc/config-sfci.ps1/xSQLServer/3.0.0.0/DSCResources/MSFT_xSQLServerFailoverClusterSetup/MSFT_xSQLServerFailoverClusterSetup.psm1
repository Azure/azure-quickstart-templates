# NOTE: This resource requires WMF5 and PsDscRunAsCredential

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
        [ValidateSet("Prepare","Complete")]
        [System.String]
        $Action,

        [System.String]
        $SourcePath = "$PSScriptRoot\..\..\",

        [System.String]
        $SourceFolder = "Source",

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $SetupCredential,

        [System.Management.Automation.PSCredential]
        $SourceCredential,

        [System.Boolean]
        $SuppressReboot,

        [System.Boolean]
        $ForceReboot,

        [parameter(Mandatory = $true)]
        [System.String]
        $Features,

        [parameter(Mandatory = $true)]
        [System.String]
        $InstanceName,

        [System.String]
        $InstanceID = $InstanceName,

        [System.String]
        $PID,

        [System.String]
        $UpdateEnabled = $True,

        [System.String]
        $UpdateSource = ".\Updates",

        [System.String]
        $SQMReporting,

        [System.String]
        $ErrorReporting,

        [System.String]
        $FailoverClusterGroup = "SQL Server ($InstanceName)",

        [parameter(Mandatory = $true)]
        [System.String]
        $FailoverClusterNetworkName,

        [System.String]
        $FailoverClusterIPAddress,

        [System.String]
        $InstallSharedDir,

        [System.String]
        $InstallSharedWOWDir,

        [System.String]
        $InstanceDir,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $SQLSvcAccount,

        [System.Management.Automation.PSCredential]
        $AgtSvcAccount = $SQLSvcAccount,

        [System.String]
        $SQLCollation,

        [System.String[]]
        $SQLSysAdminAccounts,

        [System.String]
        $SecurityMode,

        [System.Management.Automation.PSCredential]
        $SAPwd = $SetupCredential,

        [System.String]
        $InstallSQLDataDir,

        [System.String]
        $SQLUserDBDir,

        [System.String]
        $SQLUserDBLogDir,

        [System.String]
        $SQLTempDBDir,

        [System.String]
        $SQLTempDBLogDir,

        [System.String]
        $SQLBackupDir,

        [System.Management.Automation.PSCredential]
        $ASSvcAccount = $SQLSvcAccount,

        [System.String]
        $ASCollation,

        [System.String[]]
        $ASSysAdminAccounts,

        [System.String]
        $ASDataDir,

        [System.String]
        $ASLogDir,

        [System.String]
        $ASBackupDir,

        [System.String]
        $ASTempDir,

        [System.String]
        $ASConfigDir,

        [System.Management.Automation.PSCredential]
        $ISSvcAccount = $SQLSvcAccount,

        [System.String]
        $ISFileSystemFolder
    )

    $InstanceName = $InstanceName.ToUpper()

    Import-Module $PSScriptRoot\..\..\xPDT.psm1

    if($SourceCredential)
    {
        NetUse -SourcePath $SourcePath -Credential $SourceCredential -Ensure "Present"
    }
    $Path = Join-Path -Path (Join-Path -Path $SourcePath -ChildPath $SourceFolder) -ChildPath "setup.exe"
    $Path = ResolvePath $Path
    Write-Verbose "Path: $Path"
    $SQLVersion = GetSQLVersion -Path $Path
    if($SourceCredential)
    {
        NetUse -SourcePath $SourcePath -Credential $SourceCredential -Ensure "Absent"
    }
    
    if($InstanceName -eq "MSSQLSERVER")
    {
        $DBServiceName = "MSSQLSERVER"
        $AgtServiceName = "SQLSERVERAGENT"
        $ASServiceName = "MSSQLServerOLAPService"
    }
    else
    {
        $DBServiceName = "MSSQL`$$InstanceName"
        $AgtServiceName = "SQLAgent`$$InstanceName"
        $ASServiceName = "MSOLAP`$$InstanceName"
    }
    $ISServiceName = "MsDtsServer" + $SQLVersion + "0"

    if(Get-WmiObject -Namespace root/mscluster -Class MSCluster_ResourceGroup  -ErrorAction SilentlyContinue | Where-Object {$_.Name -eq $FailoverClusterGroup})
    {
        $Complete = $true
        $FailoverClusterNetworkName = (Get-ClusterGroup -Name $FailoverClusterGroup | Get-ClusterResource | Where-Object {$_.ResourceType -eq "Network Name"} | Get-ClusterParameter -Name "Name").Value
        $FailoverClusterIPAddress = (Get-ClusterGroup -Name $FailoverClusterGroup | Get-ClusterResource | Where-Object {$_.ResourceType -eq "IP Address"} | Get-ClusterParameter -Name "Address").Value
    }
    else
    {
        $FailoverClusterGroup = $null
        $FailoverClusterNetworkName = $null
        $FailoverClusterIPAddress = $null
        $Complete = $false
    }
    
    $Services = Get-Service
    $Features = ""
    if($Services | Where-Object {$_.Name -eq $DBServiceName})
    {
        $Features += "SQLENGINE,"
        $SQLSvcAccountUsername = (Get-WmiObject -Class Win32_Service | Where-Object {$_.Name -eq $DBServiceName}).StartName
        $AgtSvcAccountUsername = (Get-WmiObject -Class Win32_Service | Where-Object {$_.Name -eq $AgtServiceName}).StartName
        $InstanceID = ((Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL' -Name $InstanceName).$InstanceName).Split(".")[1]
        $FullInstanceID = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL' -Name $InstanceName).$InstanceName
        $InstanceID = $FullInstanceID.Split(".")[1]
        $InstanceDir = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$FullInstanceID\Setup" -Name 'SqlProgramDir').SqlProgramDir.Trim("\")
    }
    if($Services | Where-Object {$_.Name -eq $ASServiceName})
    {
        $Features += "AS,"
        $ASSvcAccountUsername = (Get-WmiObject -Class Win32_Service | Where-Object {$_.Name -eq $ASServiceName}).StartName
    }
    if($Services | Where-Object {$_.Name -eq $ISServiceName})
    {
        $Features += "IS,"
        $ISSvcAccountUsername = (Get-WmiObject -Class Win32_Service | Where-Object {$_.Name -eq $ISServiceName}).StartName
    }
    $Products = Get-WmiObject -Class Win32_Product
    switch($SQLVersion)
    {
        "11"
        {
            $IdentifyingNumber = "{A7037EB2-F953-4B12-B843-195F4D988DA1}"
        }
        "12"
        {
            $IdentifyingNumber = "{75A54138-3B98-4705-92E4-F619825B121F}"
        }
    }
    if($Products | Where-Object {$_.IdentifyingNumber -eq $IdentifyingNumber})
    {
        $Features += "SSMS,"
    }
    switch($SQLVersion)
    {
        "11"
        {
            $IdentifyingNumber = "{7842C220-6E9A-4D5A-AE70-0E138271F883}"
        }
        "12"
        {
            $IdentifyingNumber = "{B5ECFA5C-AC4F-45A4-A12E-A76ABDD9CCBA}"
        }
    }
    if($Products | Where-Object {$_.IdentifyingNumber -eq $IdentifyingNumber})
    {
        $Features += "ADV_SSMS,"
    }
    $Features = $Features.Trim(",")
    if($Features -ne "")
    {
        switch($SQLVersion)
        {
            "11"
            {
                $InstallSharedDir = (GetFirstItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components" -Name "FEE2E540D20152D4597229B6CFBC0A69")
                $InstallSharedWOWDir = (GetFirstItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components" -Name "A79497A344129F64CA7D69C56F5DD8B4")
            }
            "12"
            {
                $InstallSharedDir = (GetFirstItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components" -Name "FEE2E540D20152D4597229B6CFBC0A69")
                $InstallSharedWOWDir = (GetFirstItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components" -Name "C90BFAC020D87EA46811C836AD3C507F")
            }
            "13"
            {
                $InstallSharedDir = (GetFirstItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components" -Name "FEE2E540D20152D4597229B6CFBC0A69")
                $InstallSharedWOWDir = (GetFirstItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components" -Name "A79497A344129F64CA7D69C56F5DD8B4")
            }
        }
    }

    $returnValue = @{
        Action = $Action
        SourcePath = $SourcePath
        SourceFolder = $SourceFolder
        Features = $Features
        InstanceName = $InstanceName
        InstanceID = $InstanceID
        FailoverClusterGroup = $FailoverClusterGroup
        FailoverClusterNetworkName = $FailoverClusterNetworkName
        FailoverClusterIPAddress = $FailoverClusterIPAddress
        InstallSharedDir = $InstallSharedDir
        InstallSharedWOWDir = $InstallSharedWOWDir
        InstanceDir = $InstanceDir
        SQLSvcAccountUsername = $SQLSvcAccountUsername
        AgtSvcAccountUsername = $AgtSvcAccountUsername
        ASSvcAccountUsername = $ASSvcAccountUsername
        ISSvcAccountUsername = $ISSvcAccountUsername
    }

    $returnValue
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Prepare","Complete")]
        [System.String]
        $Action,

        [System.String]
        $SourcePath = "$PSScriptRoot\..\..\",

        [System.String]
        $SourceFolder = "Source",

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $SetupCredential,

        [System.Management.Automation.PSCredential]
        $SourceCredential,

        [System.Boolean]
        $SuppressReboot,

        [System.Boolean]
        $ForceReboot,

        [parameter(Mandatory = $true)]
        [System.String]
        $Features,

        [parameter(Mandatory = $true)]
        [System.String]
        $InstanceName,

        [System.String]
        $InstanceID = $InstanceName,

        [System.String]
        $PID,

        [System.String]
        $UpdateEnabled = $True,

        [System.String]
        $UpdateSource = ".\Updates",

        [System.String]
        $SQMReporting,

        [System.String]
        $ErrorReporting,

        [System.String]
        $FailoverClusterGroup = "SQL Server ($InstanceName)",

        [parameter(Mandatory = $true)]
        [System.String]
        $FailoverClusterNetworkName,

        [System.String]
        $FailoverClusterIPAddress,

        [System.String]
        $InstallSharedDir,

        [System.String]
        $InstallSharedWOWDir,

        [System.String]
        $InstanceDir,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $SQLSvcAccount,

        [System.Management.Automation.PSCredential]
        $AgtSvcAccount = $SQLSvcAccount,

        [System.String]
        $SQLCollation,

        [System.String[]]
        $SQLSysAdminAccounts,

        [System.String]
        $SecurityMode,

        [System.Management.Automation.PSCredential]
        $SAPwd = $SetupCredential,

        [System.String]
        $InstallSQLDataDir,

        [System.String]
        $SQLUserDBDir,

        [System.String]
        $SQLUserDBLogDir,

        [System.String]
        $SQLTempDBDir,

        [System.String]
        $SQLTempDBLogDir,

        [System.String]
        $SQLBackupDir,

        [System.Management.Automation.PSCredential]
        $ASSvcAccount = $SQLSvcAccount,

        [System.String]
        $ASCollation,

        [System.String[]]
        $ASSysAdminAccounts,

        [System.String]
        $ASDataDir,

        [System.String]
        $ASLogDir,

        [System.String]
        $ASBackupDir,

        [System.String]
        $ASTempDir,

        [System.String]
        $ASConfigDir,

        [System.Management.Automation.PSCredential]
        $ISSvcAccount = $SQLSvcAccount,

        [System.String]
        $ISFileSystemFolder
    )

    $InstanceName = $InstanceName.ToUpper()

    Import-Module $PSScriptRoot\..\..\xPDT.psm1
        
    if($SourceCredential)
    {
        NetUse -SourcePath $SourcePath -Credential $SourceCredential -Ensure "Present"
        $TempFolder = [IO.Path]::GetTempPath()
        & robocopy.exe (Join-Path -Path $SourcePath -ChildPath $SourceFolder) (Join-Path -Path $TempFolder -ChildPath $SourceFolder) /e
        $SourcePath = $TempFolder
        NetUse -SourcePath $SourcePath -Credential $SourceCredential -Ensure "Absent"
    }
    $Path = Join-Path -Path (Join-Path -Path $SourcePath -ChildPath $SourceFolder) -ChildPath "setup.exe"
    $Path = ResolvePath $Path
    $SQLVersion = GetSQLVersion -Path $Path
    
    foreach($feature in $Features.Split(","))
    { 
        if(($SQLVersion -eq "13") -and (($feature -eq "SSMS") -or ($feature -eq "ADV_SSMS")))
        {
            Throw New-TerminatingError -ErrorType FeatureNotSupported -FormatArgs @($feature) -ErrorCategory InvalidData
        }
    }

    switch($Action)
    {
        "Prepare"
        {
            # If SQL shared components already installed, clear InstallShared*Dir variables
            switch($SQLVersion)
            {
                "11"
                {
                    if((Get-Variable -Name "InstallSharedDir" -ErrorAction SilentlyContinue) -and (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\30AE1F084B1CF8B4797ECB3CCAA3B3B6" -ErrorAction SilentlyContinue))
                    {
                        Set-Variable -Name "InstallSharedDir" -Value ""
                    }
                    if((Get-Variable -Name "InstallSharedWOWDir" -ErrorAction SilentlyContinue) -and (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\A79497A344129F64CA7D69C56F5DD8B4" -ErrorAction SilentlyContinue))
                    {
                        Set-Variable -Name "InstallSharedWOWDir" -Value ""
                    }
                }
                "12"
                {
                    if((Get-Variable -Name "InstallSharedDir" -ErrorAction SilentlyContinue) -and (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\FEE2E540D20152D4597229B6CFBC0A69" -ErrorAction SilentlyContinue))
                    {
                        Set-Variable -Name "InstallSharedDir" -Value ""
                    }
                    if((Get-Variable -Name "InstallSharedWOWDir" -ErrorAction SilentlyContinue) -and (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\C90BFAC020D87EA46811C836AD3C507F" -ErrorAction SilentlyContinue))
                    {
                        Set-Variable -Name "InstallSharedWOWDir" -Value ""
                    }
                }
                "13"
                {
                    if((Get-Variable -Name "InstallSharedDir" -ErrorAction SilentlyContinue) -and (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\FEE2E540D20152D4597229B6CFBC0A69" -ErrorAction SilentlyContinue))
                    {
                        Set-Variable -Name "InstallSharedDir" -Value ""
                    }
                    if((Get-Variable -Name "InstallSharedWOWDir" -ErrorAction SilentlyContinue) -and (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\A79497A344129F64CA7D69C56F5DD8B4" -ErrorAction SilentlyContinue))
                    {
                        Set-Variable -Name "InstallSharedWOWDir" -Value ""
                    }
                }
            }

            # Create install arguments
            $Arguments = "/SkipRules=`"Cluster_VerifyForErrors`" /Quiet=`"True`" /IAcceptSQLServerLicenseTerms=`"True`" /Action=`"PrepareFailoverCluster`""
            $ArgumentVars = @(
                "InstanceName",
                "InstanceID",
                "UpdateEnabled",
                "UpdateSource",
                "Features",
                "PID",
                "SQMReporting",
                "ErrorReporting",
                "InstallSharedDir",
                "InstallSharedWOWDir",
                "InstanceDir"
            )
            foreach($ArgumentVar in $ArgumentVars)
            {
                if((Get-Variable -Name $ArgumentVar).Value -ne "")
                {
                    $Arguments += " /$ArgumentVar=`"" + (Get-Variable -Name $ArgumentVar).Value + "`""
                }
            }
            if($Features.Contains("SQLENGINE"))
            {
                $Arguments += " /AgtSvcAccount=`"" + $AgtSvcAccount.UserName + "`""
                $Arguments += " /AgtSvcPassword=`"" + $AgtSvcAccount.GetNetworkCredential().Password + "`""
                $Arguments += " /SQLSvcAccount=`"" + $SQLSvcAccount.UserName + "`""
                $Arguments += " /SQLSvcPassword=`"" + $SQLSvcAccount.GetNetworkCredential().Password + "`""
            }
            if($Features.Contains("AS"))
            {
                $Arguments += " /ASSvcAccount=`"" + $ASSvcAccount.UserName + "`""
                $Arguments += " /ASSvcPassword=`"" + $ASSvcAccount.GetNetworkCredential().Password + "`""
            }
            if($Features.Contains("IS"))
            {
                $Arguments += " /ISSvcAccount=`"" + $ISSvcAccount.UserName + "`""
                $Arguments += " /ISSvcPassword=`"" + $ISSvcAccount.GetNetworkCredential().Password + "`""
            }
        }
        "Complete"
        {
            # Remove trailing "\" from paths
            foreach($Var in @("InstallSQLDataDir","SQLUserDBDir","SQLUserDBLogDir","SQLTempDBDir","SQLTempDBLogDir","SQLBackupDir","ASDataDir","ASLogDir","ASBackupDir","ASTempDir","ASConfigDir","ISFileSystemFolder"))
            {
                if(Get-Variable -Name $Var -ErrorAction SilentlyContinue)
                {
                    Set-Variable -Name $Var -Value (Get-Variable -Name $Var).Value.TrimEnd("\")
                }
            }

            # Discover which cluster disks need to be added to this cluster group
            $Drives = @()
            foreach($Var in @("InstallSQLDataDir","SQLUserDBDir","SQLUserDBLogDir","SQLTempDBDir","SQLTempDBLogDir","SQLBackupDir","ASDataDir","ASLogDir","ASBackupDir","ASTempDir","ASConfigDir","ISFileSystemFolder"))
            {
                if(
                    (Get-Variable -Name $Var -ErrorAction SilentlyContinue) -and `
                    ((Get-Variable -Name $Var).Value.Length -ge 2) -and `
                    ((Get-Variable -Name $Var).Value.Substring(1,1) -eq ":")
                )
                {
                    $Drives += (Get-Variable -Name $Var).Value.Substring(0,2)
                }
            }
            $Drives = $Drives | Sort-Object -Unique
            $FailoverClusterDisks = @()
            $DiskResources = Get-WmiObject -Class MSCluster_Resource -Namespace root/mscluster | Where-Object {$_.Type -eq "Physical Disk"}
            foreach($DiskResource in $DiskResources)
            {
                $Disks = Get-WmiObject -Namespace root/mscluster -Query "Associators of {$DiskResource} Where ResultClass=MSCluster_Disk"
                foreach($Disk in $Disks)
                {
                    $Partitions = Get-WmiObject -Namespace root/mscluster -Query "Associators of {$Disk} Where ResultClass=MSCluster_DiskPartition"
                    foreach($Partition in $Partitions)
                    {
                        foreach($Drive in $Drives)
                        {
                            if($Partition.Path -eq $Drive)
                            {
                                $FailoverClusterDisks += $DiskResource.Name
                            }
                        }
                    }
                }
            }

            # Discover which cluster network to use for this cluster group
            $ClusterNetworks = @(Get-WmiObject -Namespace root/mscluster -Class MSCluster_Network)
            if([String]::IsNullOrEmpty($FailoverClusterIPAddress))
            {
                $FailoverClusterIPAddresses = "IPv4;DHCP;" + $ClusterNetworks[0].Name
            }
            else
            {
                $FailoverClusterIPAddressDecimal = ConvertDecimalIP -IPAddress $FailoverClusterIPAddress
                foreach($ClusterNetwork in $ClusterNetworks)
                {
                    $ClusterNetworkAddressDecimal = ConvertDecimalIP -IPAddress $ClusterNetwork.Address
                    $ClusterNetworkAddressMaskDecimal = ConvertDecimalIP -IPAddress $ClusterNetwork.AddressMask
                    if(($FailoverClusterIPAddressDecimal -band $ClusterNetworkAddressMaskDecimal) -eq ($ClusterNetworkAddressDecimal -band $ClusterNetworkAddressMaskDecimal))
                    {
                        $FailoverClusterIPAddresses = "IPv4;$FailoverClusterIPAddress;" + $ClusterNetwork.Name + ";" + $ClusterNetwork.AddressMask
                    }
                }
            }

            # Create install arguments
            $Arguments = "/SkipRules=`"Cluster_VerifyForErrors`" /Quiet=`"True`" /IAcceptSQLServerLicenseTerms=`"True`" /Action=`"CompleteFailoverCluster`""
            $ArgumentVars = @(
                "InstanceName",
                "FailoverClusterGroup",
                "FailoverClusterNetworkName",
                "FailoverClusterIPAddresses"
            )
            if($Features.Contains("SQLENGINE"))
            {
                $ArgumentVars += @(
                    "SecurityMode",
                    "SQLCollation",
                    "InstallSQLDataDir",
                    "SQLUserDBDir",
                    "SQLUserDBLogDir",
                    "SQLTempDBDir",
                    "SQLTempDBLogDir",
                    "SQLBackupDir"
                )
            }
            if($Features.Contains("AS"))
            {
                $ArgumentVars += @(
                    "ASCollation",
                    "ASDataDir",
                    "ASLogDir",
                    "ASBackupDir",
                    "ASTempDir",
                    "ASConfigDir"
                )
            }
            foreach($ArgumentVar in $ArgumentVars)
            {
                if((Get-Variable -Name $ArgumentVar).Value -ne "")
                {
                    $Arguments += " /$ArgumentVar=`"" + (Get-Variable -Name $ArgumentVar).Value + "`""
                }
            }
            if($FailoverClusterDisks.Count -ne 0)
            {
                $Arguments += " /FailoverClusterDisks="
                foreach($FailoverClusterDisk in $FailoverClusterDisks)
                {
                    $Arguments +="`"$FailoverClusterDisk`" "
                }
                $Arguments = $Arguments.Trim()
            }
            if($Features.Contains("SQLENGINE"))
            {
                $Arguments += " /SQLSysAdminAccounts=`"" + $SetupCredential.UserName + "`""
                if($PSBoundParameters.ContainsKey("SQLSysAdminAccounts"))
                {
                    foreach($AdminAccount in $SQLSysAdminAccounts)
                    {
                        $Arguments += " `"$AdminAccount`""
                    }
                }
                if($SecurityMode -eq "SQL")
                {
                    $Arguments += " /SAPwd=`"" + $SAPwd.GetNetworkCredential().Password + "`""
                }
            }
            if($Features.Contains("AS"))
            {
                $Arguments += " /ASSysAdminAccounts=`"" + $SetupCredential.UserName + "`""
                if($PSBoundParameters.ContainsKey("ASSysAdminAccounts"))
                {
                    foreach($AdminAccount in $ASSysAdminAccounts)
                    {
                        $Arguments += " `"$AdminAccount`""
                    }
                }
            }
        }
    }
    
    # Replace sensitive values for verbose output
    $Log = $Arguments
    if($PID -ne "")
    {
        $Log = $Log.Replace($PID,"*****-*****-*****-*****-*****")
    }
    if($SecurityMode -eq "SQL")
    {
        $Log = $Log.Replace($SAPwd.GetNetworkCredential().Password,"********")
    }
    $LogVars = @("AgtSvcAccount","SQLSvcAccount","ASSvcAccount","ISSvcAccount")
    foreach($LogVar in $LogVars)
    {
        if((Get-Variable -Name $LogVar).Value -ne "")
        {
            $Log = $Log.Replace((Get-Variable -Name $LogVar).Value.GetNetworkCredential().Password,"********")
        }
    }

    Write-Verbose "Path: $Path"
    Write-Verbose "Arguments: $Log"

    switch($Action)
    {
        'Prepare'
        {
            $Process = StartWin32Process -Path $Path -Arguments $Arguments -Credential $SetupCredential -AsTask
        }
        'Complete'
        {
            $Process = StartWin32Process -Path $Path -Arguments $Arguments
        }
    }
    Write-Verbose $Process
    WaitForWin32ProcessEnd -Path $Path -Arguments $Arguments -Credential $SetupCredential

    # Additional "Prepare" actions
    if($Action -eq "Prepare")
    {
        # Configure integration services
        if($Features.Contains("IS"))
        {
            $MsDtsSrvrPath = (Get-ItemProperty -Path ("HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\" + $SQLVersion + "0\SSIS\ServiceConfigFile") -Name '(default)').'(default)'
            if(Test-Path $MsDtsSrvrPath)
            {
                $MsDtsSrvr = [XML](Get-Content $MsDtsSrvrPath)
                if($FailoverClusterNetworkName -eq "")
                {
                    $FailoverClusterNetworkName = "."
                }
                if($InstanceName -eq "MSSQLSERVER")
                {
                    $MsDtsSrvr.DtsServiceConfiguration.TopLevelFolders.Folder | Where-Object {$_.type -eq "SqlServerFolder"} | ForEach-Object {$_.ServerName = "$FailoverClusterNetworkName"}
                }
                else
                {
                    $MsDtsSrvr.DtsServiceConfiguration.TopLevelFolders.Folder | Where-Object {$_.type -eq "SqlServerFolder"} | ForEach-Object {$_.ServerName = "$FailoverClusterNetworkName\$InstanceName"}
                }
                $MsDtsSrvr.Save($MsDtsSrvrPath)
                Restart-Service -Name ("MsDtsServer" + $SQLVersion + "0")
            }
        }
    }

    # Additional "Complete" actions
    if($Action -eq "Complete")
    {
        # Workaround for Analysis Services IPv6 issue, see KB2658571
        if($Features.Contains("AS"))
        {
            $msmredirpath = [Environment]::ExpandEnvironmentVariables("%ProgramFiles(x86)%\Microsoft SQL Server\90\Shared\ASConfig\msmdredir.ini")
            if(Test-Path ($msmredirpath))
            {
                $msmdredir = [XML](Get-Content $msmredirpath)
                if($msmdredir.ConfigurationSettings.Instances.Instance | Where-Object {$_.Name -eq $InstanceName} | ForEach-Object {$_.PortIPv6})
                {
                    $Entry = $msmdredir.ConfigurationSettings.Instances.Instance | Where-Object {$_.Name -eq $InstanceName} | ForEach-Object {$_.SelectSingleNode('PortIPv6')}
                    $msmdredir.ConfigurationSettings.Instances.Instance | Where-Object {$_.Name -eq $InstanceName} | ForEach-Object {$_.RemoveChild($Entry)}
                    $msmdredir.Save($msmredirpath)
                    Stop-ClusterGroup -Name $FailoverClusterGroup
                    Start-ClusterGroup -Name $FailoverClusterGroup
                }
            }
        }

        # Create path for Integration Services
        if($Features.Contains("IS") -and ($ISFileSystemFolder -ne ""))
        {
            if(($ISFileSystemFolder.Length -ge 2) -and ($ISFileSystemFolder.Substring(1,1) -eq ":"))
            {
                Invoke-Command -ScriptBlock {
                    $ISFileSystemFolder = $args[0]
                    if((Test-Path -Path $ISFileSystemFolder.Substring(0,2)) -and !(Test-Path -Path $ISFileSystemFolder))
                    {
                        New-Item -Path $ISFileSystemFolder -ItemType Directory
                    }
                } -ComputerName . -ArgumentList @($ISFileSystemFolder)
            }
        }
    }
    
    if($ForceReboot -or ((Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name 'PendingFileRenameOperations' -ErrorAction SilentlyContinue) -ne $null))
    {
        if(!($SuppressReboot))
        {
            $global:DSCMachineStatus = 1
        }
        else
        {
            Write-Verbose "Suppressing reboot"
        }
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
        [ValidateSet("Prepare","Complete")]
        [System.String]
        $Action,

        [System.String]
        $SourcePath = "$PSScriptRoot\..\..\",

        [System.String]
        $SourceFolder = "Source",

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $SetupCredential,

        [System.Management.Automation.PSCredential]
        $SourceCredential,

        [System.Boolean]
        $SuppressReboot,

        [System.Boolean]
        $ForceReboot,

        [parameter(Mandatory = $true)]
        [System.String]
        $Features,

        [parameter(Mandatory = $true)]
        [System.String]
        $InstanceName,

        [System.String]
        $InstanceID = $InstanceName,

        [System.String]
        $PID,

        [System.String]
        $UpdateEnabled = $True,

        [System.String]
        $UpdateSource = ".\Updates",

        [System.String]
        $SQMReporting,

        [System.String]
        $ErrorReporting,

        [System.String]
        $FailoverClusterGroup = "SQL Server ($InstanceName)",

        [parameter(Mandatory = $true)]
        [System.String]
        $FailoverClusterNetworkName,

        [System.String]
        $FailoverClusterIPAddress,

        [System.String]
        $InstallSharedDir,

        [System.String]
        $InstallSharedWOWDir,

        [System.String]
        $InstanceDir,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $SQLSvcAccount,

        [System.Management.Automation.PSCredential]
        $AgtSvcAccount = $SQLSvcAccount,

        [System.String]
        $SQLCollation,

        [System.String[]]
        $SQLSysAdminAccounts,

        [System.String]
        $SecurityMode,

        [System.Management.Automation.PSCredential]
        $SAPwd = $SetupCredential,

        [System.String]
        $InstallSQLDataDir,

        [System.String]
        $SQLUserDBDir,

        [System.String]
        $SQLUserDBLogDir,

        [System.String]
        $SQLTempDBDir,

        [System.String]
        $SQLTempDBLogDir,

        [System.String]
        $SQLBackupDir,

        [System.Management.Automation.PSCredential]
        $ASSvcAccount = $SQLSvcAccount,

        [System.String]
        $ASCollation,

        [System.String[]]
        $ASSysAdminAccounts,

        [System.String]
        $ASDataDir,

        [System.String]
        $ASLogDir,

        [System.String]
        $ASBackupDir,

        [System.String]
        $ASTempDir,

        [System.String]
        $ASConfigDir,

        [System.Management.Automation.PSCredential]
        $ISSvcAccount = $SQLSvcAccount,

        [System.String]
        $ISFileSystemFolder
    )

    switch($Action)
    {
        "Prepare"
        {
            $SQLData = Get-TargetResource @PSBoundParameters

            $result = $true
            foreach($Feature in $Features.Split(","))
            {
                if(!($SQLData.Features.Contains($Feature)))
                {
                    $result = $false
                }
            }
        }
        "Complete"
        {
            if(Get-WmiObject -Namespace root/mscluster -Class MSCluster_ResourceGroup  -ErrorAction SilentlyContinue | Where-Object {$_.Name -eq $FailoverClusterGroup})
            {
                $result = $true
            }
            else
            {
                $result = $false
            }
        }
    }
    
    $result
}


function GetSQLVersion
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [String]
        $Path
    )

    (Get-Item -Path $Path).VersionInfo.ProductVersion.Split(".")[0]
}


function GetFirstItemPropertyValue
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [String]
        $Path,

        [Parameter(Mandatory=$true)]
        [String]
        $Name
    )

    if(Get-ItemProperty -Path "$Path\$Name" -ErrorAction SilentlyContinue)
    {
        $FirstName = ((Get-ItemProperty -Path "$Path\$Name") | Get-Member -MemberType NoteProperty | Where-Object {$_.Name.Substring(0,2) -ne "PS"}).Name[0]
        (Get-ItemProperty -Path "$Path\$Name" -Name $FirstName).$FirstName.TrimEnd("\")
    }
}


function ConvertDecimalIP
{
    [CmdLetBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [Net.IPAddress]
        $IPAddress
    )
 
    $i = 3
    $DecimalIP = 0
    $IPAddress.GetAddressBytes() | ForEach-Object {
        $DecimalIP += $_ * [Math]::Pow(256,$i)
        $i--
    }
 
    return [UInt32]$DecimalIP
}


Export-ModuleMember -Function *-TargetResource
