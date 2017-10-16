#requires -Version 5
$StartTime = [System.Diagnostics.Stopwatch]::StartNew()

$computers = 'OHSQL9012'
$OutputPath = 'F:\DSCConfig'
$KeyPath = 'F:\publicKeys'


$cim = New-CimSession -ComputerName $computers
Function check-even($num){[bool]!($num%2)}


Function Get-Cert 
{ 
    Param 
    ( 
        [System.String]$RemoteMachine, 
        [System.String]$SaveLocation = "F:\publicKeys" 
    ) 
    if (!(test-path $SaveLocation))
    {
        new-item -path $SaveLocation -type Directory
    }
    $CertStore = New-Object System.Security.Cryptography.X509Certificates.X509Store -ArgumentList  "\\$($RemoteMachine)\My", "LocalMachine" 
    $CertStore.Open('ReadOnly') 
    $certificate  = $CertStore.Certificates | Where-Object {$_.EnhancedKeyUsageList.friendlyName -eq "Document Encryption"} 
    [byte[]]$Bytes  = $certificate.Export('Cert') 
    [string]$SaveLiteralPath = "$SaveLocation\$RemoteMachine.$env:UserDNSDomain.cer" 
    Remove-Item -Path $SaveLiteralPath -Force -ErrorAction Ignore 
    Set-Content -Path $SaveLiteralPath -Value $Bytes -Encoding Byte -Force | out-null 
}

foreach ($computer in $computers)
{
    Get-Cert -RemoteMachine $computer -SaveLocation $KeyPath
}

Get-cert -RemoteMachine $env:COMPUTERNAME -SaveLocation $KeyPath

[DSCLocalConfigurationManager()]
Configuration LCM_Reboot_CentralConfig 
{    
    Param(
        [string[]]$ComputerName
    )
    Node $computers
    {
        Settings
        {
            ConfigurationID                = $GUID
            CertificateID                  =(Get-PfxCertificate -FilePath "$KeyPath\$computers.$env:USERDNSDOMAIN.cer").Thumbprint
            RefreshFrequencyMins           = 30
            ConfigurationModeFrequencyMins = 15
            RefreshMode                    = "Push"
            AllowModuleOverwrite           = $true 
            RebootNodeIfNeeded = $True    
            ConfigurationMode = 'ApplyAndAutoCorrect'
        }  
    }
}
#LCM_Reboot_CentralConfig -OutputPath $OutputPath

foreach ($computer in $computers)
{
    $GUID = (New-Guid).Guid
    LCM_Reboot_CentralConfig -ComputerName $Computer -OutputPath $OutputPath 
    Set-DSCLocalConfigurationManager -Path $OutputPath  -CimSession $cim –Verbose
}

Configuration SQLBuild
{
    Import-DscResource –Module PSDesiredStateConfiguration
    Import-DscResource -Module xSQLServer
   
    Node $AllNodes.NodeName
    {
        LocalConfigurationManager
        {
            CertificateId = $Node.Thumbprint
        }

        WindowsFeature "NET"
        {
            Ensure = "Present"
            Name = "NET-Framework-Core"
            Source = $Node.NETPath 
        }

        if($Features -ne "")
        {
           xSqlServerSetup ($Node.NodeName)
           {
               DependsOn = '[WindowsFeature]NET'
               SourcePath = $Node.SourcePath
               SetupCredential = $Node.InstallerServiceAccount
               InstanceName = $Node.InstanceName
               Features = $Features
               SQLSysAdminAccounts = $Node.AdminAccount
               InstallSharedDir = "G:\Program Files\Microsoft SQL Server"
               InstallSharedWOWDir = "G:\Program Files (x86)\Microsoft SQL Server"
               InstanceDir = "G:\Program Files\Microsoft SQL Server"
               InstallSQLDataDir = "G:\MSSQL\Data"
               SQLUserDBDir = "G:\MSSQL\Data"
               SQLUserDBLogDir = "L:\MSSQL\Data"
               SQLTempDBDir = "T:\MSSQL\Data"
               SQLTempDBLogDir = "L:\MSSQL\Data"
               SQLBackupDir = "G:\MSSQL\Backup"
           }
           xSqlServerFirewall ($Node.NodeName)
           {
              SourcePath = $Node.SourcePath
              InstanceName = $Node.InstanceName
              Features = $Node.Features
           
              DependsOn = ("[xSqlServerSetup]" + $Node.NodeName)
           }
           xSQLServerPowerPlan ($Node.Nodename)
           {
               Ensure = "Present"
           }
           xSQLServerMemory ($Node.Nodename)
           {
               Ensure = "Present"
               DynamicAlloc = $True
           
               DependsOn = ("[xSqlServerSetup]" + $Node.NodeName)
           }
           xSQLServerMaxDop($Node.Nodename)
           {
               Ensure = "Present"
               DynamicAlloc = $true
           
               DependsOn = ("[xSqlServerSetup]" + $Node.NodeName)     
           }
        }
    }
}

$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName = "*"
            PSDscAllowPlainTextPassword = $false
            PSDscAllowDomainUser =$true
            NETPath = "\\ohdc9000\SQLBuilds\SQLAutoInstall\WIN2012R2\sxs"
            SourcePath = "\\ohdc9000\SQLAutoBuilds\SQL2014"
            InstallerServiceAccount = Get-Credential -UserName CORP\AutoSvc -Message "Credentials to Install SQL Server"
            AdminAccount = "CORP\user1"  
            # For build server encryption
            CertificateFile =(Get-PfxCertificate -FilePath "$KeyPath\$env:COMPUTERNAME.$env:USERDNSDOMAIN.cer").Thumbprint 
        }

    )
}

ForEach ($computer in $computers) {
            $ConfigurationData.AllNodes += @{
            NodeName        = $computer
            InstanceName    = "MSSQLSERVER"
            Features        = "SQLENGINE,IS,SSMS,ADV_SSMS"     
            CertificateFile = "$KeyPath\$computer.$env:USERDNSDOMAIN.cer"
            Thumbprint = (Get-PfxCertificate -FilePath "$KeyPath\$computer.$env:USERDNSDOMAIN.cer").Thumbprint    
            }
    
    
   $Destination = "\\"+$computer+"\\c$\Program Files\WindowsPowerShell\Modules"
   if (Test-Path "$Destination\xSqlServer"){Remove-Item -Path "$Destination\xSqlServer"-Recurse -Force}
   Copy-Item 'C:\Program Files\WindowsPowerShell\Modules\xSqlServer' -Destination $Destination -Recurse -Force
}


SQLBuild -ConfigurationData $ConfigurationData -OutputPath $OutputPath

Workflow StartConfigs 
{ 
    param([string[]]$computers,
        [System.string] $Path)
 
    foreach –parallel ($Computer in $Computers) 
    {   
        Start-DscConfiguration -ComputerName $Computer -Path $Path -Verbose -Wait -Force
    }
}

StartConfigs -Computers $computers -Path $OutputPath

#Ttest
<#
Workflow TestConfigs 
{ 
    param([string[]]$computers)
    foreach -parallel ($Computer in $Computers) 
    {
        Write-verbose "$Computer :"
        test-dscconfiguration -ComputerName $Computer
    }
}

TestConfigs -computers $computers
#>

$StartTime.Elapsed
