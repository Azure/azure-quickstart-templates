
<#PSScriptInfo

.VERSION 0.2.0

.GUID edd05043-2acc-48fa-b5b3-dab574621ba1

.AUTHOR Michael Greene

.COMPANYNAME Microsoft Corporation

.COPYRIGHT

.TAGS DSCConfiguration

.LICENSEURI https://github.com/Microsoft/DomainControllerConfig/blob/master/LICENSE

.PROJECTURI https://github.com/Microsoft/DomainControllerConfig

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
https://github.com/Microsoft/DomainControllerConfig/blob/master/README.md#releasenotes

.PRIVATEDATA OSVersions="2016-DataCenter","2016-Datacenter-Server-Core"

#>

#Requires -Module @{ModuleName='xActiveDirectory';ModuleVersion='2.16.0.0';GUID='9FECD4F6-8F02-4707-99B3-539E940E9FF5'},@{ModuleName='xStorage';ModuleVersion='3.2.0.0';GUID='00d73ca1-58b5-46b7-ac1a-5bfcf5814faf'}

<# 

.DESCRIPTION 
 Demonstrates a minimally viable domain controller configuration script
 compatible with Azure Automation Desired State Configuration service.
 
 Required variables in Automation service:
  - domainName - string that will be used as the Active Directory domain
  - domainCredential - credential to use for AD domain admin
  - safeModeCredential - credential to use for Safe Mode recovery

Required modules in Automation service:
  - xActiveDirectory version 2.16.0.0
  - xStorage version 3.2.0.0

#> 

configuration DomainControllerConfig
{

    $domainCredential = Get-AutomationPSCredential domainCredential
    $safeModeCredential = Get-AutomationPSCredential safeModeCredential

    Import-DscResource -ModuleName @{ModuleName='xActiveDirectory';ModuleVersion='2.16.0.0';GUID='9FECD4F6-8F02-4707-99B3-539E940E9FF5'},@{ModuleName='xStorage';ModuleVersion='3.2.0.0';GUID='00d73ca1-58b5-46b7-ac1a-5bfcf5814faf'},'PSDesiredStateConfiguration'

    Node $AllNodes.NodeName
    {
        WindowsFeature ADDSInstall
        {
            Ensure = 'Present'
            Name = 'AD-Domain-Services'
        }
        xWaitforDisk Disk2
        {
             DiskId = 2
             RetryIntervalSec = 10
             RetryCount = 30
        }
        xDisk DiskF
        {
             DiskId = 2
             DriveLetter = 'F'
        }
        xADDomain Domain
        {
            DomainName = $Node.domainName
            DomainAdministratorCredential = $domainCredential
            SafemodeAdministratorPassword = $safeModeCredential
            DatabasePath = 'F:\NTDS'
            LogPath = 'F:\NTDS'
            SysvolPath = 'F:\SYSVOL'
            DependsOn = '[WindowsFeature]ADDSInstall'
        }
   }
}
