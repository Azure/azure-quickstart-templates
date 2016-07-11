configuration CreateADBDC 
{ 
   param 
    ( 
        [Parameter(Mandatory)]
        [String]$DomainName,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$Admincreds,

        [Int]$RetryCount=20,
        [Int]$RetryIntervalSec=30
    ) 
    
    Import-DscResource -ModuleName xActiveDirectory, xDisk, cDisk
    
    [System.Management.Automation.PSCredential ]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($Admincreds.UserName)", $Admincreds.Password)
   
    Node localhost
    {
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
			DependsOn = "[xWaitForDisk]Disk2"
        }

        WindowsFeature ADDSInstall 
        { 
            Ensure = "Present" 
            Name = "AD-Domain-Services"
			DependsOn = "[cDiskNoRestart]ADDataDisk"
        } 

		WindowsFeature ADAdminCenter 
        { 
            Ensure = "Present" 
            Name = "RSAT-AD-AdminCenter"
			DependsOn = "[WindowsFeature]ADDSInstall"
        }
		
		WindowsFeature ADDSTools 
        { 
            Ensure = "Present" 
            Name = "RSAT-ADDS-Tools"
			DependsOn = "[WindowsFeature]ADDSInstall"
        }  

        xWaitForADDomain DscForestWait 
        { 
            DomainName = $DomainName 
            DomainUserCredential= $DomainCreds
            RetryCount = $RetryCount 
            RetryIntervalSec = $RetryIntervalSec
			DependsOn = "[WindowsFeature]ADDSInstall"
        } 

        xADDomainController BDC 
        { 
            DomainName = $DomainName 
            DomainAdministratorCredential = $DomainCreds 
            SafemodeAdministratorPassword = $DomainCreds
            DatabasePath = "F:\NTDS"
            LogPath = "F:\NTDS"
            SysvolPath = "F:\SYSVOL"
			DependsOn = "[xWaitForADDomain]DscForestWait"
        }
	
		Script script1
		{
      	    SetScript =  { 
			$dnsFwdRule = Get-DnsServerForwarder
			if ($dnsFwdRule) { Remove-DnsServerForwarder -IPAddress $dnsFwdRule.IPAddress -Force }
					Write-Verbose -Verbose "Removing DNS forwarding rule" 
            }
            GetScript =  { @{} }
            TestScript = { $false}
			DependsOn = "[xADDomainController]BDC"
        }

        LocalConfigurationManager 
        {
       	    ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $true
        }
  }
} 
