configuration ConfigureADBDC
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

    Import-DscResource -ModuleName xActiveDirectory, xPendingReboot

    [System.Management.Automation.PSCredential ]$DomainCreds = New-Object System.Management.Automation.PSCredential ("$($Admincreds.UserName)@${DomainName}", $Admincreds.Password)

    Node localhost
    {
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
        }
        xPendingReboot Reboot
        {
           Name = "Reboot"
        }
        Script Reboot
        {
            TestScript = {
            return (Test-Path HKLM:\SOFTWARE\MyMainKey\RebootKey)
            }
            SetScript = {
			New-Item -Path HKLM:\SOFTWARE\MyMainKey\RebootKey -Force
			$global:DSCMachineStatus = 1 
                }
            GetScript = { return @{result = 'result'}}
        }
        xWaitForADDomain DscForestWait
        {
            DomainName = $DomainName
            DomainUserCredential= $DomainCreds
            RetryCount = $RetryCount
            RetryIntervalSec = $RetryIntervalSec
            DependsOn = "[Script]Reboot"
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
<#
        Script UpdateDNSForwarder
        {
            SetScript =
            {
                Write-Verbose -Verbose "Getting DNS forwarding rule..."
                $dnsFwdRule = Get-DnsServerForwarder -Verbose
                if ($dnsFwdRule)
                {
                    Write-Verbose -Verbose "Removing DNS forwarding rule"
                    Remove-DnsServerForwarder -IPAddress $dnsFwdRule.IPAddress -Force -Verbose
                }
                Write-Verbose -Verbose "End of UpdateDNSForwarder script..."
            }
            GetScript =  { @{} }
            TestScript = { $false}
            DependsOn = "[xADDomainController]BDC"
        }
#>
        xPendingReboot RebootAfterPromotion {
            Name = "RebootAfterDCPromotion"
            DependsOn = "[xADDomainController]BDC"
        }

    }
}
