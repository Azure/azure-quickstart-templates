configuration ConfigureADBDC
{
   param
    (
        [Parameter(Mandatory)]
        [String]$DomainName,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$Admincreds,

        [Int]$WaitTimeoutSeconds = 900
    )

    Import-DscResource -ModuleName ActiveDirectoryDsc, ComputerManagementDsc

    [System.Management.Automation.PSCredential ]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($Admincreds.UserName)", $Admincreds.Password)

    Node localhost
    {
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
        }
        
        WaitForADDomain DscForestWait
        {
            DomainName = $DomainName
            Credential = $DomainCreds
            WaitTimeout = $WaitTimeoutSeconds
        }

        ADDomainController BDC
        {
            DomainName = $DomainName
            Credential = $DomainCreds
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
            DependsOn = "[ADDomainController]BDC"
        }
#>
        PendingReboot RebootAfterPromotion {
            Name = "RebootAfterDCPromotion"
            DependsOn = "[ADDomainController]BDC"
        }

    }
}
