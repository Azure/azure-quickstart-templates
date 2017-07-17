#
# Prereqs.ps1
#
Configuration Prereqs
{

Param (		
		[Parameter(Mandatory)]
        [String]$DomainName,

        [Parameter(Mandatory)]
        [PSCredential]$Admincreds,

        [Int]$RetryCount=20,
        [Int]$RetryIntervalSec=30 )

Import-DscResource -ModuleName PSDesiredStateConfiguration, xPendingReboot, xDisk, cDisk
[PSCredential ]$DomainCreds = New-Object PSCredential ("${DomainName}\$($Admincreds.UserName)", $Admincreds.Password)

# Lync Server 2013 prerequisit features

  Node localhost
  {  
    	  xPendingReboot Reboot1
      { 
            Name = "BeforePrereqsInstall"
      }
       Script PrereqsInstall 
      {
            SetScript = {

                Add-WindowsFeature -name "RSAT-DNS-Server","RSAT-ADDS","Web-Server","Web-Static-Content",`
	        "Web-Default-Doc","Web-Http-Errors", "Web-Asp-Net","Web-Net-Ext","Web-ISAPI-Ext","Web-ISAPI-Filter","Web-Http-Logging",`
	        "Web-Log-Libraries","Web-Request-Monitor","Web-Http-Tracing","Web-Basic-Auth","Web-Windows-Auth","Web-Client-Auth","Web-Filtering",`
	        "Web-Stat-Compression","Web-Dyn-Compression","NET-WCF-HTTP-Activation45","Web-Asp-Net45","Web-Mgmt-Tools","Web-Scripting-Tools","Web-Mgmt-Compat",`
        	"Desktop-Experience","BITS","Windows-Identity-Foundation","Server-Media-Foundation","Web-Dir-Browsing" -ErrorAction SilentlyContinue   
            }
            GetScript =  { @{} }
            TestScript = { $false }
      }

         xWaitforDisk Disk2
        {
             DiskNumber = 2
             RetryIntervalSec =$RetryIntervalSec
             RetryCount = $RetryCount
        }

        cDiskNoRestart ADDataDisk
        {
            DiskNumber = 2
            DriveLetter = "F"
        }

	  xPendingReboot Reboot2
      { 
            Name = "AfterPrereqsInstall"
			DependsOn = "[Script]PrereqsInstall", "[cDiskNoRestart]ADDataDisk"
      }

	  LocalConfigurationManager 
      {
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $true
            ActionAfterReboot = "ContinueConfiguration"
      }
  }
}